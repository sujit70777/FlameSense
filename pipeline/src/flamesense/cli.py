"""CLI entry point for the FlameSense pipeline."""

import argparse
import sys


def cmd_inspect(args: argparse.Namespace) -> None:
    """Print info about every raw/manual data file and write docs/DATA_INSPECTION.md."""
    from flamesense.inspect_data import run_inspect
    run_inspect()


def cmd_ingest(args: argparse.Namespace) -> None:
    """Run adapters from sources.yaml to produce runs_raw.parquet."""
    from flamesense.ingest.registry import run_ingest
    run_ingest()


def cmd_validate(args: argparse.Namespace) -> None:
    """Check canonical schema on ingested data."""
    import pandas as pd

    from flamesense.config import DATA_INTERIM
    from flamesense.schema import validate

    parquet_path = DATA_INTERIM / "runs_raw.parquet"
    if not parquet_path.exists():
        print(f"Error: Ingested file not found at {parquet_path}. Run 'python -m flamesense.cli ingest' first.")
        sys.exit(1)

    df = pd.read_parquet(parquet_path)
    print(f"Validating dataset from {parquet_path} ({len(df)} rows)...")

    errors = validate(df)
    if not errors:
        print("\n==========================================")
        print("Schema Validation Passed: 0 errors found.")
        print(f"Total valid runs: {len(df)}")
        print("==========================================")
    else:
        print("\n==========================================")
        print(f"Schema Validation FAILED with {len(errors)} error(s):")
        print("==========================================")
        for i, err in enumerate(errors, 1):
            print(f"  {i}. {err}")
        sys.exit(1)


def cmd_clean(args: argparse.Namespace) -> None:
    """Clean and deduplicate runs → data/processed/runs.parquet."""
    import pandas as pd

    from flamesense import config
    from flamesense.clean import clean

    src = config.DATA_INTERIM / "runs_raw.parquet"
    if not src.exists():
        print(f"Error: Ingested file not found at {src}. Run 'python -m flamesense.cli ingest' first.")
        sys.exit(1)

    df = pd.read_parquet(src)
    cleaned, stats = clean(df)
    config.DATA_PROCESSED.mkdir(parents=True, exist_ok=True)
    out = config.DATA_PROCESSED / "runs.parquet"
    cleaned.to_parquet(out, index=False)

    print(f"Cleaned {stats['rows_in']} → {stats['rows_out']} rows")
    print(f"  dropped {stats['dropped']} exact duplicate(s)")
    print(f"  flagged {stats['suspect']} suspect row(s) (kept, quality_flag='suspect')")
    print(f"Wrote {out.relative_to(config.ROOT)}")


def cmd_features(args: argparse.Namespace) -> None:
    """Add derived columns → data/processed/runs_features.parquet."""
    import pandas as pd

    from flamesense import config
    from flamesense.features import add_features

    src = config.DATA_PROCESSED / "runs.parquet"
    if not src.exists():
        print(f"Error: Cleaned file not found at {src}. Run 'python -m flamesense.cli clean' first.")
        sys.exit(1)

    df = pd.read_parquet(src)
    feats = add_features(df)
    config.DATA_PROCESSED.mkdir(parents=True, exist_ok=True)
    out = config.DATA_PROCESSED / "runs_features.parquet"
    feats.to_parquet(out, index=False)

    derived_formulas = ["log10_gravity", "o2_partial_kpa", "log10_flow", "areal_density_kg_m2"]
    derived = [c for c in feats.columns if c in derived_formulas or "__" in c]
    print(f"Features: {len(feats)} rows × {len(feats.columns)} columns")
    print(f"  derived/one-hot columns added: {len(derived)}")
    print(f"Wrote {out.relative_to(config.ROOT)}")


def cmd_report(args: argparse.Namespace) -> None:
    """Generate data report and charts → docs/DATA_REPORT.md + docs/img/*.png."""
    import pandas as pd

    from flamesense import config
    from flamesense.report import generate_report

    src = config.DATA_PROCESSED / "runs_features.parquet"
    if not src.exists():
        src = config.DATA_PROCESSED / "runs.parquet"
    if not src.exists():
        print(f"Error: No processed data found in {config.DATA_PROCESSED}. Run 'python -m flamesense.cli clean' first.")
        sys.exit(1)

    df = pd.read_parquet(src)
    md = generate_report(df, config.DOCS / "DATA_REPORT.md", config.DOCS_IMG)
    print(f"Wrote {md.relative_to(config.ROOT)}")
    print(f"Charts written to {config.DOCS_IMG.relative_to(config.ROOT)}/chart_*.png")


def cmd_track_video(args: argparse.Namespace) -> None:
    """Extract spread rates from flame video."""
    print("Not implemented yet (Phase 3B)")


def cmd_physics_check(args: argparse.Namespace) -> None:
    """Validate physics params and compare predictions to observed data."""
    print("Not implemented yet (Phase 4)")


def cmd_train(args: argparse.Namespace) -> None:
    """Train LightGBM models with grouped CV."""
    print("Not implemented yet (Phase 5)")


def cmd_export(args: argparse.Namespace) -> None:
    """Export models and data to app asset JSON files."""
    print("Not implemented yet (Phase 5)")


def cmd_evaluate(args: argparse.Namespace) -> None:
    """Compute and export evaluation metrics."""
    print("Not implemented yet (Phase 5)")


def cmd_corpus(args: argparse.Namespace) -> None:
    """Process PDFs/HTML into corpus_chunks.json."""
    print("Not implemented yet (Phase 12)")


def cmd_ask_cache(args: argparse.Namespace) -> None:
    """Generate cached answers for suggested questions."""
    print("Not implemented yet (Phase 12)")


def cmd_all(args: argparse.Namespace) -> None:
    """Run the full pipeline: ingest → validate → clean → features → report → train → export → evaluate."""
    for cmd in [cmd_ingest, cmd_validate, cmd_clean, cmd_features, cmd_report, cmd_train, cmd_export, cmd_evaluate]:
        cmd(args)


def main() -> None:
    """Parse arguments and dispatch to the appropriate command."""
    parser = argparse.ArgumentParser(
        prog="flamesense",
        description="FlameSense data pipeline CLI",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("inspect", help="Print info about raw/manual data files")
    sub.add_parser("ingest", help="Run source adapters → runs_raw.parquet")
    sub.add_parser("validate", help="Check canonical schema")
    sub.add_parser("clean", help="Clean and deduplicate")
    sub.add_parser("features", help="Add derived columns")
    sub.add_parser("report", help="Generate data report + charts")
    sub.add_parser("track-video", help="Extract spread rates from video")
    sub.add_parser("physics-check", help="Validate physics params vs observed")
    sub.add_parser("train", help="Train LightGBM models")
    sub.add_parser("export", help="Export models + data to app assets")
    sub.add_parser("evaluate", help="Compute evaluation metrics")
    sub.add_parser("corpus", help="Process documents → corpus_chunks.json")
    sub.add_parser("ask-cache", help="Cache answers for suggested questions")
    sub.add_parser("all", help="Run full pipeline end to end")

    args = parser.parse_args()

    commands = {
        "inspect": cmd_inspect,
        "ingest": cmd_ingest,
        "validate": cmd_validate,
        "clean": cmd_clean,
        "features": cmd_features,
        "report": cmd_report,
        "track-video": cmd_track_video,
        "physics-check": cmd_physics_check,
        "train": cmd_train,
        "export": cmd_export,
        "evaluate": cmd_evaluate,
        "corpus": cmd_corpus,
        "ask-cache": cmd_ask_cache,
        "all": cmd_all,
    }

    commands[args.command](args)


if __name__ == "__main__":
    sys.exit(main() or 0)
