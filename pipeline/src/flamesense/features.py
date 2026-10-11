"""Derived feature columns (PLAN.md §3.1, Phase 3)."""

import numpy as np
import pandas as pd

# Categorical columns that become one-hot columns, using only values present.
ONE_HOT_COLUMNS: list[str] = ["fuel_class", "flow_direction", "diluent"]


def add_features(df: pd.DataFrame) -> pd.DataFrame:
    """Add derived columns and one-hot encodings to an experiment-run frame.

    Derived columns (exact formulas from PLAN.md §3.1):
      log10_gravity        = log10(max(gravity_g, 1e-7))
      o2_partial_kpa       = o2_mole_fraction × pressure_kpa
      log10_flow           = log10(flow_velocity_mm_s + 1)
      areal_density_kg_m2  = fuel_thickness_mm / 1000 × fuel_density_kg_m3
    Plus one-hot columns ``<col>__<value>`` for each value present in the
    data. Missing inputs propagate as NaN (never invented).
    """
    out = df.copy()

    gravity_g = pd.to_numeric(out["gravity_g"], errors="coerce")
    out["log10_gravity"] = np.log10(np.maximum(gravity_g, 1e-7))

    o2 = pd.to_numeric(out["o2_mole_fraction"], errors="coerce")
    pressure = pd.to_numeric(out["pressure_kpa"], errors="coerce")
    out["o2_partial_kpa"] = o2 * pressure

    flow = pd.to_numeric(out["flow_velocity_mm_s"], errors="coerce")
    out["log10_flow"] = np.log10(flow + 1.0)

    thickness = pd.to_numeric(out["fuel_thickness_mm"], errors="coerce")
    density = pd.to_numeric(out["fuel_density_kg_m3"], errors="coerce")
    out["areal_density_kg_m2"] = thickness / 1000.0 * density

    for col in ONE_HOT_COLUMNS:
        if col not in out.columns:
            continue
        for value in sorted(out[col].dropna().unique()):
            out[f"{col}__{value}"] = (out[col] == value).fillna(False).astype(int)

    return out