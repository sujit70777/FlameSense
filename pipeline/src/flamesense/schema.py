"""Canonical schema definition and validation for experiment runs."""

import pandas as pd

CANONICAL_COLUMNS: list[str] = [
    "run_id",
    "group_id",
    "experiment",
    "platform",
    "gravity_g",
    "fuel_name",
    "fuel_class",
    "fuel_thickness_mm",
    "fuel_density_kg_m3",
    "o2_mole_fraction",
    "pressure_kpa",
    "diluent",
    "flow_velocity_mm_s",
    "flow_direction",
    "ignited",
    "sustained",
    "flame_spread_rate_mm_s",
    "burning_rate_k_mm2_s",
    "extinction_reason",
    "source_id",
    "source_file",
    "source_citation",
    "source_url",
    "quality_flag",
    "notes",
]

REQUIRED: set[str] = {
    "run_id",
    "group_id",
    "experiment",
    "platform",
    "gravity_g",
    "fuel_name",
    "fuel_class",
    "o2_mole_fraction",
    "pressure_kpa",
    "source_id",
    "source_file",
    "source_citation",
    "quality_flag",
}

ENUMS: dict[str, set[str]] = {
    "platform": {"iss", "free_flyer", "drop_tower", "parabolic", "ground"},
    "fuel_class": {"thin_solid", "thick_solid", "droplet", "gas_jet", "other"},
    "diluent": {"n2", "he", "co2", "other"},
    "flow_direction": {"opposed", "concurrent", "quiescent", "other"},
    "quality_flag": {"ok", "estimated", "digitized", "video_derived", "suspect"},
}


def validate(df: pd.DataFrame) -> list[str]:
    """Validate DataFrame against canonical schema §3.1.
    
    Returns a list of human-readable error descriptions. Empty list if valid.
    """
    errors: list[str] = []

    # 1. Missing required columns
    missing_cols = [c for c in CANONICAL_COLUMNS if c not in df.columns]
    if missing_cols:
        errors.append(f"Missing canonical columns: {', '.join(missing_cols)}")
        return errors  # Cannot proceed with row-level checks if columns are missing

    # 2. Nulls in required columns
    for col in sorted(REQUIRED):
        null_count = int(df[col].isna().sum())
        if null_count > 0:
            errors.append(f"Required column '{col}' has {null_count} null value(s)")

    # 3. Enum violations
    for col, allowed in ENUMS.items():
        if col in df.columns:
            non_null = df[col].dropna().astype(str).str.strip().str.lower()
            invalid = non_null[~non_null.isin(allowed)]
            if len(invalid) > 0:
                sample_invalid = sorted(invalid.unique())[:5]
                errors.append(
                    f"Column '{col}' has {len(invalid)} enum violation(s). Invalid sample: {sample_invalid}"
                )

    # 4. o2_mole_fraction not in (0, 1]
    if "o2_mole_fraction" in df.columns:
        o2 = pd.to_numeric(df["o2_mole_fraction"], errors="coerce")
        invalid_o2 = (o2 <= 0.0) | (o2 > 1.0)
        invalid_count = int(invalid_o2.sum())
        if invalid_count > 0:
            errors.append(f"'o2_mole_fraction' has {invalid_count} value(s) outside (0, 1]")

    # 5. pressure_kpa not in (0, 1000]
    if "pressure_kpa" in df.columns:
        p = pd.to_numeric(df["pressure_kpa"], errors="coerce")
        invalid_p = (p <= 0.0) | (p > 1000.0)
        invalid_count = int(invalid_p.sum())
        if invalid_count > 0:
            errors.append(f"'pressure_kpa' has {invalid_count} value(s) outside (0, 1000]")

    # 6. gravity_g not in (0, 1.5]
    if "gravity_g" in df.columns:
        g = pd.to_numeric(df["gravity_g"], errors="coerce")
        invalid_g = (g <= 0.0) | (g > 1.5)
        invalid_count = int(invalid_g.sum())
        if invalid_count > 0:
            errors.append(f"'gravity_g' has {invalid_count} value(s) outside (0, 1.5]")

    # 7. Negative rates
    if "flame_spread_rate_mm_s" in df.columns:
        spread = pd.to_numeric(df["flame_spread_rate_mm_s"].dropna(), errors="coerce")
        neg_spread = int((spread < 0.0).sum())
        if neg_spread > 0:
            errors.append(f"'flame_spread_rate_mm_s' has {neg_spread} negative value(s)")

    if "burning_rate_k_mm2_s" in df.columns:
        burning = pd.to_numeric(df["burning_rate_k_mm2_s"].dropna(), errors="coerce")
        neg_burning = int((burning < 0.0).sum())
        if neg_burning > 0:
            errors.append(f"'burning_rate_k_mm2_s' has {neg_burning} negative value(s)")

    # 8. Duplicate run_id
    if "run_id" in df.columns:
        dup_mask = df["run_id"].duplicated(keep=False)
        dup_count = int(dup_mask.sum())
        if dup_count > 0:
            sample_dups = df.loc[dup_mask, "run_id"].unique()[:5].tolist()
            errors.append(f"'run_id' has {dup_count} duplicate value(s). Sample: {sample_dups}")

    # 9. Empty source_citation
    if "source_citation" in df.columns:
        empty_cit = df["source_citation"].isna() | (df["source_citation"].astype(str).str.strip() == "")
        empty_count = int(empty_cit.sum())
        if empty_count > 0:
            errors.append(f"'source_citation' has {empty_count} empty value(s)")

    return errors
