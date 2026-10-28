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
