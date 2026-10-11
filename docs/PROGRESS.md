# FlameSense — Progress Log

Updated at the end of every phase.

---

## Phase 1 — Repository scaffold
- **Date:** 2026-10-11
- **What was built:**
  - Full repository scaffold per PLAN.md §2.3.
  - Python package `flamesense` (pyproject.toml, src layout, CLI stubs for all commands in §5). Virtualenv created in `pipeline/.venv`, dependencies installed, requirements locked in `pipeline/requirements.lock`.
  - Flutter web project in `app/` with required dependencies (`flutter_riverpod`, `go_router`, `fl_chart`, `flutter_math_fork`, `shared_preferences`, `url_launcher`, `http`, `intl`, `flutter_localizations`), l10n configuration (`l10n.yaml`, initial `app_en.arb`, `app_bn.arb`), and placeholder modules.
  - TypeScript functions project in `functions/` with Cloudflare worker types, vitest, tsconfig, and stub `api/ask.ts` returning 501.
  - Cloudflare deployment configuration `wrangler.toml` and `.dev.vars.example`.
  - Build and audit helper scripts (`scripts/sync_assets.sh`, `scripts/build_all.sh`, `scripts/check_secrets.sh`).
  - Project documentation (`README.md`, `LICENSE`, `docs/PROGRESS.md`, `docs/QUESTIONS.md`).
- **Files changed:**
  - `.gitignore`, `.dev.vars.example`, `LICENSE`, `README.md`, `wrangler.toml`
  - `scripts/sync_assets.sh`, `scripts/build_all.sh`, `scripts/check_secrets.sh`
  - `pipeline/*` (pyproject.toml, requirements.txt, requirements.lock, sources.yaml, src/flamesense/*, tests/*)
  - `functions/*` (package.json, tsconfig.json, vitest.config.ts, api/ask.ts, lib/*, test/*)
  - `app/*` (pubspec.yaml, l10n.yaml, analysis_options.yaml, lib/*, test/*, web/*, assets/*)
  - `docs/AUDIT.md`, `docs/PROGRESS.md`
- **Checks run & results:**
  - `source pipeline/.venv/bin/activate && pytest pipeline/tests -q`: PASSED (1 passed).
  - `cd app && flutter analyze`: PASSED ("No issues found!").
  - `cd app && flutter test`: PASSED (1 passed).
  - `npm --prefix functions run typecheck`: PASSED (0 errors).
  - `npm --prefix functions test`: PASSED (1 passed).
  - `bash scripts/check_secrets.sh`: PASSED ("No secrets found. OK.").
  - Pipeline CLI commands smoke-tested: `inspect`, `all` executed cleanly with Phase stubs.
- **Open questions:**
  - None for Phase 1.

---

## Phase 2 — Ingest + validate
- **Date:** 2026-10-11
- **What was built:**
  - `ingest/registry.py` (sources.yaml → `data/interim/runs_raw.parquet`), `ingest/adapters/manual_csv.py` (manual CSV adapter with schema type-casting), `schema.py` (canonical schema + `validate`), CLI `ingest`/`validate` commands.
- **Checks run & results:**
  - `pytest pipeline/tests -q`: PASSED (schema + smoke tests).
- **Commit:** `Add Phase 2 ingestion and schema checks` (79fb1e4)

---

## Phase 3 — Clean, features, data report
- **Date:** 2026-10-11
- **What was built:**
  - `clean.py`: strip whitespace + lowercase enums; drop exact duplicate measurements (same source, fuel, O₂, pressure, flow, gravity, spread rate) keeping first; flag `quality_flag='suspect'` (never delete) for spread rate > 99.5th percentile × 3; writes `data/processed/runs.parquet`.
  - `features.py`: derived columns `log10_gravity`, `o2_partial_kpa`, `log10_flow`, `areal_density_kg_m2` with the exact §3.1 formulas; one-hot `fuel_class__*`, `flow_direction__*`, `diluent__*` for values present in the data; writes `runs_features.parquet`.
  - `report.py`: `docs/DATA_REPORT.md` with 5 code-computed key facts, summary, per-experiment/platform/fuel-class tables, per-column missingness %, numeric min/median/max, and 5 charts in `docs/img/` using DESIGN.md §10 colors (light theme).
  - CLI `clean`/`features`/`report` wired to the real implementations.
- **Files changed:**
  - `pipeline/src/flamesense/clean.py`, `features.py`, `report.py`, `cli.py`
  - `pipeline/tests/test_phase3.py` (21 tests total)
  - `docs/DATA_REPORT.md`, `docs/img/chart_*.png` (generated)
- **Checks run & results:**
  - `python -m flamesense.cli clean|features|report`: PASSED (0-row dataset — no manual CSVs ingested yet, handled gracefully).
  - `python -m flamesense.cli all`: PASSED end-to-end (ingest → validate → clean → features → report).
  - `pytest pipeline/tests -q`: PASSED (21 passed, incl. 3 hand-computed derived-formula rows + clean/report tests).
  - `ruff check` on Phase 3 files: PASSED (remaining ruff findings are pre-existing Phase 2 files; untouched per CLAUDE.md rule 5).
  - Charts verified to render real content from the fixture dataset (non-white pixel check).
- **Notes:**
  - No `data/manual/*.csv` yet, so processed data is empty; commands regenerate automatically once `[SCI]`/`[LEAD]` adds data.
  - `IMPOSSIBLE_PREDICATES` in `clean.py` is empty until QUESTIONS.md answers arrive (rule 6).
  - AUDIT.md §2 "Suspect rows flagged, not deleted" implemented; "excluded from training" completes in Phase 5.
- **Open questions:**
  - None for Phase 3.
