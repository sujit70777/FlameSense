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

---

## Phase 4 — Physics reference model
- **Date:** 2026-10-11
- **What was built:**
  - `data/manual/physics_params.json`: §3.7 template with all science values null and sources empty — nothing invented; `[SCI]` fills the numbers.
  - `physics.py`: `load_params()`, `validate_params()`, `spread_rate_mm_s(row)` (de Ris 1969 thin-fuel, returns `None` for any missing param/invalid domain — never a guess), `buoyant_velocity_m_s(g, params)` and `effective_flow_mm_s()` (U_eff = √(U_forced² + U_b²), explanation only), `applicability(row) → ok | not_applicable | near_extinction_warning`, and flame-temperature linear interpolation in O₂.
  - `physics-check` CLI: prints param validation, signed-off status, per-row applicability counts, physics MAE vs observed, writes `docs/img/physics_vs_observed.png` (log-log, 1:1 line), and copies validated params to `pipeline/out/app_assets/physics_params.json` (only when validation passes).
  - `docs/PHYSICS_SPEC.md`: equations in LaTeX, parameter table (values + sources, pending SCI), applicability rules, limitation text, unchecked sign-off line.
- **Files changed:**
  - `pipeline/src/flamesense/physics.py`, `cli.py`, `pipeline/tests/test_physics.py` (17 tests)
  - `data/manual/physics_params.json`, `docs/PHYSICS_SPEC.md`, `docs/QUESTIONS.md` (Q-1)
- **Checks run & results:**
  - `pytest pipeline/tests -q`: PASSED (38 passed, incl. 17 physics tests with hand-computed de Ris + buoyant-velocity values).
  - `python -m flamesense.cli physics-check`: runs; reports 12 missing parameters and not-signed-off status; exits 1 (feature unavailable until SCI fills params) — as designed.
  - Comparison + chart path verified with filled fixture params + fixture data (MAE 0.755 mm/s over 3 applicable rows; log-log chart renders).
  - `ruff`: clean on all Phase 4 files.
- **Pending [SCI]/[LEAD] (human):**
  - Fill all 12 parameter values + sources in `data/manual/physics_params.json`, then sign off in `docs/PHYSICS_SPEC.md` (`signed_off_by_sci: true`).
  - Confirm `NEAR_EXTINCTION_*` thresholds (QUESTIONS.md Q-1).
- **Open questions:**
  - Q-1 (near-extinction thresholds) — agent-chosen, pending SCI.

---

## Plan update (2026-10-27)
- Applied the revised PLAN/CLAUDE.md to finished phases: `[SCI]` → `[LEAD]`,
  `signed_off_by_sci` → `signed_off_by_lead` in `physics.py`, `cli.py`, tests,
  `physics_params.json`, `PHYSICS_SPEC.md` (sign-off line now
  "Checked against sources by the lead (date)").
- **Data status:** `data/raw/` and `data/manual/` contain no run data, and there is no
  corpus, `missions.json`, `lessons_draft.md`, `DATA_SOURCES.md`, `CHALLENGE_REQUIREMENTS.md`
  or `usability.csv` yet ([LEAD] Phase 0 inputs). Every later phase is built to run honestly
  on 0 rows (unavailable/empty states) and picks up real data on the next `cli all`.

---

## Phase 5 — Train, evaluate, export models
- **Date:** 2026-10-27
- **What was built:**
  - `train.py`: task row selection (sustain = rows with `ignited`; spread = rate > 0, solid
    fuels), feature selection (< 40% missing, one-hots present), no imputation (dropped-row
    count logged), availability thresholds (≥ 40 rows, ≥ 8 per class), GroupKFold(min(5, groups))
    with (Stratified)KFold(5) fallback + warning when groups < 3, the exact PLAN LightGBM params,
    OOF predictions, final models on all rows, logistic calibration of OOF raw scores.
  - `evaluate.py` → `metrics.json` (§3.6, nulls instead of NaN, `available`/`reason` added);
    `model_card.py` → `docs/MODEL_CARD.md` (honest "weak metrics" wording when weak) and
    `docs/img/calibration.png`, `docs/img/spread_pred_vs_obs.png` (only for trained tasks).
  - `export.py`: LightGBM `dump_model()` → `flamesense-trees-v1` (asserts numeric `<=` splits
    only), pure-Python `eval_tree_model`, `feature_spec.json` (+ top-level `inputs`, Q-3),
    `runs.json` (6 significant digits), `app_meta.json`, `support_index.json`,
    `parity_fixtures.json` (50 random + 10 edge rows per model, expected values from
    LightGBM's own predict), placeholder model files for unavailable tasks, copies
    `physics_params.json`.
  - `support.py`: standardized kNN support index with leave-one-out p50/p95.
  - CLI `train`, `export`, `evaluate`; `config.ARTIFACTS`.
- **Files changed:** `pipeline/src/flamesense/{train,export,evaluate,support,model_card,cli,config}.py`,
  `pipeline/tests/test_phase5.py`, `pipeline/tests/fixtures/{__init__,fixture_synthetic}.py`,
  `docs/MODEL_CARD.md`, `docs/QUESTIONS.md`, `app/assets/data/*.json`, `pipeline/out/app_assets/*.json`.
- **Checks run & results:**
  - `python -m flamesense.cli all`: PASSED end to end on the real (empty) data; both tasks
    report "Only 0 usable row(s); at least 40 are required."; `metrics.json` has no NaN.
  - `pytest pipeline/tests -q`: PASSED (50 passed). Parity |python − LightGBM| < 1e-9 on all
    4 models × 60 rows, using synthetic fixture rows (tests only).
  - `ruff check pipeline/src pipeline/tests/test_phase5.py pipeline/tests/fixtures`: clean.
  - `scripts/sync_assets.sh`: copied 11 files to `app/assets/data/`.
- **Environment note:** LightGBM needed `brew install libomp` on this Mac.
- **Open questions:** Q-2 (monotone signs, pending LEAD), Q-3 (slider limits/defaults),
  Q-4 (no monotone constraints for quantile objective).

---

## Phase 6 — Flutter foundation
- **Date:** 2026-10-27
- **What was built:**
  - Bundled variable fonts `Archivo[wdth,wght].ttf`, `NotoSansBengali[wdth,wght].ttf` with OFL
    texts in `app/assets/fonts/LICENSES/`, registered with `LicenseRegistry`.
  - Theme from DESIGN.md §14: `tokens.dart` (+ sizes/durations used by widgets),
    `fs_theme_ext.dart`, `typography.dart`, `theme.dart`, `colors.dart` (flame/brand/shadow hexes).
  - Settings (theme mode + locale) persisted under `fs.theme` / `fs.locale`.
  - 525-key `app_en.arb` / `app_bn.arb` generated from `app/tool/l10n_source.py` (single source
    so keys/placeholders never diverge); every Bangla value marked `bn-pending`.
  - go_router: StatefulShellRoute with 9 branches, `/missions/:missionId`, `/explore/run/:runId`,
    error → NotFound, debug-only `/dev/gallery`, path URL strategy, per-route document titles.
  - Responsive shell: rail 248/80, top bar (tour, theme cycle with right-click menu, EN|বাং),
    compact top bar ⋯ menu + bottom nav Home/Missions/Lab/Map/More with a sheet.
  - `AssetRepository` + typed models for every §3.2 file; global loading and error screens
    (error names the file). Optional files (lessons, missions, ask cache) are loaded only if the
    asset manifest lists them — on the web a missing file returns index.html (found in browser QA).
  - Shared widgets §9: FsButton, FsIconButton, FsChip, GravityChip, FsPanel, MetricReadout,
    UnitValue, FsSlider (custom track: linear/log/log1p, snaps with 2% magnetism, markers,
    validated number field, ←/→, Shift×10, Home/End, slider semantics), FsSegmented,
    DataSupportBadge, CitationChip, FsTooltip, SectionHeader, PageHeader, EmptyState,
    ErrorState, SkeletonBlock, InlineNotice, FsDialog, FsSheet, FsTabBar, toast, FsFocusRing,
    BrandMark/Lockup, GridBackground, ChamberWindow, FsPage.
  - Web shell: `index.html` (title, description, OG/Twitter, theme-color for both schemes,
    noscript, inline splash that follows the saved/system theme), `flutter_bootstrap.js` as
    specified, `manifest.json`, favicons and icons rendered from the brand mark
    (`scripts/make_icons.py`). `SemanticsBinding.instance.ensureSemantics()` in `main()`.
  - Browser-only actions behind a conditional import (`core/platform/browser*.dart`).
- **Checks run & results:**
  - `flutter analyze`: No issues found.
  - `flutter test`: 10 passed (theme persistence, locale switch + restore, 404, every section
    route reachable, compact bottom nav, missing-asset error screen, all shared widgets at 360 px
    in both themes with real fonts, prefs keys).
  - `flutter build web --release --no-web-resources-cdn`: built; previewed in Chrome via
    `scripts/serve_spa.py`: shell renders with Archivo and grid; `/dev/gallery` → Not found in
    release. Fixed in QA: optional-asset SPA fallback; buttons stretching inside Wrap; slider
    semantics needed increased/decreased values.
- **Open questions:** Q-5 (extra copy), Q-6 (team names/contact).
