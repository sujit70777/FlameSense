# Feasibility: what the collected data can support (2026-11-02)

Based only on files in this folder:
- `raw/psi/` (24 PSI combustion investigations, 22 experimental tables);
- `docs/PSI_INVENTORY.md`;
- `raw/corpus_catalog.csv` (60 NTRS reports + 10 web resources);
- `docs/THIRD_PARTY_CANDIDATES.md`, `manual/third_party_CANDIDATES.csv`;
- `manual/holdout_luci_CANDIDATES.csv`, `manual/LUCI_TO_DIGITIZE.md`.

Row counts were recomputed from the tables for this document. Page numbers are PDF pages.

> **Correction to `docs/PSI_INVENTORY.md`:** its summary counts only the first table of
> investigations with two tables. PSI-10 also has `…Flame Design_Inverse Flame.csv` (120 rows), and
> PSI-159 also has `…CFI-G_Inverse Flames.csv` (1,015 rows, of which only 154 have values).

---

## 1. Investigations hub

| Field | Coverage | Gaps |
|---|---|---|
| **Objectives** | 24/24 have PSI `objective` text (236–1,265 characters) plus `approach`; copied verbatim in `raw/psi/*/metadata.json` | none |
| **Fuels (shape/size)** | In table columns for Saffire-I/II/III (thickness, length, width), FLEX (droplet diameter), FLEX-2 (diameter range 1.5–5 mm, packed in one cell), SPICE (nozzle mm), ACME BRE (burner size mm). Packed into the material string for BASS/BASS-II (e.g., "2 cm SIBAL", `1/4" clear rod`) | Fuel name only, no size: CFI, ACME CLD/E-FIELD/s-Flame/Flame Design/CFI-G, SLICE, SAME, SAME-R, DAFT. No table at all: PSI-60, 62, 115, 117 |
| **Conditions** | O₂ in table: PSI-10, 20, 25, 39, 68, 69, 98, 99, 159. Pressure: PSI-10, 39, 68, 69, 159. Flow: PSI-98, 99, 100, 101, 102, 107; FLEX-2 as a range; BASS-II only as an uncalibrated "Fan display" (calibration file listed, not downloaded) | No O₂ or pressure in the table: BASS, ACME CLD/E-FIELD/s-Flame, SAME, SAME-R, DAFT, SLICE, SPICE, Saffire-III |
| **Varied vs constant** | Computable for tables with enough rows: FLEX 274, SPICE 469, Flame Design 207+120, CFI-G 179+154, BASS-II 129, BASS 122, SAME-R 109, CFI 87, CLD 32, E-FIELD 32 | Too small or packed to mean much: Saffire-III (2 rows), DAFT (2), FLEX-2 (8 summary rows with lists in cells), SLICE (2 columns), Saffire-I (2 real rows + 2 note rows), PSI-142 (a data index, not a test matrix) |
| **Measurements / sensors** | PSI has no instrument field; only free text. Regex hits in text: radiometer (PSI-10, 39, 98–100, 159), P-Trak (DAFT), anemometer (Saffire), camera/video (most) | Must be curated by hand for every investigation; BASS/BASS-II text names almost no instruments (the BASS-II TM p.64 does: radiometer, anemometer, Nikon camera, HD video) |
| **Publications** | 352 listed across 23 investigations (284 with DOI); 58 matched on NTRS, 23 in the corpus | PSI-115 lists none |
| **Hardware** | PSI field filled for 19 | Empty: SLICE (106), PSI-60, 62, 115, 117. License missing: PSI-10 |

## 2. Solid flammability model (burn / no-burn, extinction)

**PSI tables alone:** only **Saffire-II (PSI-99)** has row-level solid outcomes. It has 9 samples,
whose burn length / spread columns say "~ 0" (no significant burn) for 4 silicone samples, "29 cm"
and spread rates for 2 SIBAL samples, and "PMMA consumed, Nomex not ignited" for 1 (note 2).
Saffire-I has burn times only (420 s, 70 s). Saffire-III, BASS and BASS-II tables have no outcome
column. **Total: about 9 rows from PSI.**

**Printed tables in NASA reports (transcribable, not plots):**
- `raw/ntrs/20210011385_…` (BASS-II Summary Report, NASA/TM), **Table 7.1, p.104**: **33 SIBAL fabric
  tests in 31 rows** (27 BASS-II, T28 split into a/b, + 4 BASS) with width, flow (cm/s), O₂ vol%
  (16.4–21) and comments: 6 "Quenched", 6 "No ignition"/"did not ignite", 1 "Blow-off",
  2 "No blowoff", 4 "Reused, ignited", 1 "one-sided flame". No stated outcome: 7 rows with only
  "-----" and the 4 BASS rows (comment "BASS"). Two O₂ readings are flagged "might be inaccurate".
- `raw/ntrs/20180005168_…` (Saffire I–III), **Table 1, pp.30–31**: **13 samples** with µg and 1-g
  burn length and spread rate (µg burn length "~ 0" for 4 silicone samples).
- Third party: 6 rows (`manual/third_party_CANDIDATES.csv`; 5 sustained, 1 quenched).
- LUCI: 4 rows (extinction stated for 3).

**Potential total ≈ 9 (PSI) + 31 + 13 + 6 + 4 ≈ 63 rows**, of which about 20 are clearly "did not
burn / went out": Table 7.1 has 13, Saffire 4–5, Sharma 1. Saffire-II rows appear in both PSI and
NTRS Table 1, so deduplicate. That would
meet PLAN's minimum of ≥ 40 rows and ≥ 8 per class, but only after transcription and review.
**O₂ coverage is 16.4–22.9% only.** There are no solid tests near the Moon-base 30–34% O₂, and no
reduced pressure.

## 3. Flame spread model

**In PSI tables:**
- Saffire-II µg "Spread Length" column: 2.1 and 2.6 mm/s.
- Saffire-II 1-g spread rate: 1.2 and 0.6 mm/s.
- **Total: 4 values.** No other PSI table has a spread rate.

**Printed in report tables (transcribe, no digitizing needed):**
- `20210011385` BASS-II TM **Table 5.1, p.65**: 20 PMMA flat-sample tests (1–5 mm thick, 1.2/2.2
  cm wide, opposed flow 2–21 cm/s, initial and final O₂ 16.8–22.2%). **39 spread-rate values** at
  stepped flows (0.012–0.144 mm/s); 2 tests "Not tracked".
- `20210011385` **Table 2.1, p.36**: extinction velocity for thin PMMA at 1 atm (21% → 10±5 mm/s;
  16% → 30±5 mm/s; experiment, computation and theory).
- `20180005168` **Table 1, p.31**: 6 µg spread rates (1.8, 1.3, 2.1, 2.6, 2.3, 0.98 mm/s) and 1-g
  rates.
- LUCI (`20250010653`): 4 spread rates, already in `manual/holdout_luci_CANDIDATES.csv`.

**Potential ≈ 39 + 6 + 4 (+ 4 PSI) ≈ 50 values**, mostly opposed-flow PMMA from BASS-II.
Concurrent-flow µg spread rates are few (Saffire 6, LUCI 2).

## 4. Droplet suppression model (FLEX / FLEX-2 / CFI)

- **FLEX (PSI-69): 274 rows**, every one labeled in `Test end`: Extinction 186, Disruption 61,
  Completion 27.
  - Fuels: methanol 157, heptane 117.
  - CO₂ fraction > 0 in **123 rows** (0–0.70); He > 0 in **50 rows** (0–0.45); O₂ 0.12–0.34.
  - Pressure 0–2,319.9 mmHg (one row at 0 mmHg); initial droplet diameter 1.1–4.67 mm.
  - Burning rate in 258 rows (0.05–1.06; header unit "mm", see §8).
  - Extinction share by diluent: CO₂ 88/123, He 40/50, none 58/101.
- **FLEX-2 (PSI-68): 8 rows**, a design summary (fuels with packed ranges); **no test-end labels**.
- **CFI (PSI-39): 87 rows** with pressure (7 levels, 0.5–5 atm), O₂ (0.17, 0.21) and He (0, 0.29,
  0.59); **no test-end column**.
- **Usable labeled rows: 274 (FLEX only).**

## 5. Detection (SAME / SAME-R / DAFT)

| Investigation | Table rows | Columns | What's missing |
|---|---|---|---|
| SAME (PSI-102) | 8 (4 Teflon runs + "same conditions" rows for Kapton, silicone…) | Sample material, air flow (cm/s), weight loss rate (mg/min), aging duration (min) | No particle-size results |
| SAME-R (PSI-101) | 109 | Sample type (Kapton 29, silicone 22, lampwick 20, Pyrell 20, Teflon 18), test #, description, date, inlet velocity (cm/s), Rt/R0, duration, aging and mixing times | No particle-size results |
| DAFT/DAFT-2 (PSI-47) | 2 | Session, day (2005), hardware (modified P-Trak; DustTrak), sample (Arizona Road Dust in ISS GN₂), location | Sessions only |

Particle-size results exist as **printed tables** in:
- `20130000422` Table 1, p.7: "Diameter results for baseline runs for each material (µm)";
- `20080012612` Table 1, p.6: count mean diameters vs 1-g;
- `20010074094` Table 1, p.2.

PSI also lists **201 SAME/SAME-R "Analyzed Data" spreadsheets** (not downloaded; login needed).

## 6. LUCI blind test

- **From text:** 4 candidate rows (lunar-g and 1-g × SIBAL and PMMA), built from 31 verbatim quotes:
  spread rates, starting O₂, O₂ minima, "extinction" for 3 rows, "Earth's gravity" for the 1-g rows.
- **Missing from the text:**
  - **lunar-g level** (stated only as 11 RPM at 1.22 m);
  - **pressure** ("normal pressure");
  - **O₂ at extinction**, which the blind test compares against. The text only says the falling O₂
    "enabl[es] a limiting value for extinction to be defined".
- **To digitize:** 10 plot items in `manual/LUCI_TO_DIGITIZE.md`. 8 are needed for the blind test:
  O₂ at extinction ×2 lunar-g and ×2 1-g, gravity level ×2, extinction times ×2.
- **Not available anywhere in the corpus:** chamber pressure, SIBAL thickness, PMMA rod length.
  Only one LUCI document (a slide deck) is in the corpus.

## 7. Third-party / partner data

| Source | License | Rows |
|---|---|---|
| Sharma et al. 2024, *Microgravity Sci. Technol.* 36:20 (`raw/third_party/sharma2024-mst-confinement/`) | CC BY 4.0 | **6** (Table 1) |
| Link et al. 2018, *Sci. Rep.* | CC BY 4.0 | 0 (no tables) |
| Kumar et al. 2023, arXiv:2311.09041 (IIT Madras / Hokkaido) | CC BY 4.0 | 0 (no tables) |
| Takahashi 2026 (partial-g, PCI); Takahashi 2026 (ISS/Kibo, C&F); Mikami 2026 (droplets, PCI) | CC BY 4.0; CC BY-NC-ND 4.0; CC BY 4.0 | 0 (manual download pending) |

The only extracted rows (Sharma) have NASA co-authors and use NASA BASS hardware. **No rows yet
from a source independent of NASA.**

## 8. Contradictions and data-quality issues

**Saffire metadata:**
- **Saffire PSI tables disagree with NASA report 20180005168 (Table 1, p.30):**
  - Saffire-I thickness: PSI says 0.37 **cm**, the report says 0.37 **mm**.
  - Saffire-I width and length are swapped: PSI has 94 × 40.6, the report has 40.6 wide × 94 long.
    Sample I-2 is "~ 10 cm" long in the report.
  - Saffire-III: PSI says 0.33 cm thick and 30 cm/s; the report says 0.37 mm and 25 cm/s.
  - Saffire-II sample 2-6 flow: PSI 20 cm/s, report 25 cm/s.
  - Saffire-II thickness typed "037 mm" (rows 2-4 to 2-6).
  - Use the report values and flag the PSI ones.
- **PSI-98 (Saffire-I) metadata** gives platform "ISS" and dates 2001–2008 (apparently copied from
  SAME), but its hardware field says "Saffire 1 enclosure in Cygnus". PSI-99 says "Cygnus Spacecraft".

**Other table issues:**
- **ACME BRE (PSI-20)** O₂ column has the entries "3400%" and "2100%" (probably 34% and 21%) and
  lists several O₂ levels per row, so it isn't row-level.
- **FLEX (PSI-69):**
  - one row at pressure 0 mmHg (suspect);
  - `Burning rate; mm` — the unit is probably mm²/s; check the FLEX documentation;
  - headers lost subscripts ("O initial" = O₂, "CO initial" = CO₂).
- **CFI-G inverse table:** 1,015 rows, but only 154 have values.

**Against the statement:**
- The statement says CFI-G's highest-O₂ tests reached 85%. Confirmed: the CFI-G inverse XO₂ maximum
  is 0.85. But ACME **Flame Design** inverse flames also reach 0.85 (PSI-10), which the statement
  doesn't mention.
- **"No partial-gravity data in PSI":** confirmed; every flight investigation is ISS or Cygnus
  microgravity.

**Against PLAN.md:**
- **Moon-base O₂ is out of range:** PLAN's mission screening and FM2 forecast evaluate 30–34% O₂ and
  56.5–70.3 kPa. The solid data covers only 16.4–22.9% O₂ at about 1 atm, so every solid verdict at
  Moon-base O₂ is extrapolation. The "data support: low" badge will apply everywhere. The only
  raised-O₂ solid source found (Carmignani 2026, CC BY) isn't downloaded.
- **LUCI blind test:** PLAN's method compares a predicted 50% O₂ boundary with an observed LUCI
  limit. That limit is not stated in the text and must be digitized; gravity and pressure must be
  confirmed or assumed.
- **The solid model needs report tables:** PLAN assumed BASS/BASS-II PSI tables might give outcomes,
  but they're test matrices only. The outcomes live in the BASS-II TM Tables 5.1 and 7.1.
- **Droplet model:** PLAN expected the droplet tasks to be best supported. Confirmed for FLEX only:
  FLEX-2 and CFI have no end labels.
- **Detection:** PLAN's detection content (SAME, SAME-R, DAFT) has no result columns in PSI tables;
  it must come from the report tables or the analyzed-data spreadsheets.

---

## Verdict

| Feature | Verdict | Reason |
|---|---|---|
| Investigations hub | **SUPPORTED** (with gaps) | Objectives and publications for 24/24; tables for 20 of them. But sizes, O₂/pressure and instruments are missing for about half, and instruments need hand curation (§1) |
| Solid flammability model | **PARTIAL** | Only ~9 outcome rows in PSI; ~63 possible (~20 non-burning) after transcribing BASS-II TM Table 7.1 (p.104) and Saffire Table 1 (pp.30–31). O₂ only 16–23% at 1 atm, so Moon-base predictions are extrapolation |
| Flame spread model | **PARTIAL** | Only 4 values in PSI tables; ~50 after transcribing BASS-II TM Table 5.1 (p.65), Saffire Table 1 (p.31) and LUCI. Mostly opposed-flow PMMA |
| Droplet suppression model | **SUPPORTED** | FLEX: 274 rows, all with test-end labels, CO₂ in 123 rows, He in 50; pressure and diameter present. FLEX-2/CFI add no labels |
| Detection view | **PARTIAL** | PSI tables are test logs only (SAME 8 rows, SAME-R 109, DAFT 2). Particle sizes are in report tables (3 docs) and 201 spreadsheets that weren't downloaded |
| LUCI blind test | **PARTIAL** | 4 rows of spread rates and O₂ trends from text. Extinction O₂, g-level and extinction times need digitizing (8 values); pressure isn't available at all |
| Third-party data | **PARTIAL** | 6 CC BY rows (Sharma 2024), but NASA co-authored. 3 independent JAXA-group CC papers are pending manual download; 0 independent rows so far |

---

## Update after Round 2 (2026-11-02, Prompts 8–11)

Report tables are now transcribed, and every manual file is `verified=yes`. LUCI was checked by
the lead. The other files were checked by the agent at the lead's request (`verified_by` says
which).

| Feature | Verdict now | What changed |
|---|---|---|
| Investigations hub | **SUPPORTED** | `manual/investigation_curation_CANDIDATES.csv`: instruments with quoted evidence for 17 of 24 investigations, plus parsed sample sizes (e.g. `1/4" clear rod` = 6.35 mm). 7 have no instrument named in any source we hold: PSI-20 BRE, PSI-22 E-FIELD, PSI-23 s-Flame, and the ground studies PSI-62, 115, 117, 142 |
| Solid flammability model | **PARTIAL → close to SUPPORTED** | Outcome rows: BASS-II TM Table 7.1 (19 rows with an outcome: 13 "did not burn / went out", 6 burned), Saffire Table 1 (26 µg/1-g rows, 19 with an outcome), Sharma (6), LUCI (4). About 50 labelled solid rows, so the ≥ 40 / ≥ 8 per class gate in PLAN Phase 5 is met. O2 still 16.4–22.9 %; Moon-base O2 is extrapolation |
| Flame spread model | **SUPPORTED (opposed-flow PMMA)** | 39 spread rates from BASS-II TM Table 5.1, 6 µg + 2 1-g from Saffire, 4 LUCI. Concurrent-flow µg rates remain few |
| Droplet suppression model | **SUPPORTED** | Unchanged. The FLEX burning-rate unit is confirmed as mm²/s (K = −dD²/dt; NTRS 20140006750 p.4) |
| Detection view | **SUPPORTED (particle sizes)** | `manual/same_particles_CANDIDATES.csv`: 60 values from 3 printed tables (SAME-R moments for 5 materials unaged/aged; SAME count-mean diameters with % vs 1 g; CSD low-g vs 1-g primary and aggregate sizes). The DAFT summary spreadsheet is now on disk |
| LUCI blind test | **SUPPORTED, with a caveat** | `manual/luci_digitized.csv`: SIBAL went out in lunar g at **17.9 % O2** (72.6 s). PMMA did **not** go out in lunar g (still burning at 14.4 % when gravity dropped at 124 s), so it is an upper bound only. Gravity: computed 0.165 g, plotted 0.178–0.179 g; pressure 101.3 kPa is assumed |
| Third-party data | **SUPPORTED** | Takahashi 2026 (Gifu University and JAXA-related, no NASA authors, CC BY 4.0): 32 partial-gravity test conditions (1/12–3/8 g, 101.3 and 56.5 kPa), 8 derived velocities, and 20 **model-predicted** limiting O2 values for the Moon, Mars, Ceres, Phobos and Earth (never training data). Sharma 2024: 6 outcome rows |

New data-quality items: see `manual/data_quality_issues.csv` and `docs/DATA_QUALITY.md` (23 items).
The most important: Saffire-I/III units and dimensions (use the report values); FLEX test 114
pressure 0 mmHg; Saffire-II material blanks; the conflicting FLEX-145 composition slides.
