# Data quality notes on PSI combustion data

*For the NASA PSI team, from the FlameSense project (NASA Space Apps 2026). Prepared 2026-11-02.*

While building a dashboard on the PSI combustion investigations, we compared the PSI experimental tables and metadata with the NASA reports that describe the same tests. We found 23 items worth a look: 12 where a NASA report gives a different value, 4 values that look wrong, and 7 we could not resolve. We changed nothing in the PSI files; our pipeline applies the report values with a note.

## Highest impact

1. **Saffire-I (PSI-98).** Thickness is 0.37 cm in PSI but 0.37 mm in the Saffire report (NTRS 20180005168, Table 1 p.30). Width and length are swapped. The metadata gives the ISS and 2001–2008, but Saffire-I flew on Cygnus OA-6 in 2016 (same report, p.15).
2. **Saffire-III (PSI-100).** Thickness (.33 cm vs 0.37 mm) and flow (30 vs 25 cm/s) differ from the report.
3. **FLEX (PSI-69).** The burning-rate column is labelled 'mm'. FLEX papers define it as K = −dD²/dt in mm²/s (NTRS 20140006750 p.4). The composition headers lost their subscripts ('CO' is CO₂). Test 114 has a pressure of 0 mmHg.

## All items

| ID | Investigation | Field | PSI value | Report value | Source | Status |
|---|---|---|---|---|---|---|
| DQ-01 | PSI-98 SAFFIRE-I | Sample Thickness (cm) | 0.37 (cm) | 0.37 mm | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-02 | PSI-98 SAFFIRE-I | Sample Length (cm) / Sample Width (cm) | length 40.6, width 94 | width 40.6 cm, length 94 cm (I-1); I-2 length ~ 10 cm | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-03 | PSI-98 SAFFIRE-I | platform / start_date / end_date | International Space Station (ISS); 03-02-2001 to 02-28-2008 | Cygnus (Orbital ATK OA-6): launch Mar 22, 2016; mission ops June 14, 2016 | ntrs:20180005168 p.15 (schedule table) | use_report_value |
| DQ-04 | PSI-100 SAFFIRE-III | platform | International Space Station (ISS) | Cygnus (uncrewed) | PSI-100 hardware field 'Saffire III enclosure in Cygnus'; ntrs:20180005168 title 'Using Un-Manned Spacecraft' | needs_check |
| DQ-05 | PSI-100 SAFFIRE-III | Sample Thickness | .33 cm | 0.37 mm | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-06 | PSI-100 SAFFIRE-III | Air Flow | 30 cm/s | 25 cm/s | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-07 | PSI-100 SAFFIRE-III | Sample Length (S2) | 94 cm | ~ 10 cm | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-08 | PSI-99 SAFFIRE-II | Air Flow (row 2-6) | 20 cm/s | 25 cm/s | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-09 | PSI-99 SAFFIRE-II | Samle Thickness (rows 2-4, 2-5, 2-6) | 037 mm | 0.37 mm | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-10 | PSI-99 SAFFIRE-II | Material (rows 2-6, 2-9) | (blank) | 2-6 Cotton-Fiberglass; 2-9 PMMA | ntrs:20180005168 p.30 (Table 1) | use_report_value |
| DQ-11 | PSI-99 SAFFIRE-II | column headers | 'Samle Thickness', '?-g Burn Length', '?-g Spread Length' | 'Sample Thickness', 'µ-g Burn Length', 'µ-g Spread Length' | ntrs:20180005168 p.31 | use_report_value |
| DQ-12 | PSI-20 ACME BRE | Oxygen Conc (percent), rows 2019-Mar-7 and 2019-Apr-1 | 3400%; 2100% | – | none | needs_check |
| DQ-13 | PSI-20 ACME BRE | Oxygen Conc (percent) | multi-level cells, e.g. '21; 26.5; 40' | – | none | flag_suspect |
| DQ-14 | PSI-20 ACME BRE | chamber pressure | (absent) | – | PSI-20 table note: 'The chamber pressures were also varied but are not identified in this summary table.' | needs_check |
| DQ-15 | PSI-69 FLEX | Ambient pressure; mmHg (FLEX Test # 114, C11M201) | 0 | – | none | flag_suspect |
| DQ-16 | PSI-69 FLEX | Burning rate; mm (unit) | mm | mm^2/s (burning rate constant K = -dD^2/dt) | ntrs:20140006750 p.4 ('burning rate constants K (=dD2/dt) ... 0.41 and 0.33 mm2/s'); ntrs:20130014061 p.5 ('Kex = -d(D2)/dt') | use_report_value |
| DQ-17 | PSI-69 FLEX | headers 'O/N/CO/He initial ambient composition' | O, N, CO | O2, N2, CO2 (subscripts lost) | ntrs:20130010979 p.10 ('FLEX-145 : ... O2 20% / N2 75% / CO2 5%' matches row 145: 0.2 / 0.75 / 0.05) | use_report_value |
| DQ-18 | PSI-69 FLEX | N2 / CO2 fractions (FLEX Test # 145, C01M201) | N 0.75, CO 0.05 | – | ntrs:20130010979 p.9 says '20% O2 / 75% CO2 / 5% N2'; p.10 of the same deck says 'O2 20% / N2 75% / CO2 5%' | needs_check |
| DQ-19 | PSI-159 ACME CFI-G | rows | 1015 rows | 154 rows with values | none | flag_suspect |
| DQ-20 | PSI-10 ACME/Flame Design | license | (empty) | – | none | needs_check |
| DQ-21 | PSI-25 BASS-II | Fan display | fan setting | – | raw/psi/PSI-25_BASS-II/files/Raw Data/Fan calibration data.xlsx (PSI, downloaded) | needs_check |
| DQ-22 | PSI-25 BASS-II (report) | O2, vol% (GMT45-T1, GMT45-T2) | 18.5 | – | ntrs:20210011385 p.104 footnote b | flag_suspect |
| DQ-23 | PSI-98/99/100 SAFFIRE (report) | footnotes i-iv | (undefined in report) | PSI-99 table Notes 1-4 | PSI-99 experimental table | needs_check |

Status: **use_report_value**, a NASA report gives the value; **flag_suspect**, the value looks wrong and no source corrects it; **needs_check**, unresolved. Full notes are in `manual/data_quality_issues.csv`.
