"""Project paths and configuration."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DATA_RAW = ROOT / "data" / "raw"
DATA_MANUAL = ROOT / "data" / "manual"
DATA_INTERIM = ROOT / "data" / "interim"
DATA_PROCESSED = ROOT / "data" / "processed"
CORPUS_RAW = ROOT / "data" / "corpus_raw"
PIPELINE_OUT = ROOT / "pipeline" / "out"
APP_ASSETS_OUT = PIPELINE_OUT / "app_assets"
DOCS = ROOT / "docs"
DOCS_IMG = DOCS / "img"
