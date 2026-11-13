# Candidate data sources (for [LEAD] to open and confirm)

**These are leads, not data.** The agent found them by web search on 2026-10-28. Per PLAN.md §3.0
a source goes into `docs/DATA_SOURCES.md` only after the lead has opened it, and every value is
copied by the lead with its citation. The agent has added no rows.

Why this matters: with 0 runs, every prediction, map, mission verdict and video number in the
app is empty. At least **40 runs with a known outcome** unlock the burning model (≥ 8 kept burning
and ≥ 8 went out); 40 runs with a spread rate unlock the spread models (PLAN.md Phase 5).

## 1. Fastest path: digitize published per-run tables → `data/manual/*.csv`

Use `docs/templates/digitized_runs_template.csv` (the exact §3.1 columns). One CSV per paper,
`quality_flag=digitized`, `source_citation` on every row, e.g.
"NASA NTRS 20180005168, Table 1 p.30–31, sample I-1".

| Source | What it holds (seen in the document) | Notes |
|---|---|---|
| **Saffire I–III results**, NTRS 20180005168 — https://ntrs.nasa.gov/citations/20180005168 | Table 1 (pp. 30–31) "Summary of Samples, Test Conditions, and Selected Results": sample, material (cotton-fiberglass SIBAL, silicone), width, thickness (mm), flow speed (cm/s → ×10 mm/s), flow direction, O₂ %, ignition, burn duration, **µg spread rate (mm/s)** and **1-g spread rate** | Each sample gives a microgravity row (platform `free_flyer`, gravity ≈ 1e-6 unless stated) and, where tested, a 1-g ground row. "Insignificant"/"~0" burn = `sustained=false` |
| Saffire IV and V, NTRS 20210017780 — https://ntrs.nasa.gov/citations/20210017780 | Fire safety implications of Saffire IV/V (PMMA, cotton, cotton-fiberglass, 40 cm wide) | Check for a run table before using |
| Guibaud et al., SIBAL/cotton concurrent spread (UCL repository) — https://discovery.ucl.ac.uk/id/eprint/10164340/ | Concurrent spread data for Saffire IV/V | Journal paper: check the licence (AUDIT §1) |
| BASS / BASS-II summaries — https://ntrs.nasa.gov/citations/20160000593, https://ntrs.nasa.gov/citations/20150002323 | Over 100 ISS glovebox burns of solids: flame spread, flow speed, extinction and N₂ suppression | Look for tables of flow speed vs spread/extinction |

## 2. Official flight data: NASA Physical Sciences Informatics (PSI)

PSI hosts completed ISS combustion investigations, including **BASS, BASS-II, FLEX, FLEX-2,
ACME (CLD Flame, E-Field Flames, s-Flames, BRE), CFI and DAFT** (NASA ROSES PSI list:
https://science.nasa.gov/physical-sciences-informatics-psi/nasa-psi-research-opportunity/).
Much of it is images and video; look for summary spreadsheets per test point. Download into
`data/raw/<source_id>/` without renaming, run `python -m flamesense.cli inspect`, and the agent
writes the adapter (PLAN Phase 2).

## 3. Check the official challenge resources first

The full 2026 statements were due 28 Oct 2026. The "Flame in Freefall" page on
spaceappschallenge.org lists the datasets the judges expect; map each one in
`docs/CHALLENGE_REQUIREMENTS.md` (PLAN §0.4) and prefer those over the leads above.

## 4. Mission and physics sources already named in PLAYBOOK_LEAD §3.1

NTRS 20240003211 (8.2 psia / 34% O₂ exploration atmosphere; ISS 14.7 psia / 21%), 20260003925,
20240015307, and the FM2 test plan 20260001966. Fill `source` in `data/manual/missions.json`
after opening each one (Q-7).
