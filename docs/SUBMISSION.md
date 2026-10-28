# FlameSense — NASA Space Apps 2026 project page (draft)

One section per field of the NASA project page (PLAYBOOK_TEAM §9.1). The team turns this into
clear English on the page; Ehsanur checks technical fields and submits. **[VERIFY]** marks every
fact the agent could not confirm from the repository (numbers appear only after real data is
added; never round up or guess).

Challenge: **Flame in Freefall: AI-Powered Fire Safety Insights from Microgravity Combustion Data**
Team: **FlameSense** (Rajshahi) — members [VERIFY per the under-18 rule]

---

## High-Level Summary

NASA plans Moon and Mars habitats with lower pressure and 34% oxygen, where materials burn more
easily and NASA has almost no fire data. FlameSense brings NASA's space-station fire experiments
together in one open tool. It shows how a flame changes without gravity, predicts whether a flame
keeps burning and how fast it spreads, checks itself against combustion physics, warns when it is
extrapolating, and ranks the experiments that would teach NASA the most. It helps spacecraft
fire-safety researchers, students and teachers, and people who work in oxygen-rich rooms on Earth.

- 240-second video: [VIDEO2_URL]
- Code: [GITHUB_URL] (https://github.com/sujit70777/FlameSense)

## Project Demo

30-second video: [VIDEO3_URL]

## Final Project

- Live app: https://flamesense.ehsanur.com [VERIFY after deploy; fallback https://flamesense.pages.dev]
- Source code and README: https://github.com/sujit70777/FlameSense
- Judge tour: https://flamesense.ehsanur.com/?tour=1

## Project Details — 1. Why, what and how

**Why.** On Earth, rising hot air stretches a flame into a teardrop and pulls fresh air in. In
orbit nothing rises, so flames turn round, blue and slow, and can survive in weak airflow. NASA's
exploration atmosphere (8.2 psia / 56.5 kPa, 34% O₂) makes material flammability harder still
[VERIFY sources: NTRS 20240003211, 20260003925, 20240015307 per PLAYBOOK_LEAD §3.1].

**What.** A web app with nine parts: the Gravity Twin hero, a Data Explorer of every run with its
source, a Fire Lab for "what if" predictions, a Flammability Map of oxygen × airflow, Mission
Mode for ISS, Artemis lunar, Mars transit and Mars surface atmospheres, an Experiment Wishlist,
a one-click Mission Fire Brief (PDF), Ask the NASA papers (answers with citations), Earth
lessons, and a Methods page that shows the data, models, validation and limits.

**How.**
1. A Python pipeline ingests NASA data into one canonical table (one row per test run, with
   its source file and citation), cleans it, flags suspect rows, and adds derived features.
2. LightGBM models (sustain probability; 10th/50th/90th-percentile spread) are trained with
   grouped cross-validation by test series and exported as JSON trees that run in the browser
   (checked against LightGBM to 1e-9).
3. A k-nearest-neighbour "data support" index tells the user when a prediction is far from
   any NASA run; outside the tested range the app says it is extrapolating.
4. A thin-fuel opposed-flow theory (de Ris 1969) and the buoyant velocity give a physics check,
   switched off until its parameters are sourced and signed off.
5. Ask uses BM25 retrieval over NASA documents and the Claude API, with every sentence cited.

**Requirement by requirement.** [VERIFY: copy the table from `docs/CHALLENGE_REQUIREMENTS.md`
once the lead fills it from the full challenge statement.]

**Datasets in detail.** [VERIFY: one paragraph per row of `docs/DATA_SOURCES.md` — name, link,
files, what FlameSense used, how it was mapped, rows kept and dropped.]

## Project Details — 2. Who benefits

- **Spacecraft fire-safety researchers:** every run in one place, the map of where flames
  survive, and where the data runs out (Moon and Mars gravity).
- **Mission planners:** worst-case verdicts per material for each mission atmosphere, and five
  ranked test conditions with a CSV test matrix and a PDF brief.
- **Students and teachers:** the Gravity Twin, plain-language explanations, a guided tour, and
  Bangla.
- **Earth fire safety:** lessons for low-airflow and oxygen-rich rooms, with sources.

Highlighted features: Gravity Twin; Experiment Wishlist; data-support badge and hatching on
the map; Mission Fire Brief.

Usability results: [VERIFY: from `data/manual/usability.csv` — testers, tasks, completion,
median times, and what changed after testing.]

## Project Details — 3. Tools and technologies

Flutter Web (Material 3, Riverpod, go_router, fl_chart, flutter_math_fork, pdf), Python
(pandas, NumPy, LightGBM, scikit-learn, matplotlib, pypdf), Cloudflare Pages + Pages Functions
(TypeScript) with KV rate limiting, the Anthropic Claude API, Archivo and Noto Sans Bengali
fonts (SIL OFL 1.1). Code is Apache-2.0.

## Use of AI

See `docs/AI_USAGE.md` (linked from the README). Summary: a coding agent (Claude Code) wrote the
code under Ehsanur's review, with every prompt listed; the Ask page uses the Claude API only over
retrieved NASA documents (system prompt included); predictions use LightGBM models trained on
NASA data; no images or voices in the app are AI-generated. [VERIFY for videos and slides.]

## NASA data sources

[VERIFY: for each dataset in `docs/DATA_SOURCES.md` — name, link, what it was used for, how.]
Partner-agency or third-party (literature) data, listed separately: [VERIFY].

## References

- NASA Technical Reports Server: NTRS 20240003211, 20260003925, 20240015307, 20260001966 [VERIFY]
- de Ris, J. N. (1969). Spread of a laminar diffusion flame. *Proc. Combust. Inst.* 12. [VERIFY]
- Data sources: see `docs/DATA_SOURCES.md` [VERIFY]
- Libraries: Flutter, flutter_riverpod, go_router, fl_chart, flutter_math_fork, pdf,
  shared_preferences, url_launcher, http, intl, web; pandas, numpy, pyarrow, lightgbm,
  scikit-learn, matplotlib, pypdf, pyyaml; TypeScript, vitest, Wrangler, Playwright.
- Fonts: Archivo (Omnibus-Type), Noto Sans Bengali (Google), SIL OFL 1.1.
- NASA Planetary Fact Sheet (Moon 1.62 m/s², Mars 3.71 m/s²).
