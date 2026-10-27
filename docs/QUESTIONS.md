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
