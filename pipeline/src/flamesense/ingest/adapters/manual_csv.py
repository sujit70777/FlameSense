"""Adapter for manually digitized experiment CSVs in data/manual/*.csv."""

from pathlib import Path
import glob
import pandas as pd

from flamesense.schema import CANONICAL_COLUMNS


def load(raw_dir: Path, files: list[str]) -> pd.DataFrame:
    """Load canonical CSV files from data/manual/ and type-cast to canonical schema."""
    frames: list[pd.DataFrame] = []

    resolved_files: list[Path] = []
    for pattern in files:
        p = Path(pattern)
        if not p.is_absolute():
            # Check relative to repo root first, then raw_dir
            if (p).exists():
                resolved_files.append(p)
                continue
            matched = list(raw_dir.glob(pattern)) or list(Path(".").glob(pattern))
            if matched:
                resolved_files.extend(matched)
            else:
                p_in_dir = raw_dir / pattern
                if p_in_dir.exists():
                    resolved_files.append(p_in_dir)
        else:
            resolved_files.extend([Path(f) for f in glob.glob(str(p))])

    resolved_files = sorted(list(set(resolved_files)))

    for file_path in resolved_files:
        if not file_path.exists() or file_path.suffix.lower() != ".csv":
            continue
        df = pd.read_csv(file_path)
        
        # Ensure all canonical columns exist
        for col in CANONICAL_COLUMNS:
            if col not in df.columns:
                df[col] = None

        # Reorder to canonical columns
        df = df[CANONICAL_COLUMNS].copy()

        # Type-casting
        df["run_id"] = df["run_id"].astype(str)
        df["group_id"] = df["group_id"].astype(str)
        df["experiment"] = df["experiment"].astype(str)
        df["platform"] = df["platform"].astype(str).str.strip().str.lower()
        df["fuel_name"] = df["fuel_name"].astype(str)
        df["fuel_class"] = df["fuel_class"].astype(str).str.strip().str.lower()
        df["source_id"] = df["source_id"].astype(str)
        df["source_file"] = df["source_file"].astype(str)
        df["source_citation"] = df["source_citation"].astype(str)
        df["quality_flag"] = df["quality_flag"].astype(str).str.strip().str.lower()

        for num_col in [
            "gravity_g",
            "fuel_thickness_mm",
            "fuel_density_kg_m3",
            "o2_mole_fraction",
            "pressure_kpa",
            "flow_velocity_mm_s",
            "flame_spread_rate_mm_s",
            "burning_rate_k_mm2_s",
        ]:
            if num_col in df.columns:
                df[num_col] = pd.to_numeric(df[num_col], errors="coerce")

        for bool_col in ["ignited", "sustained"]:
            if bool_col in df.columns:
                df[bool_col] = df[bool_col].map(
                    {True: True, False: False, "True": True, "False": False, "1": True, "0": False, 1: True, 0: False}
                )

        frames.append(df)

    if not frames:
        return pd.DataFrame(columns=CANONICAL_COLUMNS)

    combined = pd.concat(frames, ignore_index=True)
    return combined[CANONICAL_COLUMNS]
