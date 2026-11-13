"""Data cleaning, deduplication, and suspect flagging (Phase 3).

Pipeline: clean → features → report over ``data/interim/runs_raw.parquet``.
"""

from collections.abc import Callable

import pandas as pd

from flamesense.schema import ENUMS

# Columns that define an "exact duplicate measurement" (PLAN.md Phase 3 step 1b).
# TODO(Q-18): replicate tests with distinct printed IDs match this key and are dropped (logged).
DUP_KEY_COLUMNS: list[str] = [
    "source_id",
    "fuel_name",
    "fuel_thickness_mm",  # same material at another thickness is a different test
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
        # Strip real strings only; booleans (ignited, sustained) and nulls keep their type.
        out[col] = out[col].map(lambda v: v.strip() if isinstance(v, str) else v)
    for col in ENUMS:
        if col in out.columns:
            out[col] = out[col].map(lambda v: v.lower() if isinstance(v, str) else v)
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


DROP_REASON = "exact duplicate on DUP_KEY_COLUMNS (PLAN.md Phase 3 step 1b)"


def dropped_row_log(df: pd.DataFrame, duplicates: pd.Series) -> list[dict]:
    """One record per duplicate row: its run_id, the kept run_id and the reason."""
    # Same grouping as DataFrame.duplicated (NaN equals NaN).
    keys = df.groupby(DUP_KEY_COLUMNS, dropna=False, sort=False).ngroup()
    first_by_key = df.loc[~duplicates].assign(_k=keys[~duplicates]).set_index("_k")["run_id"]
    return [
        {
            "run_id": str(df.at[i, "run_id"]),
            "kept_run_id": str(first_by_key.get(keys.at[i], "")),
            "source_id": str(df.at[i, "source_id"]),
            "reason": DROP_REASON,
        }
        for i in df.index[duplicates]
    ]


def clean(
    df: pd.DataFrame,
    *,
    drop_duplicates: bool = True,
    flag_suspect: bool = True,
) -> tuple[pd.DataFrame, dict]:
    """Clean, dedupe, and flag suspect rows.

    Returns ``(cleaned_df, summary)``; ``summary`` carries ``rows_in``,
    ``rows_out``, ``dropped`` and ``suspect`` counts (PLAN.md Phase 3 step 1),
    plus ``dropped_rows``: one record per dropped row naming the kept row it
    duplicates, so no row is ever dropped silently.
    """
    out = strip_and_normalise(df)
    summary: dict = {"rows_in": len(out), "rows_out": len(out), "dropped": 0, "suspect": 0,
                     "dropped_rows": []}

    if drop_duplicates:
        duplicates = out.duplicated(subset=DUP_KEY_COLUMNS, keep="first")
        summary["dropped"] = int(duplicates.sum())
        summary["dropped_rows"] = dropped_row_log(out, duplicates)
        out = out.loc[~duplicates].copy()

    if flag_suspect:
        out = flag_suspect_rows(out)
        summary["suspect"] = int((out["quality_flag"] == "suspect").sum())

    summary["rows_out"] = len(out)
    return out, summary