# Staged, verified data from the prep work (not ingested yet)

These CSVs come from `~/flamesense-prep` (PREP_PROMPTS Rounds 1–2). Every row is `verified=yes`:
LUCI by the lead, the rest by the agent at the lead's request (see each row's `verified_by`).
They sit in this sub-folder on purpose. `pipeline/sources.yaml` ingests `data/manual/*.csv`
(top level only), so nothing here reaches training until the phase that needs it moves or maps it.

| File | Rows | Kind | Consumed by |
|---|---|---|---|
| holdout_luci.csv | 4 | LUCI runs (holdout, group_id=luci) | Phase 5B (needs the leakage guard first) |
| luci_digitized.csv | 10 | LUCI plot values (O2 at extinction, g level) | Phase 5B blind test |
| bassii_t71.csv | 31 | SIBAL burn/no-burn (NASA/TM-20210011385 Table 7.1) | Phase 2/3 data refresh |
| bassii_t51.csv | 43 | PMMA spread rates (Table 5.1) | Phase 2/3 data refresh |
| bassii_t21.csv | 2 | Extinction velocity, thin PMMA (Table 2.1) | reference (findings) |
| saffire_t1.csv | 26 | Saffire I–III µg / 1-g results (NTRS 20180005168 Table 1) | Phase 2/3 data refresh |
| third_party.csv | 66 | Sharma 2024 (6 runs); Takahashi 2026 (32 test conditions, 8 derived values, 20 MODEL PREDICTIONS) | Phase 2/3 (runs only); predictions never train |
| same_particles.csv | 60 | SAME/SAME-R/CSD particle sizes (not runs) | Phase 13 detection pillar |
| investigation_curation.csv | 24 | Instruments and sample sizes with quotes | Phase 3D |
| data_quality_issues.csv | 23 | PSI vs report discrepancies | Phase 3D / Methods; summary in docs/prep/DATA_QUALITY.md |
