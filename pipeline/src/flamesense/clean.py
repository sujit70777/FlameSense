"""Data cleaning, deduplication, and suspect flagging (Phase 3).

Pipeline: clean → features → report over ``data/interim/runs_raw.parquet``.
"""

from collections.abc import Callable

import pandas as pd

from flamesense.schema import ENUMS

# Columns that define an "exact duplicate measurement" (PLAN.md Phase 3 step 1b).
DUP_KEY_COLUMNS: list[str] = [
    "source_id",
    "fuel_name",
    "o2_mole_fraction",
    "pressure_kpa",
    "flow_velocity_mm_s",
    "gravity_g",
    "flame_spread_rate_mm_s",
]

# Physically impossible combinations (PLAN.md Phase 3 step 1c), filled from
# QUESTIONS.md answers as the lead agrees them. Each entry takes the
# DataFrame and returns a boolean Series marking impossible rows.
IMPOSSIBLE_PREDICATES: list[Callable[[pd.DataFrame], pd.Series]] = []


def strip_and_normalise(df: pd.DataFrame) -> pd.DataFrame:
    """Strip whitespace from string columns and lowercase enum columns."""
    out = df.copy()
    for col in out.select_dtypes(include=["object", "string"]).columns:
        out[col] = out[col].astype(str).str.strip()
    for col in ENUMS:
        if col in out.columns:
            out[col] = out[col].str.lower()
    return out


def flag_suspect_rows(df: pd.DataFrame) -> pd.DataFrame:
    """Mark suspect rows instead of deleting them (PLAN.md Phase 3 step 1c).

    A row is flagged ``suspect`` when its spread rate exceeds the 99.5th
    percentile of spread rates × 3, or when it matches an impossible
    combination in IMPOSSIBLE_PREDICATES. No rows are ever deleted here.
    """
    out = df.copy()
    suspect = pd.Series(False, index=out.index)

    spread = pd.to_numeric(out["flame_spread_rate_mm_s"], errors="coerce")
    valid = spread.dropna()
    if len(valid) > 0:
        p995 = float(valid.quantile(0.995))
        if p995 > 0:
            suspect |= spread > (p995 * 3.0)

    for predicate in IMPOSSIBLE_PREDICATES:
        suspect |= predicate(out).fillna(False).astype(bool)

    out.loc[suspect, "quality_flag"] = "suspect"
    return out


def clean(
    df: pd.DataFrame,
    *,
    drop_duplicates: bool = True,
    flag_suspect: bool = True,
) -> tuple[pd.DataFrame, dict]:
    """Clean, dedupe, and flag suspect rows.

    Returns ``(cleaned_df, summary)``; ``summary`` carries ``rows_in``,
    ``rows_out``, ``dropped`` and ``suspect`` counts (PLAN.md Phase 3 step 1).
    """
    out = strip_and_normalise(df)
    summary: dict = {"rows_in": len(out), "rows_out": len(out), "dropped": 0, "suspect": 0}

    if drop_duplicates:
        duplicates = out.duplicated(subset=DUP_KEY_COLUMNS, keep="first")
        summary["dropped"] = int(duplicates.sum())
        out = out.loc[~duplicates].copy()

    if flag_suspect:
        out = flag_suspect_rows(out)
        summary["suspect"] = int((out["quality_flag"] == "suspect").sum())

    summary["rows_out"] = len(out)
    return out, summary