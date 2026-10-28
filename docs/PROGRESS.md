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

---

## Phase 7 — Predictor engine in Dart
- **Date:** 2026-10-27
- **What was built:**
  - `domain/tree_model.dart` (flat typed arrays, `raw`/`predict`, length/NaN checks, logit
    calibration, expm1, identity), `gravity.dart` (constants from the NASA fact sheet, log
    slider mapping, 2% snap labels, gravity class), `lab_input.dart` (URL query round-trip),
    `predictor.dart` (feature vector from feature_spec order with the §3.1 formulas, quantile
    sort + `quantilesReordered`, unavailable tasks → null + warnings, outside-range, low
    support, partial gravity, effective airflow), `support_index.dart` (kNN on standardized
    features, levels), `physics_model.dart` (port of physics.py; unavailable while any value is
    null or unsigned in release), `sensitivity.dart` (±10% of slider range, top 4),
    `materials.dart`, `slider_scale.dart` (moved from widgets), Riverpod providers in
    `domain/providers.dart`.
  - `pipeline/tests/make_app_fixtures.py` builds `app/test/fixtures/fixture_*.json` by training on
    the synthetic fixture rows (tests only; physics fixture values are labelled not real).
- **Checks run & results:**
  - `flutter test`: 25 passed, 1 skipped (O₂ monotonicity sweep — constraints off until Q-2).
    Parity |Dart − LightGBM| < 1e-9 on 4 models × 60 rows; 1,000 predictions < 200 ms on the VM;
    1,000-point quantile sweep never crosses; real empty assets → no numbers shown.
  - `flutter analyze`: No issues found. `pytest pipeline/tests -q`: 50 passed.
- **AUDIT ticked:** §4 parity, quantile sweep, derived features.
- **Open questions:** none new.

---

## Phase 8 — Home and the Gravity Twin hero
- **Date:** 2026-10-27
- **What was built:**
  - `widgets/flame_twin/flame_painter.dart`: DESIGN §9.20 exactly (b = s^1.4, 96-point outline,
    flicker only when b > 0.25 and motion allowed, colour lerp space → Earth, glow, inner core,
    soot halo for b > 0.5, fuel sample, ignition scale/fade). `flame_twin.dart`: 4 s loop that
    pauses offstage (TickerMode), never ticks in microgravity (steady flame), static in reduced motion.
  - Home (§11.1): headline/subhead/CTAs ("Open the Fire Lab" → `/lab?g=<current>`, tour →
    `/?tour=1`), Chamber window with Earth + your-gravity flames, heroSeam, readouts (buoyant
    airflow only when physics is enabled; predicted spread only when the spread model exists),
    gravity slider with ISS/Moon/Mars/Earth snaps and microg→ember track, ignition once per
    session, data sentence from app_meta (honest pending sentence while 0 runs, Q-5),
    "Where to go next" list with Missions first, footer (disclaimer, credits, not affiliated).
  - Reusable `GravitySlider`, `SiteFooter`; 404 drifting flame (±6 px / 6 s).
  - Note: DESIGN §11.1 specifies one data sentence; PLAN step 2's "3 facts" strip is the same
    sentence (no extra un-specified facts invented).
- **Checks run & results:** `flutter test` 34 passed / 1 skipped; `flutter analyze` clean;
  hero at 360/768/1440 without overflow; snaps; reduced motion → controller idle; ignition
  once; CTA URL `/lab?g=0.3783`. Browser preview of the release build checked visually.
  60 fps DevTools check is a [LEAD] manual step (the painter repaints only the hero via
  RepaintBoundary).

---

## Phase 9 — Data Explorer
- **Date:** 2026-10-27
- **What was built:** pure filter/sort/CSV logic (`explore_filters.dart`), Riverpod filter/sort
  providers, filter chips (experiment multi-select, platform, material type, gravity class,
  O₂ and pressure range dialogs, 4 quality toggles; flagged off by default), compact Filters
  button + sheet with active count, result count, Clear, Download CSV (UTF-8 BOM, every column
  incl. `source_citation`, `flamesense_runs_<yyyyMMdd>.csv`, via package:web Blob). Charts
  (fl_chart): spread vs O₂ (log y), burning vs airflow (log x, deterministic jitter by run-id
  hash), runs per experiment (palette ≤ 6 then Other); gravity encoded by colour AND shape
  (filled circle / diamond / hollow circle per DESIGN §10.2 — DESIGN wins over the plan's
  "shape by experiment"); tooltips with units; tap → run detail; chart summaries for screen
  readers (counts only, no invented interpretation). Virtualized sortable table with sticky
  header, pinned Run column, horizontal scroll on narrow widths. Run detail: dialog ≥ 1024,
  page below, every non-null field with units, quality, citation, Open source (new tab),
  Load these conditions in the Fire Lab; unknown id → not found. States: first-frame
  skeleton, no data (Q-5), empty filters, one-experiment notice.
- **Checks:** `flutter test` 45 passed / 1 skipped; analyze clean. Filtering 5,000 runs < 100 ms.
  Found and fixed in tests: async asset loading inside `testWidgets` must use `tester.runAsync`.

---

## Phase 10 — Fire Lab
- **Date:** 2026-10-27
- **What was built:** Conditions panel (material presets from the runs → class/thickness/
  density; Custom unlocks a fuel-class switch and thickness/density sliders; O₂ % with "Earth
  air 21%" marker, pressure with "Sea level 101.3 kPa" marker, log airflow, gravity with snaps,
  airflow direction, Reset, Copy link + toast). No "ISS cabin" or "Typical ISS ventilation"
  marker: DESIGN requires a sourced value, none supplied yet. Chamber window with one flame,
  gravity label, effective airflow with forced/buoyant caption (forced-only caption while
  physics is off). Prediction panel: support badge, SustainGauge (ramp colour, mValue tween,
  unavailable state with info), SpreadBand (log axis from measured spread range), PhysicsCard
  (4 states), SensitivityList, all notices (quantile notice debug-only). Compare with Earth:
  delta line + two columns (Earth column emberTint/ember), stacking when the panel is
  < 560 px. Layouts: 360|flex|400 ≥ 1280, 340 + stacked 1024–1279, compact order flame →
  prediction → conditions with a sticky result bar. URL ↔ state: queries applied on load /
  back-forward; changes reflected with `SystemNavigator.routeInformationUpdated(replace: true)`.
- **Checks:** `flutter test` 60 passed / 1 skipped (Lab at 360/768/1280/1920 × light/dark
  without overflow; O₂ change; outside-range; query + partial-g; compare; copy link URL;
  numeric field error; empty-data unavailable state). Browser preview verified.

---

## Phase 11 — Flammability map
- **Date:** 2026-10-27
- **What was built:** pure `map_grid.dart` (64 × 48 cells, x = airflow log1p over the slider
  range, y = O₂ linear, memoized by (fuel class, thickness, density, pressure, gravity,
  direction); marching-squares 50% contour), `heatmap_painter.dart` (ramp §10.4, 45° hatch
  on low-support cells §10.5, contour with halo and "50%" label §10.6, run overlay 7 px
  filled = kept burning / hollow = went out with surface outline, pinned cell focus-ring
  outline, mission pins/markers for Phase 11B), map view with axes, hover, click/tap to pin,
  arrow-key cell navigation and a screen-reader summary, inspector (O₂, airflow, %, support,
  Open in Fire Lab), legend, controls (material type, pressure, gravity incl. Custom, airflow
  direction, overlay chips), compact settings sheet, Moon/Mars gap notice (only when the
  gravity-class run count is 0, so the "no tests" wording is never false), unavailable
  EmptyState over the runs scatter, first-draw skeleton, `/map?fuel=&p=&g=&dir=`.
- **Checks:** `flutter test` (phase 11: 6 passed; grid computed in < 250 ms on the VM,
  deterministic; contour on a synthetic grid; empty state; Moon notice; 360 px). Visual QA in
  Chrome on a scratch build with fixture data swapped into the served assets (repo untouched).

---

## Phase 11B — Missions, Experiment Wishlist, Mission Fire Brief
- **Date:** 2026-10-28
- **Human input missing:** `data/manual/missions.json` — the agent wrote the §3.10 template with
  empty sources (Q-7); everything is hidden in release until sourced.
- **What was built:** `pipeline/src/flamesense/missions.py` (validation + export, wired into
  `export`), `domain/missions.dart` (worst case over the airflow sweep × flow directions,
  verdicts, gravity-class run counts, release visibility), `domain/wishlist.dart` (13 × 5 × 12 ×
  fuel-class grid, score = 0.45u + 0.45n + 0.10w, greedy selection with standardized distance
  ≥ 0.75, reasons, planned-point percentile exactly as computed), `domain/brief.dart` (A4 PDF,
  English, static Archivo Regular/Bold instanced from the OFL variable font by
  `scripts/make_pdf_fonts.py`, footer on every page, disclaimer, citations), Missions page,
  Mission detail (materials table → Lab, data-gap notice, wishlist panel with mini map pins and
  planned squares, CSV test matrix, PDF brief), Home "Plan for a mission" row (Phase 8).
- **Checks:** `pytest` 54 passed; `flutter test` 74 passed / 1 skipped (verdict thresholds,
  worst case = max over sweep, 5 diverse deterministic picks, exact score formula, planned
  percentile, unsourced hidden in release, PDF builds with the mission name, detail page,
  unknown id → 404); analyze clean.
- **Open questions:** Q-7, Q-8.

---

## Phase 12 — Corpus, Ask API, Ask page
- **Date:** 2026-10-28
- **Human input missing:** `data/corpus_raw/corpus_meta.csv` and documents; `.dev.vars` key.
  The `corpus` command writes an empty corpus, so Ask returns the honest not-grounded answer
  (no LLM call) until documents are added. `ask_cache.json` cannot be generated without the key
  and a corpus (`python -m flamesense.cli ask-cache --url http://localhost:8788`); suggested
  questions still work live, and show "Saved answer" once cached.
- **What was built:** `corpus.py` (PDF per page / HTML stripped, ≥ 200-char pages,
  ≤ 1,200-char sentence chunks with 150-char overlap, `D<n>#<seq>`, license_note required,
  8 MB cap), `ask_cache.py` + CLI (`corpus`, `ask-cache --url`). Pages Function: `validate.ts`,
  `ratelimit.ts` (30/h/IP, 2000/day, KV optional locally), `bm25.ts` (k1 1.2, b 0.75, top 6,
  15% cut-off, lazy module index), `prompt.ts` (system prompt verbatim), `anthropic.ts` (raw
  fetch, 25 s timeout, Q-9 adjustments), `answer.ts` (fence stripping, citation filtering,
  not-found template), `handler.ts` (CORS allow-list + same origin, 403/405/400/429/502/500,
  logs status/latency/tokens only). App: Ask client with every error mapped to §12 copy,
  controller (cached suggestions instant, last 5 in memory only), suggested questions, input
  with counter (Enter sends, Shift+Enter newline), answer card with inline citation chips that
  scroll to and pulse the source card, sources, copy, not-grounded related-question button,
  waiting skeleton, error notices with retry, earlier questions, AI footnote.
- **Layout change (Q-10):** function tooling/tests moved to `functions-dev/`.
- **Checks:** `npm --prefix functions test` 11 passed, typecheck clean; `pytest` 58 passed;
  `flutter test` 78 passed / 1 skipped; analyze clean; `wrangler pages dev` probe (valid → 200
  not-grounded, empty/501/non-JSON → 400, GET → 405, unknown origin → 403, SPA routes 200,
  `lib/` not routed); `scripts/check_secrets.sh` OK (now also scans git history for real keys).

---

## Phase 13 — Earth lessons, Methods, About, 404, Judge Tour
- **Date:** 2026-10-28
- **Human inputs missing:** `lessons_draft.md`, `usability.csv` (Q-11). No lesson science written.
- **What was built:** `lessons.py` (draft → lessons.json, approved only with reviewer + source;
  usability.csv → usability.json, wired into `export`). Earth page (two-half lesson rows, sources,
  footer notice, empty state, drafts hidden in release). Methods (sticky ToC / compact dropdown,
  `?s=` anchors; data sources table computed from runs, quality-flag table; predictions with the
  oxygen-constraint sentence only when the model is constrained; metrics tables with plain-language
  meanings + calibration chart; physics equations in flutter_math_fork identical to
  PHYSICS_SPEC.md with symbol/unit tables, parameter table, sign-off line; support; limitations;
  usability table or pending; honesty). About (what, team per Q-6, challenge, GitHub, AI use,
  licenses + LicensePage, data credits from runs, not-affiliated, privacy, contact via GitHub
  issues, version/data version/build date). 404 with drifting flame (Phase 8). Judge Tour:
  target registry, 8 steps, controller, overlay with spotlight cutout (rLg, 8 px padding, 2 px
  microg border), caption card placed right/below/above with step counter and Back/Next/Finish/
  Exit, →/←/Esc, focus on the card, `?tour=1` auto-start, no animation in reduced motion.
- **Checks:** `flutter test` 86 passed / 1 skipped; `pytest` 60 passed; analyze clean; tour
  verified in Chrome on the fixture QA build.
