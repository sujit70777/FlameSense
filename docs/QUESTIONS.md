# FlameSense — Open Questions

Questions the agent could not answer from the docs. Each has phase number, context, and options chosen.

---

## Q-1 — Phase 4: near-extinction warning thresholds

**Context:** PLAN.md Phase 4 says the thin-fuel formula "over-predicts spread
near extinction (very low flow in microgravity, or low oxygen)" but defines no
thresholds for the `near_extinction_warning` state.

**Chosen (safest, pending SCI confirmation).** Warning when the row is
applicable AND:
- O₂ mole fraction < 0.15, **or**
- microgravity (`gravity_g < 0.01`) with forced flow < 5 mm/s.

Marked `TODO(Q-1)` in `physics.py`. If `[SCI]` wants different thresholds,
update `NEAR_EXTINCTION_*` constants and this note.

---

## Also worth confirming by [SCI]
- The O₂ grid `flame_temp_vs_o2.o2 = [0.21, 0.30]` in the §3.7 template is
  only the interpolation grid; the `t_f_k` values and grid itself may be
  adjusted to the cited source.
- `buoyant_velocity_m_s` evaluates T_f at O₂ = 0.21 (standard air) for the
  characteristic value; the Lab may interpolate at the actual O₂.
