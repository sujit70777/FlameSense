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

---

## Phase 14 — Responsive, accessibility, Bangla, performance, polish
- **Date:** 2026-10-28
- **Responsive:** `test/phase14_responsive_test.dart` pumps every route (incl. run detail, mission
  detail, 404) at 360/390/768/1024/1280/1440/1920 in both themes, in Bangla at 360/1440, and on the
  real empty data: no overflow anywhere.
- **Accessibility:** contrast table from `scripts/contrast.py` (all text pairs ≥ 4.5:1 in both
  themes; focus ring, markers and badge borders ≥ 3:1; chart axis lines ~2:1, Q-12). Compact hit
  areas ≥ 44 px (chips via `HitTarget`, segmented 44 px tall). Tooltips + labels on every icon
  button (FsIconButton requires them), chart/map/gauge/slider semantics, information never by
  colour alone, reduced motion stops flame flicker, ignition, shimmer, pulses and tour animation.
- **Fonts:** every UI string is covered by Archivo + Noto Sans Bengali except U+207B; added the
  908-byte `FsSymbols.ttf` so no fallback font is fetched at runtime (Q-12).
- **Bangla:** still a first draft (all `bn-pending`); awaiting [TEAM] review. Line height ×1.15,
  no letter spacing, Bangla digits via `intl` already in place.
- **Performance (measured, gzip):** `main.dart.js` 1.28 MB (pdf package now a deferred part),
  CanvasKit (Chromium build) 2.09 MB, all manifest fonts 1.02 MB, data 3 KB → **4.40 MB** worst
  case (≤ 4.5 MB budget). Splash/interactive timing and 60 fps drag need a DevTools run on
  [LEAD]'s laptop (manual AUDIT §8 items).
- **Polish:** per-route document titles, locale-aware 3-significant-digit formatting, no debug
  banner, brand name through l10n. Screenshots of 10 pages × 2 themes × 1440/390 in
  `docs/img/screens/` (real data, so they show the honest empty states) and `app/web/og.png`
  rendered from FlamePainter: `flutter test --update-goldens --dart-define=FS_SCREENSHOTS=true test/screenshots_test.dart`.
| Theme | Foreground | Background | Ratio | Needs | Use | Result |
|---|---|---|---|---|---|---|
| dark | textPrimary | bg | 16.56 | 4.5 | body text | pass |
| dark | textPrimary | surface1 | 15.45 | 4.5 | panel text | pass |
| dark | textPrimary | surface3 | 12.42 | 4.5 | tooltip/hover | pass |
| dark | textSecondary | surface1 | 8.63 | 4.5 | supporting text | pass |
| dark | textSecondary | surface2 | 7.79 | 4.5 | table header | pass |
| dark | textTertiary | bg | 5.59 | 4.5 | captions on bg | pass |
| dark | textTertiary | surface1 | 5.21 | 4.5 | captions in panels | pass |
| dark | textTertiary | surface2 | 4.71 | 4.5 | hint in inputs | pass |
| dark | microg | bg | 8.82 | 4.5 | links | pass |
| dark | microg | surface1 | 8.23 | 4.5 | links in panels | pass |
| dark | microg | microgTint/surface1 | 6.08 | 4.5 | selected chip/nav | pass |
| dark | onMicrog | microgStrong | 5.75 | 4.5 | primary button | pass |
| dark | emberText | surface1 | 7.54 | 4.5 | ember text | pass |
| dark | textPrimary | emberTint/surface1 | 12.44 | 4.5 | Earth column text | pass |
| dark | textPrimary | warnTint/surface1 | 11.51 | 4.5 | warn notice | pass |
| dark | textPrimary | dangerTint/surface1 | 12.79 | 4.5 | danger notice | pass |
| dark | warn | surface1 | 10.86 | 4.5 | unknown count / debug notes | pass |
| dark | onDanger | danger | 7.30 | 4.5 | danger button | pass |
| dark | focusRing | bg | 13.32 | 3.0 | focus ring (UI) | pass |
| dark | focusRing | surface1 | 12.42 | 3.0 | focus ring in panels | pass |
| dark | ember | surface1 | 7.54 | 3.0 | ember dots/markers (UI) | pass |
| dark | partial | surface1 | 8.05 | 3.0 | partial-g markers (UI) | pass |
| dark | success | surface1 | 9.74 | 3.0 | badge border (UI) | pass |
| dark | danger | surface1 | 6.43 | 3.0 | badge border (UI) | pass |
| dark | outlineStrong | surface1 | 2.01 | 3.0 | chart axes (UI) | FAIL |
| light | textPrimary | bg | 16.98 | 4.5 | body text | pass |
| light | textPrimary | surface1 | 18.22 | 4.5 | panel text | pass |
| light | textPrimary | surface3 | 15.34 | 4.5 | tooltip/hover | pass |
| light | textSecondary | surface1 | 8.12 | 4.5 | supporting text | pass |
| light | textSecondary | surface2 | 7.30 | 4.5 | table header | pass |
| light | textTertiary | bg | 4.94 | 4.5 | captions on bg | pass |
| light | textTertiary | surface1 | 5.30 | 4.5 | captions in panels | pass |
| light | textTertiary | surface2 | 4.77 | 4.5 | hint in inputs | pass |
| light | microg | bg | 4.98 | 4.5 | links | pass |
| light | microg | surface1 | 5.34 | 4.5 | links in panels | pass |
| light | microg | microgTint/surface1 | 4.65 | 4.5 | selected chip/nav | pass |
| light | onMicrog | microgStrong | 5.34 | 4.5 | primary button | pass |
| light | emberText | surface1 | 5.42 | 4.5 | ember text | pass |
| light | textPrimary | emberTint/surface1 | 16.22 | 4.5 | Earth column text | pass |
| light | textPrimary | warnTint/surface1 | 16.05 | 4.5 | warn notice | pass |
| light | textPrimary | dangerTint/surface1 | 15.59 | 4.5 | danger notice | pass |
| light | warn | surface1 | 4.73 | 4.5 | unknown count / debug notes | pass |
| light | onDanger | danger | 5.49 | 4.5 | danger button | pass |
| light | focusRing | bg | 4.98 | 3.0 | focus ring (UI) | pass |
| light | focusRing | surface1 | 5.34 | 3.0 | focus ring in panels | pass |
| light | ember | surface1 | 3.50 | 3.0 | ember dots/markers (UI) | pass |
| light | partial | surface1 | 5.34 | 3.0 | partial-g markers (UI) | pass |
| light | success | surface1 | 4.14 | 3.0 | badge border (UI) | pass |
| light | danger | surface1 | 5.49 | 3.0 | badge border (UI) | pass |
| light | outlineStrong | surface1 | 1.86 | 3.0 | chart axes (UI) | FAIL |

2 failing pair(s)

---

## Phase 15 — Testing and full audit
- **Date:** 2026-10-28
- **Test suites:** `pytest` 64 passed (pipeline coverage **88%**, target 70%); `flutter test`
  108 passed / 42 skipped (41 screenshot generators + the Q-2 monotonicity sweep; domain
  coverage **95.4%**, target 90%); `npm --prefix functions test` 11 passed.
- **Smoke:** `scripts/smoke.mjs` (Playwright, installed Chrome) against `wrangler pages dev`:
  every route title + semantics label, Lab keyboard step (21.0% → 21.5%), Ask first suggested
  question, 404, **zero console errors, zero third-party requests** → PASSED.
  `node scripts/smoke.mjs <url> [--expect-citations]` once the corpus exists.
- **Ask eval:** `pipeline/tests/ask_eval.yaml` (10 answerable with `expected_doc` for [LEAD] to
  fill, 5 unanswerable, 5 injections with canaries) + `python -m flamesense.cli ask-eval --url`.
  Not run: needs the API key and corpus.
- **Fixed during the audit:** slider semantics nodes had no accessible name (now
  `container: true`); `functions/` layout broke the Pages build (Q-10); OG/screenshot harness.
  Verified keyboard Tab order and Enter in tests and in Chrome; back/forward restores Lab state.
- **Added:** CI workflow (pipeline + ruff, app format/analyze/test, functions, secrets),
  CONTRIBUTING.md, DATA_UPDATE.md, data-correction issue template, `scripts/contrast.py`.
- **Open Blockers that need [LEAD]/[TEAM] or production** (cannot be done by the agent):
  - Data: real runs in `data/raw/`/`data/manual/` + DATA_SOURCES.md; `validate` on final data;
    5-row unit-conversion spot checks; digitized-row second check.
  - Science: physics params + sign-off; review of every science sentence; lessons approval;
    Q-2 monotone signs; missions sources (Q-7).
  - Ask: corpus + `.dev.vars` key → `ask-cache`, review 12 cached answers, `ask-eval` scores,
    upstream-failure drill.
  - Bangla: native review of all strings (still `bn-pending`).
  - Production: deploy, custom domain, headers, smoke on production, phone on mobile data,
    `v1.0-submission` tag, cross-browser/device checks, DevTools timing and 60 fps.
  - Submission: registrations, videos, NASA page, usability test, rehearsals (PLAYBOOKs).

---

## Phase 16 — Deploy (prepared; deploy itself is a [LEAD] step)
- **Date:** 2026-10-28
- **Done by the agent:** `app/web/_headers` exactly as PLAN step 7, plus `no-cache` for the deferred
  `main.dart.js_*.part.js` chunk and `flutter_service_worker.js` (so a redeploy is never stale);
  `wrangler.toml` carries a commented `[[kv_namespaces]]` block to fill. Release build +
  `scripts/check_secrets.sh` OK. Headers verified on `wrangler pages dev` (nosniff, referrer,
  permissions, SAMEORIGIN; no-cache for index/bootstrap/main; 600 s assets; 86400 s canvaskit);
  smoke test passes with them.
- **Namecheap static deployment (user-directed, 2026-11-02):** added
  `.github/workflows/deploy-namecheap.yml` to build/test and upload `app/build/web/` to the confirmed
  `~/flamesense.ehsanur.com/` document root using the existing SSH secret names. It deliberately
  omits rsync `--delete`; `app/web/.htaccess` provides Flutter route fallback. The user chose a
  static-only deployment, so live `/api/ask` requests remain unavailable; bundled suggested answers
  still work.
- **Checks:** Flutter analyze passed; Flutter tests passed (117 passed, 42 skipped); release web
  build passed and included `.htaccess`; pipeline ruff passed; pipeline tests passed (71); workflow
  YAML parsed and `git diff --check` passed.
- **Not done:** no SSH deployment or production smoke/phone check has run. The Namecheap workflow
  deploys on a push to `main`. The Cloudflare Pages/API deployment steps above remain an alternative
  and were not used for this static-only setup.

---

## Phase 17 — Submission package (agent drafts)
- **Date:** 2026-10-28
- **Written:** final `README.md` (pitch, links, 4 screenshots, features, architecture, data,
  validation, limitations, exact run-locally commands, team, licence, AI disclosure);
  `docs/SUBMISSION.md` (one section per NASA page field); `docs/AI_USAGE.md` (generated by
  `scripts/make_ai_usage.py`: tools, human contributions, the Ask system prompt read from
  `functions/lib/prompt.ts`, all 19 phase prompts verbatim with run dates);
  `docs/VIDEO_SCRIPT.md` + `docs/video/video2.srt` and `video3.srt`; `docs/SLIDES.md` (7 slides);
  templates `docs/DATA_SOURCES.md`, `docs/CHALLENGE_REQUIREMENTS.md`, `docs/MENTOR_NOTES.md`
  (headers only, no invented rows). About page AI-use text now matches AI_USAGE.md (en + bn).
- **[VERIFY] markers:** every number, dataset name, member name and NASA reference that is not
  in the repository yet. The current dataset has 0 runs, so no numbers could be filled.
- **Human steps left (PLAYBOOKs):** demo recordings, videos with burned-in subtitles, NASA page
  fields and photos, submission, rehearsals.
- **Checks:** `flutter analyze` clean; `flutter test` 108 passed / 42 skipped; `pytest` 64 passed;
  ruff clean; functions 11 passed + typecheck; release build; `check_secrets.sh` OK; smoke test
  on `wrangler pages dev` passed.

---

## Prep data import (before Phase 3C)
- **Date:** 2026-11-02
- **What:** the verified prep bundle from `~/flamesense-prep` (PREP_PROMPTS Rounds 1–2) was copied
  in: `data/raw/{psi,ntrs,web,third_party}`, `data/raw/corpus_catalog.csv`, `docs/prep/`
  (statement summary, PSI inventory, feasibility, third-party candidates, data quality, environment)
  and the verified manual CSVs staged in `data/manual/prep/` (not ingested; see its README and
  QUESTIONS Q-14). Large re-downloadable files are gitignored (Q-13); `data/PREP_MANIFEST.csv`
  holds a SHA-256 for every file.

---

## Phase 3B — Video flame tracking
- **Date:** 2026-11-02
- Phase 3B skipped: no calibration file (`data/manual/video_calibration.csv` does not exist).

---

## Phase 3C — Coverage atlas (F19)
- **Date:** 2026-11-02
- **What was built:**
  - `pipeline/src/flamesense/catalog.py` + CLI `catalog` (also in `all`): reads every
    `data/raw/psi/<PSI-id>_<ACRONYM>/` (metadata.json + experimental tables), detects O2,
    pressure, row-level outcome, spread rate and burning rate columns, converts units (O2
    fraction/%, mmHg/atm/bar/kPa/psi), and writes `pipeline/out/app_assets/coverage.json`
    (synced to `app/assets/data/`). `used_in_models` checks the processed runs; `why_not_used` is
    built only from file facts.
  - Result on the real data: 24 investigations, 1,991 table rows, 1,009 placed in the matrix
    (FLEX, CFI, ACME Flame Design, ACME CFI-G). Every flight investigation is microgravity; the
    Moon/Mars row is empty, as the statement says. 3 implausible values skipped (Q-15).
  - App: `data/models/coverage.dart` (optional asset), Explore tabs "What NASA has tested" (first)
    and "Test runs" (`?tab=runs`), `coverage_tab.dart`, `coverage_matrix.dart` (log-scaled microg
    tints, hatched empty cells, tap to filter, pressure band switch), `coverage_table.dart`
    (DOI ghost buttons, "Used in models" + reason). 27 new l10n keys (en + bn-pending).
- **Tests:** `pipeline/tests/test_catalog.py` (6, fixture investigations in
  `pipeline/tests/fixtures/fixture_psi/`); `app/test/phase3c_coverage_test.dart` (5,
  `test/fixtures/fixture_coverage.json`). Updated tour step 6 and 3 Phase 9 tests to
  `/explore?tab=runs`.
- **Checks:** `pytest` 71 passed; ruff clean; `flutter analyze` no issues; `flutter test` 117
  passed / 42 skipped; `npm --prefix functions test` 11 passed.
- **Open questions:** Q-13 (what of data/raw is committed), Q-14 (staged prep CSVs), Q-15 (copy,
  fuel-class vocabulary, matrix placement).

---

## Phase 3D — Investigations hub data (F20), partial
- **Date:** 2026-11-02
- **Built:** `pipeline/src/flamesense/investigations.py` + CLI `investigations` (in `all`) →
  `investigations.json` (24 records: identity, PI, hardware family, fuel state, verbatim objective
  quotes, fuels from the verified curation, conditions incl. airflow/CO2/He/droplet ranges,
  computed varied/constant per table, measurements with evidence, pillar defaults, data
  richness, publications); `app/lib/data/models/investigation.dart`;
  `app/lib/domain/investigation_rank.dart` (PLAN formula, default weights, per-term breakdown);
  `app/lib/domain/compare.dart`.
- **Not done (Q-16):** AI summaries, `/api/compare`, tests (lead will write and run them).
- **Checks:** ruff clean; `flutter analyze` no issues. Tests not run (lead's request).
- **Local SSH deploy (user-directed, 2026-11-02):** added `scripts/deploy.sh` (+ git-ignored
  `scripts/deploy.env`, `scripts/deploy.env.example`), matching the user's other project: checks a
  clean, pushed `main`, runs `scripts/build_all.sh`, rsyncs `app/build/web/` (no `--delete`) to
  `~/flamesense.ehsanur.com/`, then health-checks `/` and `/lab`. `deploy-namecheap.yml` is now
  manual (`workflow_dispatch`) because this repo has no SSH secrets.
- **Data refresh (user-directed, 2026-11-02):** 102 runs now reach the app (was 0) via
  `scripts/stage_manual_runs.py`; mappings in QUESTIONS Q-17. Fixed `clean.strip_and_normalise`
  (stringified booleans/nulls, crashed on an all-null enum column) and `report.gravity_class`
  (parabolic partial-g runs were counted as microgravity). pytest 71 passed, ruff clean.

## Production performance follow-up
- **Date:** 2026-11-03
- **Live measurement:** the first browser load took about 48 seconds to reach the home page.
  CanvasKit WASM transferred 5.43 MB in 37.2 seconds; `main.dart.js` transferred 1.31 MB
  (Brotli) in 35.2 seconds. Fonts were also transferred without compression. Startup then fetched
  the data JSON files serially over about 5.4 seconds.
- **Changes:** `AssetRepository.load()` now fetches all required and manifest-listed optional JSON
  files concurrently. The first deploy showed that LiteSpeed did not compress these large binary
  and data responses from the `.htaccess` output-filter rules. The follow-up build creates gzip
  sidecars for CanvasKit WASM, app JSON, and fonts; `.htaccess` serves those to gzip-capable
  browsers with the correct MIME/encoding and a `Vary` header.
- **Checks:** `flutter analyze` clean; `flutter test` 117 passed / 42 skipped; release web build
  succeeded with `.htaccess` included. Commit `e216c15` deployed; production `/` and `/lab` return
  200. Live headers confirm WASM is served as `application/wasm` + gzip (2,062,566 bytes, down
  from 5,428,806), and `runs.json` as `application/json` + gzip (6,845 bytes, down from 110,811).
  A fresh mobile-sized Chrome context with service workers blocked rendered the home hero in
  22.5 seconds (no network throttling); this is improved from the initial ~48 seconds but remains
  above the 5-second target and still needs real-phone/mobile-data verification.
- **Production smoke:** all page routes, Lab keyboard interaction and 404 passed. Ask did not return
  an answer: the static Namecheap host returns the SPA HTML for `/api/ask`; the API is not deployed
  on this hosting target.

---

## Phase 17C — source_type centralization + data provenance
- **Date:** 2026-11-04
- **What was built:**
  - `schema.py`: `source_type` added to `CANONICAL_COLUMNS` (after `source_url`), `ENUMS["source_type"]` = {nasa_psi, nasa_report, partner_agency, third_party}, added to `REQUIRED`.
  - `ingest/adapters/manual_csv.py`: coerces `source_type` (strip/lower); fallback derivation from `source_id` prefix (`third_party_`/`ntrs_`/`psi_`).
  - `export.py`: `gravity_class()`, `_counts()`, `build_app_meta()` now emits source_type/gravity_class/experiment/model_use count maps; `runs.json` rows tagged with `source_type`; `cli_all` reordered so export runs before report.
  - `report.py`: `DATA_REPORT.md` Summary + source_type/gravity_class/experiment/model_use tables sourced from `app_meta.json` (not recomputed); platforms/groups lines removed.
  - `app/lib/data/models/app_meta.dart`: `sourceType`, `gravityClass`, `experimentCounts`, `modelUse` maps + `sustainRuns`/`spreadRuns`/`bothModelsRuns`/`neitherModelRuns` getters.
  - `app/lib/widgets/data_provenance.dart` (new): per-`source_type` table (type | runs | experiments | source link/citation) + "Download master list (CSV)" of all runs (UTF-8 BOM, every column incl. `source_type`) via `runsToCsv`/`downloadBytes`; Sharma 2024 "NASA co-authored" callout.
  - `app/lib/features/methods/methods_data.dart`: `DataProvenance` wired into the Methods "data" section (DESIGN §11.7 #data).
  - `app/lib/features/explore/{explore_page.dart,filter_bar.dart}`: Explore total now reads `meta.nRuns` from `app_meta.json`; `DataProvenance` wired into the runs tab.
  - `app/lib/l10n/app_en.arb` / `app_bn.arb`: 8 new `prov*` keys (+ `provIntro` with placeholders); regenerated via `flutter gen-l10n`.
- **Exact counts (verified, 123 runs total; 127 raw → 123 cleaned, 4 exact dupes dropped):**
  - `source_type`: nasa_report=92, third_party=31 (nasa_psi=0, partner_agency=0)
  - `gravity_class`: microgravity=97, partial=26, earth=0
  - `model_use`: sustain=42, spread=45, both=6, neither=42
  - Every count in the app now equals `app_meta.json` (AUDIT §15f); Sharma 2024 labelled "NASA co-authored" (third-party, not NASA).
- **Files changed:**
  - `pipeline/src/flamesense/{schema,export,report,cli}.py`, `pipeline/src/flamesense/ingest/adapters/manual_csv.py`
  - `app/lib/data/models/app_meta.dart`, `app/lib/widgets/data_provenance.dart` (new), `app/lib/features/methods/methods_data.dart`, `app/lib/features/explore/{explore_page.dart,filter_bar.dart}`
  - `app/lib/l10n/{app_en.arb,app_bn.arb}` + regenerated `app_localizations*.dart`
  - `app/test/fixtures/{fixture_app_meta.json,fixture_runs.json}` (source_type added); `pipeline/tests/fixtures/{fixture_synthetic.py,fixture_runs.csv}` + `tests/test_phase3.py` column-count expectation 25→26
  - `docs/PROGRESS.md`
- **Checks run & results:**
  - `python -m flamesense.cli validate`: PASSED (127 raw rows, 0 schema errors).
  - `python -m pytest -q`: PASSED (71 passed).
  - `cd app && flutter analyze`: No issues found.
  - `cd app && flutter test`: PASSED (117 passed, 42 skipped).
- **Open questions:** None for this phase.

## Phase 17D — Home hero cleanup + Key findings & gaps (F28)
- **Date:** 2026-11-04
- **What was built (PLAN §1.0 / DESIGN §11.1, §11.1b):**
  - `app/lib/features/home/hero_readout.dart`: removed the predicted spread readout (PLAN §1.0: "No spread-rate readout"). Under each flame only the physics buoyant-airflow readout shows, and only when `physics_params` is signed off (`predictor.physics.buoyantVelocityMmS` returns null otherwise → row hidden).
  - `app/lib/features/home/key_findings_panel.dart` (new): "Key findings & gaps" panel directly under the hero — three `MetricReadout`s (row on desktop, stack on compact) each with a one-sentence explanation and a "See the evidence" ghost link, plus a "Biggest gaps" list of 3 rows (rank, title, sentence, relevance × scarcity score bar, link) and the caption "Numbers are computed from the data on every build." Wired into `home_page.dart` directly under the hero (before the data sentence).
  - `app/lib/data/models/app_meta.dart`: `homeMaxO2MicrogravitySolidsPct`, `homeMapLowCells`, `homeMapTotalCells`, `homeMaterialsOutsideMoonBase`, `homeMaterialsTotal`, `homeTopGaps` (`List<HomeTopGap>`) + JSON parsing.
  - `pipeline/src/flamesense/export.py`: `build_home_key_findings()` computes all values at export — highest O₂ for burning solids in microgravity; low/no-data map cells of the 64×48 total; materials outside the sustain range at the expected Moon-base atmosphere (30% O₂ / ~70 kPa); top 3 gaps ranked by mission relevance × data scarcity. Merged into `app_meta.json` under a `home` key.
  - `app/lib/l10n/app_en.arb` / `app_bn.arb`: 11 new `homeKeyFindings*` keys; regenerated via `flutter gen-l10n`.
  - `app/test/phase7_domain_test.dart`: new guard test "predicted value differs between 1 g and orbit (1e-6 g)" — fails if sustain probability or spread q50 is identical at Earth gravity and ISS orbit.
- **Files changed:**
  - `pipeline/src/flamesense/export.py`
  - `app/lib/data/models/app_meta.dart`, `app/lib/features/home/{home_page.dart,hero_readout.dart,key_findings_panel.dart}` (new)
  - `app/lib/l10n/{app_en.arb,app_bn.arb}` + regenerated `app_localizations*.dart`
  - `app/test/fixtures/fixture_app_meta.json` (home keys added); `app/test/phase7_domain_test.dart` (new test)
  - `docs/PROGRESS.md`
- **Exact counts (computed at export, 123 runs):**
  - `home.maxO2MicrogravitySolidsPct`: 31 (% oxygen)
  - `home.mapLowCells` / `home.mapTotalCells`: 2641 / 3072
  - `home.materialsOutsideMoonBase` / `home.materialsTotal`: 0 / 14 (Moon-base 30% O₂ / 70 kPa is inside the sustain range in this dataset)
  - `home.topGaps`: 3 gaps ranked by relevance × scarcity (high-O₂ solid fire, sparse partial-gravity data, no Earth-gravity baseline)
- **Checks run & results:**
  - `python -m flamesense.cli validate`: PASSED (127 raw rows, 0 schema errors).
  - `python -m pytest -q`: PASSED (71 passed).
  - `cd app && flutter analyze`: No issues found.
  - `cd app && flutter test`: PASSED (118 passed, 42 skipped).
- **Open questions:** None for this phase.


## Phase 17E — Counts audit: one source of truth, provenance per source, no silent drops
- **Date:** 2026-11-11
- **Audit findings (fixed):**
  - Sharma 2024 rows were labelled "(third-party, not NASA)" in `experiment`/`notes` (set by
    `scripts/stage_manual_runs.py`), contradicting PLAN §1.0. Now "(third-party, NASA co-authored)";
    Takahashi 2026 "(third-party, independent of NASA)". Only those two columns changed in
    `data/manual/third_party_runs.csv` (32 rows, verified column-by-column).
  - 4 rows were dropped by dedupe with no record of which. Now logged per row (Q-18).
  - `model_use` buckets overlapped (42 + 45 + 6 + 42 = 135 ≠ 123). Now exclusive buckets that sum to
    123, plus per-model totals.
  - Home gap copy was hard-coded English in `export.py`, and gap 1 was false ("No solid-fire data
    above 23% oxygen" — Saffire V/VI have 6 burning solid runs at 25–31% O₂). Gaps are now ids +
    computed params; copy in l10n (`gap*`).
  - "Materials outside Moon-base range" was 0 of 14 because gravity was not checked and the
    atmosphere was hard-coded (30% / 70 kPa). Now read from `missions.json` `artemis_lunar`
    (34% O₂, 56.5 kPa, 0.1654 g) and checked against the sustain rows: 14 of 14 outside (O₂ and
    gravity). Its link went to `/missions/lunar_base` (no such mission); now `/missions/artemis_lunar`.
  - Methods/About source tables grouped by `source_id`, which ingest sets to `manual` for every row,
    so they showed one source (BASS-II citation, 123 runs). Provenance is now per citation, from
    `app_meta.json` `sources`. `DataProvenance` also recounted runs itself; now reads meta only.
  - Home sentence said "{experiments} NASA experiments" (2 of 10 are third-party); DATA_REPORT said
    "14 fuel classes" (they are materials) and "41 ignited runs" (they are runs with a stated outcome).
  - Report tests read the real `pipeline/out/app_meta.json` with fixture data; `generate_report` now
    takes `meta` explicitly and refuses a meta whose `n_runs` differs from the data.
- **What was built:**
  - `clean.py`: `dropped_row_log()`; CLI writes `data/processed/dropped_rows.csv` and prints each drop.
  - `export.py`: `build_app_meta` adds `rows_ingested`, `rows_dropped`, `dropped_rows`, `sources`
    (type, authorship, citation, url, experiments, runs, merged duplicates), exclusive `model_use`,
    `home.moonBase`; `check_counts()` fails export if any breakdown does not sum to `n_runs`;
    `authorship()` fails strict export for a third-party source with no label (keyed by DOI).
  - `report.py`: key facts and all tables from app_meta; new "Data provenance" section + drop log.
  - App: `SourceProvenance`, `HomeTopGap.id/params` in `app_meta.dart`; `DataProvenance` rewritten
    (per-source table, type counts, master CSV, co-authored note) and now the only source table on
    Methods; About credits from `meta.sources`; `gap_copy.dart`; key-finding values via l10n;
    `MetricReadout` value scales down instead of overflowing.
- **Exact counts (`app/assets/data/app_meta.json`, data_version in file):**
  - Rows ingested 127; dropped as exact duplicates 4 (bassii_t71:GMT216-T26, -T28b, -T29;
    third_party_sharma2024:T1-4); **n_runs 123** = runs.json rows 123 = processed parquet 123.
  - `source_type`: nasa_psi 0, nasa_report 92, partner_agency 0, third_party 31.
  - `gravity_class`: microgravity 97, partial 26, earth 0.
  - `experiment`: BASS-II 67, Takahashi 2026 26, Saffire-II 9, Sharma 2024 5, BASS 4, Saffire-V 3,
    Saffire-VI 3, Saffire-I 2, Saffire-III 2, Saffire-IV 2 (10 experiments, 14 materials).
  - `model_use`: sustain 42, spread 45; exclusive: sustain only 36, spread only 39, both 6, neither 42.
  - `sources`: BASS-II TM 71 (3 merged), Takahashi 2026 26 (independent), Saffire NTRS 20180005168 13,
    Sharma 2024 5 (NASA co-authored, 1 merged), Saffire IV–V ICES-2021-266 5, Saffire VI ICES-2024-365 3.
  - `home`: max O₂ 31%; map low cells 2641 of 3072; materials outside Moon base 14 of 14; gaps:
    high-O₂ solids 0.938 (6 of 97 above 23%, 0 went out, 54.1–72.6 kPa), partial gravity 0.71
    (26 of 123, 0 NASA), Earth baseline 0.7 (0 runs).
- **Files changed:** `scripts/stage_manual_runs.py`, `data/manual/third_party_runs.csv`,
  `pipeline/src/flamesense/{clean,cli,export,report}.py`, `pipeline/tests/{test_app_meta.py (new),
  test_phase3.py,test_phase5.py,test_cli_e2e.py,make_app_fixtures.py}`, `pipeline/out/app_assets/*`,
  `app/assets/data/{app_meta,runs,coverage}.json`, `app/lib/data/models/app_meta.dart`,
  `app/lib/widgets/{data_provenance,metric_readout}.dart`, `app/lib/features/home/{gap_copy (new),
  key_findings_panel,data_sentence}.dart`, `app/lib/features/{methods/methods_data,about/about_page}.dart`,
  `app/lib/l10n/*`, `app/test/{provenance_test.dart (new),fixtures/fixture_app_meta.json}`,
  `docs/{DATA_REPORT,DESIGN,AUDIT,QUESTIONS,PROGRESS}.md`, `docs/img/chart_runs_per_experiment.png`.
- **Checks run & results:**
  - `python -m flamesense.cli all`: exit 0. `python -m flamesense.cli validate`: exit 0 (127 rows, 0 errors).
  - `pytest pipeline/tests -q`: 82 passed. `ruff check pipeline/src`: clean.
  - `flutter analyze`: No issues found. `flutter test`: 123 passed, 42 skipped, 0 failed.
  - `grep -ri fixture app/assets/data`: nothing.
- **Open questions:** Q-18 (keep replicate tests? ingest `source_id` overwrite; Lab gravity range;
  `tour5Body` "NASA plans" wording).

## Phase 17F — Home hero + Key findings & gaps (F28) audit against DESIGN §11.1 / §11.1b
- **Date:** 2026-11-11
- **Audit findings (fixed):**
  - Hero buoyant-airflow row showed with **unsigned** physics in debug/profile builds:
    `PhysicsModel` only requires sign-off in release, and the shipped `physics_params.json` has
    `signed_off_by_lead: false`. `HeroReadout` now requires `signedOffByLead` in every build
    mode. No predicted spread readout exists on Home (confirmed; now tested).
  - Key findings cards showed each number twice (MetricReadout label "31% oxygen" + value "31%";
    "2,641 of 3,072" as both label and value). Now one readout per finding using the DESIGN keys
    `homeKeyFindingsOxygen/MapCells/Materials`, then its explanation and "See the evidence".
    `MetricReadout` skips an empty label. Removed the redundant `homeKeyFindingsOutOf` key; Bangla
    for MapCells/Materials was English "of" (now Bangla, `bn-pending`).
  - Values, gaps (relevance × scarcity) and links were already computed at export in 17E
    (app_meta.json `home`): max O₂ 31%; 2641 of 3072 low/no-data cells; 14 of 14 materials outside at
    the lunar base (→ `/missions/artemis_lunar`); gaps high-O₂ solids 0.938 (→ /map), partial
    gravity 0.71 (→ /map), Earth baseline 0.7 (→ /explore). The map always draws low-support hatching.
- **Tests added:**
  - `app/test/gravity_distinct_test.dart`: Lab compare mode at 1e-6 g vs 1 g — both models must
    return values (no silent skip), values must differ, and the two rendered columns must not show
    the same numbers; Home hero 1 g vs ISS readouts must differ. Mutation-checked: fails when the
    Earth column is computed at the user's gravity.
  - `app/test/phase8_home_test.dart`: unsigned physics → no "Buoyant airflow" and no spread text on
    Home (fixture `fixture_physics_params_unsigned.json`). Mutation-checked: fails without the fix.
- **Files changed:** `app/lib/features/home/{hero_readout,key_findings_panel}.dart`,
  `app/lib/widgets/metric_readout.dart`, `app/lib/l10n/*`, `app/test/{gravity_distinct_test.dart (new),
  phase8_home_test.dart, fixtures/fixture_physics_params_unsigned.json (new)}`,
  `docs/{AUDIT,PROGRESS}.md`.
- **Checks run & results:** `flutter analyze`: No issues found. `flutter test`: 126 passed, 42
  skipped. `python -m flamesense.cli validate`: exit 0. `pytest pipeline/tests -q`: 82 passed.
- **Open questions:** none new (Q-18 still open).

## Phase 17G — Solid-model valid range, Moon-base wording and mission citations
- **Date:** 2026-11-11
- **Built:**
  - `export.solid_valid_range` (pipeline): per input, where NASA saw flames both keep burning and go
    out (overlap of burned and went-out sustain rows). Written to `feature_spec.json` `valid_range`:
    O₂ 0.169–0.221, pressure 100–101.325 kPa, airflow 22–470 mm/s, gravity 1e-6 g. The Home
    Moon-base finding and map low-cell count use the same range (14 of 14 materials outside, inputs
    O₂/pressure/gravity; low/no-data cells 2641 → 2876 of 3072). Rule and choices in Q-19.
  - App: `ValidRange` (`feature_spec.dart`); `Predictor.inValidRange`; sustain and spread return
    null outside it, with one `outsideTestedRange` warning instead of per-input "extrapolation"
    notices. New `OutsideTestedRange` widget ("Outside NASA's tested range" + the range) in the
    Lab summary and notices, Map inspector and page notice (outside cells blank + hatched, no
    contour), mission material table (`Verdict.outsideRange`, row counts, Brief), and wishlist
    (out-of-range candidates and planned points get no score; empty-state copy). Screening (F17) is
    not built (cut in §1.0), so there is nothing to gate there.
  - Wording: `tour5Body` and Moon/Mars mission notes say "likely" / "NASA recommendation"; new
    `MissionSources` panel on every mission detail page (atmosphere source from missions.json; for
    ≥30% O₂ / ≤70.3 kPa missions also the challenge-statement citation and "34% oxygen at 8.2 psia
    (56.5 kPa) is a NASA recommendation (NTRS 20240003211)" with a link); the same lines in the
    Brief PDF. PRESENTATION, SLIDES, SUBMISSION, VIDEO_SCRIPT and the two .srt files no longer say
    "NASA plans".
- **Bug found:** the shipped sustain model trained only at 1e-6 g, so the Lab showed the same
  probability at 1 g as in orbit (17F's test only used fixtures). Gravity in `valid_range` fixes it;
  new real-data test in `gravity_distinct_test.dart` (mutation-checked: fails without the gravity
  check).
- **Tests added:** `pipeline/tests/test_valid_range.py` (5); `app/test/moon_base_outside_test.dart`
  (11, real shipped assets): O₂ 0.30/0.34 × 56.5–70.3 kPa × four gravities × airflows × fuel classes
  → no sustain/spread number; map grids all blank; missions all `outsideRange` with no
  probability; wishlist empty; Lab pages show no gauge or spread band; Artemis page shows no "NN%"
  cell, cites the statement and NTRS 20240003211; no "NASA plans" in English copy. Mutation-checked
  (removing the gate fails 3 domain tests). Fixture generator now writes a documented
  `fixture_training_box` valid range so fixture UI tests keep numbers; updated phase 7/10/11/11B
  tests for the new behaviour. `WishlistPickRow` split out of `wishlist_panel.dart` (200-line rule).
- **Files changed:** `pipeline/src/flamesense/export.py`, `pipeline/tests/{test_valid_range.py (new),
  make_app_fixtures.py}`, `app/lib/{data/models/feature_spec.dart, domain/{predictor,missions,
  wishlist,brief}.dart, core/labels.dart, widgets/outside_tested_range.dart (new), features/lab/
  {prediction_summary,lab_notices}.dart, features/map/{map_grid,heatmap_painter,map_inspector,
  map_page}.dart, features/missions/{materials_table,mission_row,mission_detail_page,wishlist_panel,
  mission_sources (new),wishlist_pick_row (new)}.dart, l10n/*}`, `app/tool/l10n_source.py`,
  `app/assets/data/{feature_spec,app_meta}.json`, `app/test/*`, PRESENTATION.md,
  `docs/{SLIDES,SUBMISSION,VIDEO_SCRIPT,AUDIT,QUESTIONS,PROGRESS}.md`, `docs/video/*.srt`.
- **Checks run & results:** `python -m flamesense.cli validate`: exit 0. `pytest pipeline/tests -q`:
  87 passed. `ruff check pipeline`: clean. `flutter analyze`: No issues found. `flutter test`:
  138 passed, 42 skipped.
- **AUDIT:** ticked §15e "solid model never returns a number outside valid_range" and §15f
  "Mission and Home copy say expected/likely".
- **Open questions:** Q-19 (range rule, spread gating, sweep rule, map-grid mismatch). No rover
  mission exists in `missions.json` ([LEAD] data); rover conditions are covered by the tests.

## Phase 16 — Cloudflare Pages hosting, feature registry, Bangla removed
- **Date:** 2026-11-11
- **Built:**
  - Hosting: Cloudflare Pages + Functions only. `scripts/deploy.sh` rewritten (`--preview` →
    branch `preview`; production from a pushed `main`; wrangler login check; build, secret scan,
    `wrangler pages deploy`, smoke). Namecheap workflow, `deploy.env.example`, `.htaccess` and
    the `.gz` step in `build_all.sh` removed. README "Deploy" section rewritten.
  - API: `functions/api/[[path]].ts` answers JSON 404 for unknown `/api/*`; `handleAsk` returns
    503 `{"error":"unavailable"}` immediately when `ANTHROPIC_API_KEY` is missing.
  - Ask client: any non-JSON reply (SPA HTML) or 404/405/501/503 → new `unavailable` kind with an
    info notice "Free-form questions aren't available right now…" (no retry button); client
    timeout 40 → 30 s (`kAskTimeout`; function gives up on Claude at 25 s).
  - `core/features.dart`: `FeatureRegistry` (missions, ask, earth, coverage) from loaded, valid
    assets; rail, bottom nav, More sheet, Home next-list, key-finding/gap links, tour steps and the
    Explore coverage tab skip disabled features; the shell sends deep links to hidden pages Home.
    Optional assets that fail to parse now disable their feature instead of failing the app.
    Tour step count is dynamic (`TourController.next(total)`).
  - Bangla removed: language toggle widget deleted (top bar, More sheet), locale fixed to `en`
    (stored `fs.locale` ignored), `app_bn.arb` + generated Dart deleted, Noto Sans Bengali font
    dropped, `ask_cache.py` English only (6 answers), readiness Bangla item removed.
  - `scripts/smoke.mjs`: computes features from the deployed assets, expects hidden routes to land
    on Home with no nav entry (guarded by a visible-item check), asserts JSON for
    `/api/ask` POST/GET/bad JSON and an unknown `/api/*`, checks saved + free-form Ask when shown.
- **Tests added:** `app/test/features_registry_test.dart` (8: path rules, shipped data hides Ask
  + Earth, deep links go Home, 6-step tour, compact nav, invalid optional file, HTML from
  `/api/ask` → notice while saved answers work, stalled endpoint ends in an error after
  `kAskTimeout`); vitest: missing key → 503 JSON without a model call, every handler error is
  JSON, catch-all JSON 404. Updated phase 3C/6/12/13/14/15 tests; new fixtures
  `fixture_lessons_approved.json`, `fixture_invalid_json.json`.
- **Checks run & results:** `flutter analyze`: No issues found. `flutter test`: 145 passed, 42
  skipped. `npm --prefix functions test`: 14 passed; typecheck clean. `pytest pipeline/tests -q`:
  87 passed. `ruff check pipeline`: clean. `flutter build web --release --no-web-resources-cdn`: ok.
  `scripts/check_secrets.sh`: OK. `node scripts/smoke.mjs http://localhost:8788` against
  `npx wrangler pages dev app/build/web` (no API key): **passed, 0 console errors**.
- **Not done:** preview/production deploy and production smoke. Wrangler is not logged in; the
  lead must run the steps in README "Deploy" (Q-20).
- **Open questions:** Q-20.

## Event-day hotfix — production redeploy (2026-11-13)
- **Found:** flamesense.ehsanur.com (LiteSpeed/Namecheap) still served the 2 Nov build (`e216c15`);
  Phases 17E–17G and 16 were never live. Cloudflare move not done (wrangler not logged in, Q-20).
- **Done:** rebuilt (`scripts/build_all.sh`, only timestamps changed; counts unchanged, 123 runs),
  server backup `<REMOTE_PATH>_backup_20261102`, rsync upload (no delete). Restored `app/web/.htaccess`
  for this host with two fixes: `/data` deep link returned 403 (clashed with the `data/` folder),
  and `.js` added to the precompressed-gzip rules. `.gz` copies created in `app/build/web` by hand
  (`gzip -9 -k` on wasm/js/json/ttf/otf); canvaskit.wasm 7.3 MB → 2.9 MB on the wire.
- **Checks:** flutter analyze clean; flutter test 146 passed / 42 skipped; pytest 87 passed; vitest 14
  passed; validate exit 0; secret scan OK. Live: `/`, `/data`, `/methods`, `/missions`, `/map`, `/lab`
  render, 0 console errors, 0 failed requests; live `app_meta.json` git_sha `4453ed6`.
- **Note:** `scripts/smoke.mjs` waits for `networkidle` and times out on this host's first load (~20 s
  cold from the test machine); pages themselves are fine.

---

## Post-16 fixes: map zoom + challenge resources (2026-11-13)
- **Map:** O2 and airflow axes now span the solid valid range (`mapAxes()` in
  `app/lib/features/map/map_grid.dart`), so in-range conditions colour the whole grid instead
  of ~21 %. Used by the grid, axis labels and wishlist markers. Test in `phase11_map_test.dart`.
- **Lessons (F23):** `data/manual/lessons_draft.md` drafts L1–L6 (Apollo 1, Apollo 13, Mir,
  three spinoffs), each restating its saved challenge-resource page. All `status: draft` —
  [LEAD] must review and approve; drafts stay hidden in release. `lessons.json` regenerated.
  Earth copy: "In orbit" → "In spaceflight" (Apollo 1/13 were not in orbit).
- **About:** "Why fire safety in space matters" section with Apollo 1 / 13 / Mir links.
- **Ask corpus:** `data/corpus_raw/corpus_meta.csv` built from `data/raw/corpus_catalog.csv`
  (68 docs; ScienceCasts video and NTRS 20240003211 have no file). `corpus_chunks.json`:
  3,906 chunks, 4.0 MB. `ask_cache.json` still needs [LEAD] with the API key.
- **Coverage:** `catalog.why_not` names non-solid fuels (FLEX droplet, ACME CFI-G gas jet)
  instead of "not ingested yet". They were already in the matrix.
- **Tests:** registry/Earth tests serve `fixture_empty_lessons.json` for the release view;
  new test: shipped lessons are hidden in release until approved.
- **Checks:** `flutter analyze` no issues; `flutter test` 147 passed; `pytest` 87 passed;
  `ruff` clean.

## Ask on Gemini free tier + Namecheap deploy script (2026-11-13)
- **Ask provider:** `functions/lib/gemini.ts` (generateContent, JSON mode, `x-goog-api-key`)
  replaces `anthropic.ts`; `wrangler.toml` `ASK_MODEL = "gemini-flash-latest"`,
  `ASK_MAX_TOKENS = "2048"`; secret `GEMINI_API_KEY` (`.dev.vars` / Pages secret).
- **Busy / quota:** Google 429, 503 and empty-body 404 → `429 upstream_busy` with
  `retry_after_s` (RetryInfo or 60 s). App: `AskErrorKind.busy`, copy `askErrBusy` with
  "N seconds" / "N minutes". One key only (Q-21).
- **Free-tier limit found:** 20 requests/day per model (`gemini-3.8-flash` behind the alias).
  Retries during setup used today's quota, so `ask_cache.json` is not generated yet; Ask stays
  hidden until it is (feature registry).
- **API base URL:** `--dart-define=ASK_API_BASE` (`ask_client.dart`, `build_all.sh` passes
  `$ASK_API_BASE`) so the static Namecheap site can call the function on Cloudflare later.
- **Deploy:** `scripts/deploy_namecheap.sh` restored from 4d3e9dc + `.gz` copies and a dated
  server backup before rsync (no `--delete`). `check_secrets.sh` also scans for Google keys.
- **Checks:** ruff clean; pytest 87 passed; vitest 15 passed; tsc clean; flutter analyze no
  issues; flutter test 147 passed; secret scan OK.

## Judge feedback fixes + Ask live with Groq fallback (2026-11-13)
- **Feedback checked against code:** both models train on orbit rows only (`log10_gravity`
  std 0), so gravity cannot move the verdict; Moon/Mars give "outside tested range"; the
  usability section was empty; the video script overclaimed Moon/Mars predictions.
- **Gravity framing:** Lab caption `labGravityOrbitOnly` under the gravity slider when the
  valid gravity range is orbit only. Home subhead now leads with "NASA's fire data stops at
  orbit"; primary CTA `homeCtaNext` → Moon-base mission (wishlist); Lab and Tour follow.
- **Methods:** "Tested with people" hidden until `usability.json` has tasks (no made-up results).
- **Ask:** `functions/lib/groq.ts` fallback (Gemini → Groq, shorter wait when both busy);
  `filterMarkers` normalises `[ S5]` markers; `ask-cache --pause` spaces requests (no retries).
  `ask_cache.json` generated (6 answers, grounded, model `openai/gpt-oss-120b`); askQ1/askQ5
  reworded (Q-21). Cloudflare: Pages project, secrets, `RATE_KV` bound in `wrangler.toml`.
- **Docs:** Video 2 script and SRT reordered (finding first, Ask + Lessons shown, closing line),
  Video 3 caption no longer claims Moon/Mars predictions; README/SUBMISSION usability lines.
- **Secrets:** `check_secrets.sh` also matches Groq keys (`gsk_…`).
- **Checks:** flutter analyze no issues; flutter test 149 passed; pytest 87 passed; ruff clean;
  vitest 16 passed; secret scan OK.

