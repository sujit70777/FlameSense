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
    import sys

    import matplotlib

    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    import pandas as pd

    from flamesense import config
    from flamesense.physics import (
        applicability,
        load_params,
        spread_rate_mm_s,
        validate_params,
    )

    params_path = config.DATA_MANUAL / "physics_params.json"
    params = load_params(params_path)
    if params is None:
        print(f"Error: {params_path.relative_to(config.ROOT)} is missing. "
              f"[LEAD] must create it (PLAN.md §3.7).")
        sys.exit(1)

    print("=== Physics parameters ===")
    print(f"File: {params_path.relative_to(config.ROOT)} (version {params.get('version', '?')})")
    print(f"Signed off by [LEAD]: {params.get('signed_off_by_lead', False)}")

    problems = validate_params(params)
    if problems:
        print(f"\nParameters NOT valid — {len(problems)} problem(s), predictions unavailable:")
        for i, p in enumerate(problems, 1):
            print(f"  {i}. {p}")
    else:
        print("\nParameters valid: all required values present and sources filled.")

    src = config.DATA_PROCESSED / "runs_features.parquet"
    if not src.exists():
        src = config.DATA_PROCESSED / "runs.parquet"
    if not src.exists():
        if problems:
            print("\nNo processed data and invalid params — nothing to compare.")
        else:
            print("\nNo processed data (0 rows) — nothing to compare. "
                  "Run 'python -m flamesense.cli all' after ingesting data.")
        sys.exit(1 if problems else 0)

    df = pd.read_parquet(src)
    print(f"\n=== Physics vs observed ({len(df)} rows) ===")

    apps = df.apply(applicability, axis=1)
    app_counts = apps.value_counts()
    for cls in ["ok", "near_extinction_warning", "not_applicable"]:
        print(f"  {cls}: {int(app_counts.get(cls, 0))}")
    if "near_extinction_warning" in app_counts:
        print("  Note: near-extinction rows flagged (TODO(Q-1), QUESTIONS.md); "
              "formula over-predicts there.")

    if problems:
        print("\nSkipping comparison: params invalid (see problems above).")
        sys.exit(1)

    applicable = df[apps.isin(["ok", "near_extinction_warning"])].copy()
    if not applicable.empty:
        applicable["physics_mm_s"] = applicable.apply(
            lambda r: spread_rate_mm_s(r, params), axis=1
        )
        valid = applicable.dropna(subset=["physics_mm_s", "flame_spread_rate_mm_s"])
        valid = valid[valid["flame_spread_rate_mm_s"].notna()].copy()
        if valid.empty:
            print("No rows with both physics prediction and observed spread rate.")
        else:
            mae = float((valid["physics_mm_s"] - valid["flame_spread_rate_mm_s"]).abs().mean())
            n_valid = len(valid)
            print(f"Physics MAE vs observed: {mae:.4g} mm/s over {n_valid} applicable row(s)")

            both_pos = valid[(valid["physics_mm_s"] > 0) & (valid["flame_spread_rate_mm_s"] > 0)]
            if not both_pos.empty:
                fig, ax = plt.subplots(figsize=(8, 5))
                ax.scatter(
                    both_pos["flame_spread_rate_mm_s"],
                    both_pos["physics_mm_s"],
                    s=28,
                    c="#1F66D6",
                    alpha=0.8,
                    label="runs",
                )
                lo = min(
                    both_pos["flame_spread_rate_mm_s"].min(),
                    both_pos["physics_mm_s"].min(),
                )
                hi = max(
                    both_pos["flame_spread_rate_mm_s"].max(),
                    both_pos["physics_mm_s"].max(),
                )
                ax.plot([lo, hi], [lo, hi], color="#D9560B", linestyle="--", label="1:1")
                ax.set_xscale("log")
                ax.set_yscale("log")
                ax.set_title("Physics vs observed spread rate", loc="left")
                ax.set_xlabel("Observed spread rate (mm/s, log scale)")
                ax.set_ylabel("Physics spread rate (mm/s, log scale)")
                ax.legend()
                fig.tight_layout()
                chart_path = config.DOCS_IMG / "physics_vs_observed.png"
                chart_path.parent.mkdir(parents=True, exist_ok=True)
                fig.savefig(chart_path, dpi=150, bbox_inches="tight", facecolor="white")
                plt.close(fig)
                print(f"Wrote {chart_path.relative_to(config.ROOT)}")

    # Copy validated params to app assets (only when validation passed).
    out = config.APP_ASSETS_OUT / "physics_params.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(params_path.read_text(encoding="utf-8"), encoding="utf-8")
    print(f"Copied validated params to {out.relative_to(config.ROOT)}")


def _load_features_frame():
    """Read data/processed/runs_features.parquet or exit with a hint."""
    import pandas as pd

    from flamesense import config

    src = config.DATA_PROCESSED / "runs_features.parquet"
    if not src.exists():
        print(f"Error: {src} not found. Run 'python -m flamesense.cli features' first.")
        sys.exit(1)
    return pd.read_parquet(src)


def cmd_train(args: argparse.Namespace) -> None:
    """Train LightGBM models with grouped CV → artifacts/."""
    from flamesense import config
    from flamesense.train import train_all

    summaries = train_all(_load_features_frame(), config.ARTIFACTS)
    for task, s in summaries.items():
        if s["available"]:
            print(f"{task}: trained on {s['n_rows']} rows, {s['n_groups']} group(s), "
                  f"{len(s['features'])} features, CV {s['cv']}")
        else:
            print(f"{task}: unavailable — {s['reason']}")
        print(f"  candidate rows {s['n_candidate_rows']}, "
              f"dropped for missing features {s['n_dropped_missing']}")
        for w in s["warnings"]:
            print(f"  warning: {w}")
    print(f"Wrote {(config.ARTIFACTS / 'train_summary.json').relative_to(config.ROOT)}")


def cmd_export(args: argparse.Namespace) -> None:
    """Export models and data to app asset JSON files."""
    from flamesense import config
    from flamesense.export import export_all

    written = export_all(_load_features_frame(), config.ARTIFACTS, config.APP_ASSETS_OUT)
    for name, path in written.items():
        print(f"  {name}: {path.stat().st_size / 1024:.1f} KB")
    print(f"Exported {len(written)} file(s) to {config.APP_ASSETS_OUT.relative_to(config.ROOT)}")


def cmd_evaluate(args: argparse.Namespace) -> None:
    """Compute metrics.json, docs/MODEL_CARD.md and evaluation charts."""
    from flamesense import config
    from flamesense.evaluate import evaluate_all
    from flamesense.export import write_json
    from flamesense.model_card import load_json, write_charts, write_model_card

    metrics = evaluate_all(_load_features_frame(), config.ARTIFACTS)
    write_json(config.APP_ASSETS_OUT / "metrics.json", metrics, indent=1)
    summaries = load_json(config.ARTIFACTS / "train_summary.json")
    card = write_model_card(metrics, summaries, config.DOCS / "MODEL_CARD.md")
    charts = write_charts(metrics, summaries, config.DOCS_IMG)
    for task, m in metrics.items():
        state = "available" if m["available"] else f"unavailable ({m['reason']})"
        print(f"{task}: {state}")
    print(f"Wrote metrics.json, {card.relative_to(config.ROOT)} and {len(charts)} chart(s)")


def cmd_corpus(args: argparse.Namespace) -> None:
    """Process PDFs/HTML into pipeline/out/corpus_chunks.json."""
    from flamesense import config
    from flamesense.corpus import build_corpus, write_corpus

    corpus = build_corpus(config.CORPUS_RAW)
    if not corpus["docs"]:
        print("Warning: data/corpus_raw/corpus_meta.csv not found; writing an empty corpus "
              "(Ask answers 'not found' until documents are added).")
    size = write_corpus(corpus, config.PIPELINE_OUT / "corpus_chunks.json")
    print(f"Corpus: {len(corpus['docs'])} docs, {len(corpus['chunks'])} chunks, {size / 1024:.1f} KB")


def cmd_ask_cache(args: argparse.Namespace) -> None:
    """Cache answers for the suggested questions from a running /api/ask."""
    import json

    from flamesense import config
    from flamesense.ask_cache import build_cache

    cache = build_cache(args.url, config.ROOT / "app" / "lib" / "l10n")
    out = config.APP_ASSETS_OUT / "ask_cache.json"
    out.write_text(json.dumps(cache, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"Wrote {len(cache)} cached answers to {out.relative_to(config.ROOT)}; "
          "[LEAD] must review all of them before deploy.")


def cmd_ask_eval(args: argparse.Namespace) -> None:
    """Score a running /api/ask against pipeline/tests/ask_eval.yaml."""
    from flamesense import config
    from flamesense.ask_eval import run_eval

    report = run_eval(args.url, config.ROOT / "pipeline" / "tests" / "ask_eval.yaml")
    ok = True
    for cat, r in report.items():
        rate = "n/a" if r["rate"] is None else f"{r['rate']:.0%}"
        print(f"{cat:13s} {rate:>5s} (target {r['target']:.0%}; scored {r['scored']}, unscored {r['unscored']})"
              f" {'PASS' if r['pass'] else 'FAIL'}")
        ok = ok and r["pass"]
    sys.exit(0 if ok else 1)


def cmd_readiness(args: argparse.Namespace) -> None:
    """Print which human inputs the demo still needs."""
    from flamesense.readiness import readiness

    items = readiness()
    for it in items:
        mark = "OK  " if it.ok else "TODO"
        print(f"{mark} {it.name:26s} {it.detail}")
        if not it.ok:
            print(f"     -> {it.action}")
    done = sum(it.ok for it in items)
    print(f"\n{done}/{len(items)} ready")


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
    ask_cache = sub.add_parser("ask-cache", help="Cache answers for suggested questions")
    ask_cache.add_argument("--url", default="http://localhost:8788", help="Base URL of /api/ask")
    ask_eval = sub.add_parser("ask-eval", help="Score /api/ask against ask_eval.yaml")
    ask_eval.add_argument("--url", default="http://localhost:8788", help="Base URL of /api/ask")
    sub.add_parser("readiness", help="List missing human inputs for the demo")
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
        "ask-eval": cmd_ask_eval,
        "readiness": cmd_readiness,
        "all": cmd_all,
    }

    commands[args.command](args)


if __name__ == "__main__":
    sys.exit(main() or 0)
