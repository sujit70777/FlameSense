"""CLI entry point for the FlameSense pipeline."""

import argparse
import sys


def cmd_inspect(args: argparse.Namespace) -> None:
    """Print info about every raw/manual data file."""
    print("Not implemented yet (Phase 2)")


def cmd_ingest(args: argparse.Namespace) -> None:
    """Run adapters from sources.yaml to produce runs_raw.parquet."""
    print("Not implemented yet (Phase 2)")


def cmd_validate(args: argparse.Namespace) -> None:
    """Check canonical schema on ingested data."""
    print("Not implemented yet (Phase 2)")


def cmd_clean(args: argparse.Namespace) -> None:
    """Clean and deduplicate runs."""
    print("Not implemented yet (Phase 3)")


def cmd_features(args: argparse.Namespace) -> None:
    """Add derived feature columns."""
    print("Not implemented yet (Phase 3)")


def cmd_report(args: argparse.Namespace) -> None:
    """Generate data report and charts."""
    print("Not implemented yet (Phase 3)")


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
