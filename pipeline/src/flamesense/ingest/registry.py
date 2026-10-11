"""Registry for dataset adapters and source ingestion."""

from pathlib import Path
import importlib
from typing import Any
import pandas as pd
import yaml

from flamesense.config import ROOT, DATA_RAW, DATA_INTERIM
from flamesense.schema import CANONICAL_COLUMNS


def get_adapter(name: str) -> Any:
    """Import and return the adapter module by name."""
    try:
        module = importlib.import_module(f"flamesense.ingest.adapters.{name}")
        if not hasattr(module, "load"):
            raise AttributeError(f"Adapter '{name}' must implement a 'load' function.")
        return module
    except ImportError as e:
        raise ImportError(f"Could not import adapter '{name}': {e}") from e


def run_ingest(sources_yaml_path: Path | None = None) -> pd.DataFrame:
    """Ingest all sources defined in sources.yaml and write to data/interim/runs_raw.parquet."""
    if sources_yaml_path is None:
        sources_yaml_path = ROOT / "pipeline" / "sources.yaml"

    if not sources_yaml_path.exists():
        raise FileNotFoundError(f"Configuration file not found: {sources_yaml_path}")

    with open(sources_yaml_path, "r", encoding="utf-8") as f:
        config = yaml.safe_load(f) or {}

    sources = config.get("sources", [])
    if not sources:
        print("Warning: No sources defined in sources.yaml.")
        df_empty = pd.DataFrame(columns=CANONICAL_COLUMNS)
        DATA_INTERIM.mkdir(parents=True, exist_ok=True)
        out_path = DATA_INTERIM / "runs_raw.parquet"
        df_empty.to_parquet(out_path, index=False)
        print(f"Written empty interim dataset to {out_path.relative_to(ROOT)} (0 rows)")
        return df_empty

    all_frames: list[pd.DataFrame] = []

    print("=== Running Data Ingestion ===")
    for src in sources:
        source_id = src.get("id")
        adapter_name = src.get("adapter")
        files = src.get("files", [])

        if not source_id or not adapter_name:
            print(f"Skipping malformed source entry: {src}")
            continue

        print(f"Ingesting source '{source_id}' with adapter '{adapter_name}' ({len(files)} file pattern(s))...")
        adapter = get_adapter(adapter_name)
        df_src = adapter.load(DATA_RAW, files)

        if not df_src.empty:
            df_src["source_id"] = source_id
            print(f"  -> Ingested {len(df_src)} row(s) for '{source_id}'")
            all_frames.append(df_src)
        else:
            print(f"  -> 0 rows returned for '{source_id}'")

    if all_frames:
        combined_df = pd.concat(all_frames, ignore_index=True)
    else:
        combined_df = pd.DataFrame(columns=CANONICAL_COLUMNS)

    DATA_INTERIM.mkdir(parents=True, exist_ok=True)
    out_parquet = DATA_INTERIM / "runs_raw.parquet"
    combined_df.to_parquet(out_parquet, index=False)

    print(f"\nIngestion summary: Total {len(combined_df)} row(s) written to {out_parquet.relative_to(ROOT)}")
    for src_id, count in combined_df["source_id"].value_counts().items():
        print(f"  - {src_id}: {count} row(s)")

    return combined_df
