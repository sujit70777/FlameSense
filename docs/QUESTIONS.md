# FlameSense — Open Questions

Questions the agent could not answer from the docs. Each has phase number, context, and options chosen.

---

## Q-1 — Phase 4: near-extinction warning thresholds

**Context:** PLAN.md Phase 4 says the thin-fuel formula "over-predicts spread
near extinction (very low flow in microgravity, or low oxygen)" but defines no
thresholds for the `near_extinction_warning` state.

**Chosen (safest, pending LEAD confirmation).** Warning when the row is
applicable AND:
- O₂ mole fraction < 0.15, **or**
- microgravity (`gravity_g < 0.01`) with forced flow < 5 mm/s.

Marked `TODO(Q-1)` in `physics.py`. If `[LEAD]` wants different thresholds,
update `NEAR_EXTINCTION_*` constants and this note.

---

## Also worth confirming by [LEAD]
- The O₂ grid `flame_temp_vs_o2.o2 = [0.21, 0.30]` in the §3.7 template is
  only the interpolation grid; the `t_f_k` values and grid itself may be
  adjusted to the cited source.
- `buoyant_velocity_m_s` evaluates T_f at O₂ = 0.21 (standard air) for the
  characteristic value; the Lab may interpolate at the actual O₂.

---

## Q-2 — Phase 5: confirm monotone constraint signs ([LEAD])

**Context:** PLAN.md Phase 5 proposes `+1` for `o2_mole_fraction` and `o2_partial_kpa`
(both tasks) and `−1` for `fuel_thickness_mm` and `areal_density_kg_m2` (spread), to be
confirmed by `[LEAD]` here before training.

**Chosen (safest until confirmed):** all signs are `0` (unconstrained).
`MONOTONE_CONFIRMED_BY_LEAD = False  # TODO(Q-2)` in `pipeline/src/flamesense/train.py`.
To apply the signs, the lead writes "Q-2 confirmed: <signs>" below and flips the constant
to `True`, then re-runs `python -m flamesense.cli all`.

**Answer:** _(pending [LEAD])_

---

## Q-3 — Phase 5: slider limits and no-data defaults

**Context:** PLAN.md Phase 5 gives physical limits for O₂ (0.10–0.50), pressure
(10–200 kPa), airflow (0–1000 mm/s) and gravity (1e-6–1 g) but none for fuel thickness or
density, and no defaults for when the dataset is empty.

**Chosen (UI limits, not data):** thickness 0.01–50 mm (log slider), density 1–3000 kg/m³.
When an input has no training values, sliders span the physical limits and defaults are
O₂ 0.21 (Earth air), 101.3 kPa (sea level), airflow 100 mm/s, gravity 1e-6 g (ISS),
thickness 0.1 mm, density 500 kg/m³. These are only starting positions; no prediction is
shown while the tasks are unavailable. The gravity slider always spans 1e-6–1 g (the
Earth/Mars/Moon/ISS snaps need the full range; outside-range flags still apply).
`feature_spec.json` gains a top-level `"inputs"` object holding these user-input sliders
(the per-task `features` list is unchanged). Marked `TODO(Q-3)` in `export.py`.

---

## Q-4 — Phase 5: LightGBM cannot apply monotone constraints to quantile models

**Context:** LightGBM 4.7 raises "Cannot use monotone_constraints in quantile objective".
The plan asks for constraints on the spread quantile models.

**Chosen:** constraints (once Q-2 is confirmed) are applied to the sustain classifier only.
Spread models are trained unconstrained, and a warning is written to `metrics.json` /
MODEL_CARD.md when the signs are confirmed. Marked `TODO(Q-4)` in `train.py`.

---

## Q-5 — Phase 6: copy strings not given in DESIGN.md

**Context:** A few states need copy that DESIGN.md §12 does not define.
**Chosen (agent wording, in `app/tool/l10n_source.py`, marked `TODO(Q-5)` in descriptions):**
`homeDataPending` (Home when the dataset is empty), `exploreNoDataTitle/Body` (Explore when
there are 0 runs, instead of the misleading "No runs match these filters"), `labDeltaSlower`
(compare mode when spread is slower on Earth), `methodsDesc` and `aboutDesc` (§8.4 requires a
description on every page). The HTML splash text is "Loading FlameSense" (PLAN Phase 6 step 9)
while the in-app loading screen says "Loading NASA experiment data" (DESIGN §11.0).
Please review the wording.

---

## Q-6 — Phase 6: team names and contact email on About

**Context:** DESIGN §11.8 asks for team member names (as the team decides; no one under 18)
and a contact email. Only Ehsanur is named in the docs.
**Chosen:** `aboutTeamBody` names only Ehsanur and describes the two other roles; Contact links
to GitHub issues instead of an email. Replace in `app/tool/l10n_source.py` when decided.

---

## Q-7 — Phase 11B: `data/manual/missions.json` is a template ([LEAD] input missing)

**Context:** PLAN Phase 11B needs `data/manual/missions.json` with NASA sources; it did not exist.
**Chosen:** the agent wrote the §3.10 template with the atmosphere numbers exactly as written
in PLAN.md §3.10, **every `source` empty** and **no FM2 points**. Release builds hide every
unsourced mission and planned test, so the Missions page shows "Mission presets are being
verified" until the lead fills sources. Debug builds show them with a warning.
**[LEAD] to do:** fill each `source` from the NASA document; check every number against it
(note: §3.10 uses Moon 0.1654 g / Mars 0.3794 g, while `gravity.dart` uses the PLAN Phase 7
values 0.1652 / 0.3783 from the Planetary Fact Sheet — pick one); copy FM2 points exactly.
PLAYBOOK_LEAD §3.1 lists the candidate NASA sources to open: NTRS 20240003211 (8.2 psia /
34% O₂ exploration atmosphere; ISS 14.7 psia / 21%), NTRS 20260003925, NTRS 20240015307 and the
FM2 test plan NTRS 20260001966. The agent did not fill `source` fields from them, because each
must be opened and checked by the lead.

## Q-8 — Phase 11B: wishlist reason thresholds and planned airflow

**Chosen:** a reason is shown when its term is strong — "unsure" when u ≥ 0.6, "no run close"
when n ≥ 0.5 (distance ≥ p95), "wide range" when w ≥ 0.5; otherwise the largest term's reason.
`w` = interval width ÷ widest interval among the mission's candidates. Planned points
("buoyant flow only") are scored at the airflow slider minimum. The percentile sentence
truncates to one decimal (never rounds up). `TODO(Q-8)`.

---

## Q-9 — Phase 12: Anthropic request differs from PLAN step 6 for the current model

**Context:** PLAN.md sends `temperature: 0.2` to `claude-sonnet-5-5`. Per the current API
reference, Claude Sonnet 5.5 rejects non-default sampling values with a 400, thinks by default
(thinking tokens count toward the 800-token `max_tokens`), and supports a server-side refusal
fallback. **Chosen** (`functions/lib/anthropic.ts`): no `temperature`; for `claude-sonnet-5-5`
send `thinking: {type: "between_tools"}` (thinking off, so the budget goes to the answer);
`fallbacks: "default"` + `anthropic-beta: server-side-fallback-2026-07-01`; `stop_reason` is
checked before content (a refusal becomes the not-grounded answer). Model id stays from
`ASK_MODEL` as the plan specifies. **[LEAD]:** confirm with one real question via
`wrangler pages dev` once `.dev.vars` has the key.

## Q-10 — Phase 12: Pages compiles every file under `functions/`

**Context:** `wrangler pages dev` failed with the planned layout: it builds every file in
`functions/`, including `node_modules` and vitest tests. **Chosen:** `functions/` keeps only
`api/` and `lib/` (plus a dependency-free `package.json` whose `test`/`typecheck` scripts forward
to `../functions-dev`). Tooling and tests live in `functions-dev/`. `npm --prefix functions test`
still works as CLAUDE.md says.

---

## Q-11 — Phase 13: lessons and usability input formats ([LEAD] inputs missing)

**Context:** `data/manual/lessons_draft.md` and `data/manual/usability.csv` do not exist.
**Chosen:** the agent wrote no lesson text. `pipeline/src/flamesense/lessons.py` documents the
draft format (`## L1` blocks with `key: value` lines, `source: label | url`); a lesson stays
`draft` unless it has `reviewed_by` and a source URL. Usability: `usability.csv` with
`task_en,task_bn,completed,total,median_seconds` and optional `usability_change.txt`.
`python -m flamesense.cli export` converts both. Until then Earth shows "Lessons are being
reviewed" and Methods shows the usability-pending sentence. Tour step 5 points at the
Missions list while the Artemis preset is unsourced.

---

## Q-12 — Phase 14: accessibility deviations from DESIGN.md sizes

- **Touch targets:** chips stay 32 px visually but get a 44 px tall hit area on compact
  (`widgets/hit_target.dart`); `FsSegmented` is 44 px tall on compact instead of 36 px (a hit
  area can't be extended inside the fixed container). `TODO(Q-12)`.
- **Chart axes:** `outlineStrong` axis lines are ~2:1 against `surface1` (below the 3:1 for
  graphical objects). Token values are final per DESIGN.md, so they are unchanged; tick labels
  (`textTertiary`, ≥ 4.5:1) carry the information. Decide whether to darken the token.
- **Superscript minus:** Archivo has no U+207B (used in "10⁻⁶ g"). `FsSymbols.ttf` (908 bytes,
  `scripts/make_symbol_font.py`) holds that one glyph, derived from Archivo's hyphen, so no
  fallback font is fetched from Google at runtime.

---

## Q-13 — Phase 3C: where the prep data lives and what is committed

**Context:** the prep bundle (`~/flamesense-prep/prep_bundle`, 369 MB) was copied in. `data/raw`
now holds `psi/` (24 PSI investigations: metadata, file manifests, 22 experimental tables + 5
extra PSI files), `ntrs/` (60 NASA reports), `web/` (challenge resource pages) and `third_party/`
(CC-licensed papers). PLAN Phase 1 step 2 says to gitignore `data/raw` when it exceeds 50 MB.
**Chosen:** gitignore only the large, re-downloadable parts (NTRS PDFs, NTRS API cache, PSI raw API
JSON, third-party PDFs). About 28 MB stays in git: every experimental table, metadata.json,
manifests, checksums, web pages and the page-marked NTRS text. Integrity: `data/PREP_MANIFEST.csv`
(SHA-256 of every bundled file). **[LEAD]:** confirm, or say to gitignore all of `data/raw`.

## Q-14 — Verified prep CSVs are staged in `data/manual/prep/`, not `data/manual/`

**Context:** `pipeline/sources.yaml` ingests every `data/manual/*.csv` as canonical runs. The prep
CSVs include non-run tables (particle sizes, model predictions, issue lists) and the LUCI holdout,
whose leakage guard only arrives in Phase 5B. Several rows also lack required values (e.g.
pressure for BASS-II, O2 for Saffire 1-g rows), which `validate` would reject. **Chosen:** stage
them in `data/manual/prep/` (not ingested). The phase that consumes each file maps it explicitly
(see `data/manual/prep/README.md`). TODO(Q-14).

## Q-15 — Phase 3C: copy and vocabulary not specified in DESIGN.md

- **UI strings:** DESIGN §11.2b gives only the caption. Labels, the cell filter notice, the
  empty state and the matrix note ("{placed} of {total} table rows state both oxygen and
  pressure…") were written by the agent under the `coverage*` keys (§12 naming rule). The second
  tab is "Test runs" (§11.20). Bangla is `bn-pending`. **[LEAD]:** review the wording.
- **`fuel_classes` in coverage.json:** a coarse factual vocabulary (`droplet`, `gas_jet`, `solid`,
  `smoke_aerosol`) read from table headers, the title, and for flight investigations PSI's
  objective/approach text. It is not the canonical `fuel_class` (thin/thick cannot be decided
  from these files).
- **Matrix placement:** a table row is counted only when it states exactly one O2 value and one
  pressure with a unit. Rows with ranges or lists in one cell (FLEX-2, ACME BRE) and tables with
  no pressure (BASS-II, Saffire) stay out of the matrix but are listed. Values outside 0–100 % O2
  or ≤ 0 kPa are skipped and counted (`implausible_values_skipped`: ACME BRE '3400%'/'2100%',
  FLEX test 114 '0 mmHg').
- **Row counts:** `n_rows` counts test rows: empty rows, "Note …" rows, Saffire flow-video rows and spreadsheet continuation lines (e.g. 10 lines in ACME E-FIELD that hold only an extra fuel concentration under the previous test day) are not counted, so E-FIELD shows 22 of 32 printed lines.
- **Explore tabs:** the coverage tab is first (§11.2b); `/explore?tab=runs` opens the runs tab.
  The Judge Tour step 6 and three Phase 9 tests now use that link. TODO(Q-15).

## Q-16 — Phase 3D: parts deferred by the lead

- **AI summaries** (`summary_student_en`, `summary_expert_en`) are `null` with `reviewed: false`;
  the offline summary step with the number check needs the Anthropic key. **`/api/compare`** (AI
  narrative) is not written yet for the same reason. TODO(Q-16).
- **Tests** for Phase 3D are left to the lead, at the lead's request.
- Pillars are the PLAN defaults (others = `fundamental`); hardware families follow the statement.

## Q-17 — Data refresh: staged prep runs mapped into `data/manual/` (lead to review)

**Context:** Explore and the map were empty (0 runs). `scripts/stage_manual_runs.py` now writes
`data/manual/bassii_t71.csv` (31), `bassii_t51.csv` (43) and `third_party_runs.csv` (32) from
`data/manual/prep/`. **Chosen:** BASS-II T7.1 pressure 101.325 kPa from "Ambient pressure was
1 atm" (p.102); T5.1 pressure 101.325 kPa from the MSG value "pressure P = 1 atm" (p.19), flagged
`estimated`; fuel_class thick_solid at >= 1 mm else thin_solid; Sharma 2024 and Takahashi 2026
Table 1 included and labelled "third-party, not NASA"; Takahashi rows with changing gravity
("1/6 -> 0"), T2/T3 derived values and model predictions excluded. Saffire left out (no pressure
stated) and the LUCI holdout untouched. **Lead:** confirm or change these. TODO(Q-17).
- **Q-17 update (2026-11-02):** Saffire I–III orbit runs staged with 100 kPa from ICES-2021-266
  Table 2 (NTRS 20210011521, p.8; stated for I-1, II-5, II-6, III-1, others `estimated`);
  `ignited=True` only where `sustained=True`. `clean.DUP_KEY_COLUMNS` now includes
  `fuel_thickness_mm` (Saffire II silicone samples at four thicknesses were collapsed).
- **Q-17 update 2 (2026-11-02):** added `prep/saffire_iv_vi.csv` (8 runs: ICES-2021-266 and
  ICES-2024-365 Table 1, all ignited + sustained, quotes in `source_text_snippet`) and Saffire I–III
  outcomes stated in other NASA papers (`SAFFIRE_OUTCOMES`: silicone II-1..4 ignited, not sustained,
  NTRS 20170008805 p.12; PMMA II-8/II-9 and I-1/III-1 sustained, ICES-2021-266 p.8). Sustain model
  now trains on 42 rows (ROC AUC 0.82). Lead: spot-check these quotes.

## Q-18 — Counts audit (2026-11-11): replicates, source_id, copy (lead to decide)

- **Replicate tests are dropped as "exact duplicates".** `clean.DUP_KEY_COLUMNS` follows PLAN Phase 3
  step 1b literally, so 4 rows with their own printed test IDs are dropped: BASS-II GMT216-T26 (=T25),
  T28b (=T28a), T29 (=T27), and Sharma 2024 T1-4 (=T1-1; a different baffle, polycarbonate vs
  anodized aluminum, which the schema has no column for). **Chosen (safest, no data change):** keep
  the PLAN rule, but every drop is now logged (`data/processed/dropped_rows.csv`, CLI output,
  `app_meta.json` `dropped_rows`, DATA_REPORT "Data provenance", Methods/Data intro). **Lead:** say
  whether replicates should be kept (would make 127 runs and change model training rows). TODO(Q-18).
- **`source_id` is overwritten at ingest.** `ingest/registry.py` sets every row's `source_id` to the
  sources.yaml id (`manual`), discarding the per-paper ids in the CSVs, so the `source_id` part of
  the duplicate key does nothing. The provenance table therefore groups by citation. Not changed here
  (it touches validation against DATA_SOURCES.md). TODO(Q-18).
- **Lab range warning ignores the sustain rows' gravity.** `feature_spec.json` input `gravity_g` has
  `train_max` 0.375 (all runs, incl. Takahashi parabolic) while the sustain model trained only at
  1e-6 g, so the Lab does not warn at Moon gravity. The Home Moon-base finding now checks the sustain
  rows (14 of 14 outside). Not changed here (predictor scope). TODO(Q-18).
- **Copy changed from DESIGN §13:** `homeDataSentence` said "{experiments} NASA experiments" but 2 of
  10 experiments are third-party; now "… from {experiments} experiments across {fuels} materials:
  {nasa} from NASA, {other} from other sources." DESIGN.md updated. Gap titles/sentences moved from
  hard-coded English in `export.py` to l10n keys `gap*` (the old title "No solid-fire data above 23%
  oxygen" was false: Saffire V/VI have 6 burning solid runs at 25–31% O₂, 54–73 kPa).
- **Not fixed (other audit items):** `tour5Body` says "NASA plans habitats with 34% oxygen" (AUDIT
  §15f mission wording); the generator `tests/make_app_fixtures.py` overwrites the hand-made
  `fixture_missions.json` and adds untracked fixtures (reverted by hand this time).

## Q-19 — Solid-model valid range and mission wording (2026-11-11, phase 17G; lead to confirm)

- **How `valid_range` is defined.** PLAN §1.0 says "predictions only inside the tested range (O₂
  16–23%, ~1 atm)", but the data has 6 burning solid runs above that (Saffire V/VI: 25–31% O₂ at
  54–73 kPa, all at 200 mm/s, all burned). A plain min..max box would include 0.30 O₂ at 56.5 kPa
  (Saffire VI tested 0.303 at 54.6 kPa) and break the AUDIT §15e test. **Chosen (data-derived, no
  hand-typed limits):** `export.solid_valid_range` = per input, the overlap of the burned rows' and
  the went-out rows' ranges in the sustain training data ("where NASA saw both outcomes"; a
  classifier can't place a limit it never saw). Shipped: O₂ 0.169–0.221, pressure 100–101.325 kPa,
  airflow 22–470 mm/s, gravity 1e-6–1e-6 g. It is written to `feature_spec.json` `valid_range` and
  used by the app and by the Home Moon-base finding. The UI says "Outside NASA's tested range" and
  states this rule and the range. **Lead:** confirm the rule (or give fixed limits).
- **Gravity is part of the range.** The shipped sustain model trained on microgravity runs only
  (`log10_gravity` is constant), so its 1 g value was identical to its orbit value (a §15f
  violation the 17F fixture test missed). With gravity in `valid_range`, 1 g, Moon and Mars get no
  number. This also closes the Q-18 item "Lab range warning ignores the sustain rows' gravity".
- **Spread model gated by the same range.** PLAN §1.0 has no spread ML, but the app still ships the
  spread quantile models; they now also return null outside `valid_range` so no solid number shows
  at Moon-base conditions. The physics reference (de Ris) is not gated (it is a theory line, shown
  only when signed off).
- **Mission verdict with a partly out-of-range airflow sweep.** PLAN Phase 11B says `outside_range`
  if *any* swept airflow is outside `valid_range`; the sweep (0–300 mm/s) always starts below
  22 mm/s, which would mark ISS and Earth "outside" too. **Chosen:** out-of-range sweep points are
  skipped; the verdict is `outside_range` when no swept point is inside (O₂, pressure or gravity
  untested). Wishlist candidates and planned points outside the range get no score.
- **Home "low/no-data map cells" now counts cells outside `valid_range`** (2641 → 2876 of 3072).
  Note: `export._map_low_cells` uses O₂ 0.10–0.50 and airflow 0–1000 mm/s, while the Dart map uses
  the slider range (0.134–0.326, 14–732); not changed here. TODO(Q-19).
- **DESIGN §11.4 gap-overlay caption** ("stops at 23% oxygen. The Moon base will be at 30% or
  more") is not implemented and would be wrong on both counts (31% tested; "likely"). Not changed.
- **Mission citations:** the challenge statement has no URL in the repo, so it is cited by name
  ("NASA Space Apps Challenge 2026, 'Flame in Freefall'"); NTRS 20240003211 links to
  ntrs.nasa.gov. Submission docs and video scripts/captions (not yet recorded) now say "likely" /
  "NASA recommends"; Q-18's `tour5Body` item is fixed.

## Q-20 — Phase 16: hosting move, feature registry, Bangla removal (2026-11-11; lead to act)

- **Ask and Earth are hidden in the shipped build.** `ask_cache.json` does not exist and
  `web/data/corpus_chunks.json` is an empty corpus; `lessons.json` has 0 lessons (Q-11). Under
  PLAN §1.0 "Unfinished = hidden", `core/features.dart` turns both off: no nav item, no Home link,
  no tour step (tour is 6 steps), deep links go Home. **Chosen:** Ask needs at least one saved
  English answer to be shown, so "cached answers always work" holds whenever Ask is visible.
  **Lead:** to bring Ask back, add corpus PDFs → `cli corpus` → `wrangler pages dev` with
  `.dev.vars` → `cli ask-cache` (now English only, 6 answers) → review. Earth comes back when an
  approved, sourced lesson is in `lessons.json`.
- **Invalid optional files no longer crash the app.** A malformed `missions.json`, `lessons.json`,
  `ask_cache.json`, `usability.json` or `coverage.json` now hides its feature (logged with
  `debugPrint`, listed in `AppData.invalidAssets`) instead of showing the global error screen.
  Required files still fail loudly.
- **`app/tool/l10n_source.py` is stale.** `app_en.arb` has been edited directly since Phase 13
  (622 keys vs 540 in the script); running the script would drop 80+ keys. Marked "STALE, DO NOT
  RUN" in its docstring; `app_en.arb` is the source of truth. `app_bn.arb` and the Noto Sans
  Bengali font are no longer shipped.
- **Namecheap deploy removed** (`deploy-namecheap.yml`, `deploy.env.example`, `app/web/.htaccess`,
  the `.gz` pre-compression step). `scripts/deploy.sh` now deploys to Cloudflare Pages. The local
  git-ignored `scripts/deploy.env` was left untouched.
- **Not done (needs the lead's Cloudflare login):** `wrangler login`, Pages project, RATE_KV id in
  `wrangler.toml`, `ANTHROPIC_API_KEY` secret, preview deploy + smoke, DNS CNAME.

## Q-21 — Ask on the Gemini free tier; hosting for the event (2026-11-13; lead decided)

- **Provider switch.** The lead chose the Google Gemini API (free tier) instead of a paid Anthropic
  key. `functions/lib/gemini.ts` replaces `anthropic.ts`; `ASK_MODEL = "gemini-flash-latest"`,
  `ASK_MAX_TOKENS = "2048"` (Gemini counts thinking tokens toward the output limit). Secret:
  `GEMINI_API_KEY` (`.dev.vars` locally, Pages secret in production). Prompt and JSON contract
  unchanged.
- **Quota / overload.** Google 429 (free quota used up), 503 (high demand) and an empty-body 404
  (seen under load on 2026-11-13) map to `429 {"error":"upstream_busy","retry_after_s":N}`
  (RetryInfo delay or 60 s). The app shows "busy or has reached its free limit … wait N seconds".
- **Not done: rotating several keys to stretch the free quota.** The lead supplied three keys and
  asked to switch to the next one when a limit is hit. Using extra keys to get around a free-tier
  rate limit is against Google's API terms, so only one key is used. **Chosen:** one key + the
  wait message above.
- **Hosting.** The live site is still on Namecheap (static, LiteSpeed), which can't run
  `/api/ask`; there the 6 saved answers work and free-form questions show the "not available"
  notice. To enable free-form questions: `npx wrangler login` (lead, browser), Pages project,
  `wrangler pages secret put GEMINI_API_KEY`, deploy, then rebuild the Namecheap site with
  `ASK_API_BASE=https://flamesense.pages.dev` (new `--dart-define`, `ask_client.dart`).
- **Update (2026-11-13, lead decided): Groq fallback + Cloudflare.** The lead added a Groq key
  (a different provider, each used within its own free tier; still no multi-key rotation).
  `functions/lib/groq.ts`: Gemini first, Groq when Gemini fails or is busy; when both are busy,
  the shorter wait is shown. The lead ran `wrangler login`; Pages project `flamesense`, both
  secrets and the `RATE_KV` namespace exist. The Namecheap site calls
  `https://flamesense.pages.dev/api/ask` via `ASK_API_BASE`.
- **Suggested questions changed.** "Why are flames round…" and "Why are flames in space blue?"
  retrieved weak sources (a CFD grid paragraph; a narrow soot study). Replaced with "How is a
  candle flame in microgravity different from one on Earth?" (ISS Researcher's Guide) and "Is a
  material more flammable on the Moon than on Earth?" (FM2 / Fire on the Moon). [LEAD] reviews
  all 6 saved answers; askQ5 opens with "Yes", a little stronger than its sources ("may not be").
