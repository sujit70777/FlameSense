# FlameSense — Ehsanur's Plan (product, code, data, science)

You own everything inside the product: code (through the coding agent), data, science checks,
in-app content, deployment, and the technical parts of the submission.
The other two team members follow `PLAYBOOK_TEAM.md` (registrations, videos, slides, page text,
usability tests, copy review, device testing). This file says what you hand them, and when.

Source of the rules: *NASA Space Apps Challenge 2026 Bangladesh Participants Guide*. If your Local
Lead says something different, the Local Lead wins.

---

## 1. This week (urgent)

| # | Action | Done |
|---|---|---|
| 1 | Send the email in §1.1 to the Rajshahi Local Lead, Toufiq Elahi Plabon (`event2@basis.org.bd`) | [ ] |
| 2 | Make sure both team members are on the NASA team page and the Bangladesh registration (they handle it; you approve them on the team page) | [ ] |
| 3 | **28 Oct:** read the full *Flame in Freefall* statement; fill `docs/CHALLENGE_REQUIREMENTS.md` and `docs/DATA_SOURCES.md` (PLAN §0.4, §3.0) | [ ] |
| 4 | Create accounts on every data portal the statement links to; download everything offline into `data/raw/` | [ ] |
| 5 | Install and test: Flutter stable, Python 3.11, Node 20+, Git, Wrangler, Claude Code; create the Cloudflare account and the Anthropic API key with a spend limit | [ ] |
| 6 | Follow the rules-compliant plan in §5: **all code is written during the event** (official Space Apps FAQ: teams may begin working at the start of the hackathon). Ask the Local Lead the exact start time on 13 Nov and whether pre-collected, verified data is fine (it's research; we disclose it) | [ ] |

### 1.1 Email to the Local Lead

> Subject: Team FlameSense (Rajshahi): registration check and three questions
>
> Assalamu Alaikum,
>
> We are Team FlameSense, registered for the Rajshahi Local Event on the NASA site, working on the
> challenge "Flame in Freefall". Our team page: [link].
>
> 1. We formed our team after 1 October and did not submit the 240-second prescreening video.
>    Is our seat at the Rajshahi event confirmed? Can we still submit the prescreening video, and where?
> 2. What time on 13 November may teams start building? We'll write all code during the event. We are
>    collecting and checking NASA data and planning beforehand; is that fine as long as we disclose it?
> 3. One member is an HSC candidate who may be under 18. The guide asks us to name every member in the
>    videos but also forbids names, faces and voices of anyone under 18. How should we credit him?
> 4. Is the Rajshahi event in person or virtual this year?
>
> Thank you,
> Ehsanur Rahman, Team FlameSense, mail@ehsanur.com, +880 1747-931646

---

## 2. Deadlines that drive your build

| When (Asia/Dhaka) | What | What it needs from you |
|---|---|---|
| Fri 13 Nov (start time from Local Lead; default 09:00) | Hackathon Day 1 | Create the repo and start Phase 1. No project code exists before this |
| **Fri 13 Nov, by 16:00** | Team starts recording video 2 | **Working, deployed demo** with real numbers |
| Fri 13 Nov 18:30 | Video 2 (240 s) due | Your demo screen recording is in it |
| **Sat 14 Nov 09:00** | Video 3 (30 s) + NASA page submitted | Final technical fields filled; you click **Submit** |
| Sat 14 Nov 11:00 | Local judging | You run the live demo and answer technical questions |

---

## 3. What the product must prove (score sheet)

The score sheet totals 118 points, plus a 5% bonus. The product carries these items:

| Criterion | Points | The product proves it with |
|---|---|---|
| Impact | 20 | Mission Mode for NASA's planned 34% O₂ Moon/Mars habitats, the Experiment Wishlist, the Mission Fire Brief, and the oxygen-rich-rooms lesson for Earth |
| Creativity | 20 | Gravity Twin; an app that recommends NASA's next experiments, not only predictions |
| Validity | 20 | Real data only, citations per row, physics check, grouped validation, extrapolation warnings, usability results on the Methods page |
| Relevance | 20 | The statement's datasets at the core of every screen; every requirement mapped |
| User experience | 5 | Tour, plain language, Bangla, tested with non-experts |
| NASA data usage | 5 | NASA data plus partner-agency or third-party (literature) data, clearly shown |
| Repository open | 1 | Public GitHub repository |

### 3.0 What the official statement asks for (28 Oct)

An AI-powered web dashboard that **summarizes, ranks and interprets PSI combustion investigations** so users can: (1) find the investigations most relevant to spacecraft, space stations, lunar and Martian bases and pressurized rovers; (2) extract data for predictive modeling; (3) highlight research for next-generation fire safety controls and equipment; optionally (4) Earth applications. Audience: professors, students, aerospace researchers and engineers. Key facts it gives: Moon base and rovers likely ≥ 30% O₂ at ≤ 10.2 psi; **PSI has no partial-gravity data**; microgravity and Earth-gravity results could bound intermediate gravity.

**What this changed in the plan:** investigations are now the core of the app (Phases 3D and 9B: summaries, varied-vs-constant, sensors, hardware family, comparison, transparent habitat ranking). Added: a data extractor (ZIP with data dictionary), gravity bounds, a droplet suppression model (FLEX has the best row-level data), the Safety tech & Earth page (prevention, detection, suppression + NASA spinoffs), and a pressurized-rover habitat. The blind test and FM2 forecast stay as the differentiator, labeled as data from NASA reports outside PSI. Every requirement is mapped in `docs/CHALLENGE_REQUIREMENTS.md`.

### 3.0b Score forecast against the official sheet (honest, if the plan is executed well)

| # | Criterion | Max | Rubric's top band asks for | Our evidence | Realistic | Lever to push higher |
|---|---|---|---|---|---|---|
| 1 | Impact | 20 | Major problem, pathway to scale, adoption, **measurable outcomes** | Moon base fire safety; open source; extractor; safety tech | 13–16 | Before/after usability times (PSI site vs FlameSense) + a quoted expert from the target audience |
| 2 | Creativity | 20 | Bold, unexpected connections, sets a new benchmark | Blind test + frozen forecast; Gravity Twin | 14–17 | Make "graded by reality" the headline everywhere |
| 3 | Validity | 20 | Validated data and methods, working prototype, **usability tested**, **clear performance metrics** | Grouped CV, LOEO, blind test, quote checks, usability test | 15–18 | Show metrics on screen in the videos, not just on Methods |
| 4 | Relevance | 20 | NASA data central, creative, **reproducible, transparent data usage** | Every requirement mapped; provenance; extractor; investigations as core | 16–19 | Walk the statement's objectives in order during the demo |
| 5 | Presentation | 20 | Beginning, middle, end; polished; clear English; emotional + intellectual | Videos on the official 240 s / 30 s structures | 12–17 | Rehearse; real team story; Apollo 1 → Moon base arc |
| 6 | Teamwork | 5 | Genuine collaboration | Team runs videos, tests, page; mentor notes; commits | 3–4 | Teammates commit docs/data checks from their own accounts |
| 7 | User experience | 5 | Anyone can use it | Tour, plain language, usability results | 4–5 | Fix every confusion found in testing |
| 8 | NASA data usage | 5 | **NASA data + other agency or third-party data, clearly shown** | PSI + NTRS + challenge resources | 3–5 | Add ≥ 1 clearly labeled non-NASA source (Space Agency Partner or peer-reviewed paper data) |
| 9–11 | Category, repo, page | 3 | Binary | Planned | 3 | Test links privately |
| — | Women bonus | +5% | ≥ 1 woman on the team | Team member on the NASA page | +5% | Make sure she's listed with a role |

Realistic total: **about 83–104 of 118, then +5%** (≈ 87–109). That is a strong local contender and a credible global nominee. Nobody can promise the top score; these levers are where the remaining points are.

### 3.0c Can we reach 118? Will NASA buy it?

**118 out of 118:** no plan can guarantee it. A 20 on Impact, Creativity, Validity, Relevance or Presentation means a judge felt "absolutely wow: I couldn't have imagined it". That is a human judgment, and five judges must all feel it. What we can do is put evidence for the top band of every criterion in front of them, so nothing is lost for a missing item. The binary and small items (category, repo, page, teamwork, UX, data usage, women bonus) should be maxed out completely; they are fully in our control.

**Will NASA buy it?** Honestly, no, and that is not how this works. Space Apps projects must stay open source, so there is nothing to sell. NASA can **use** it, and that is the real prize. A tool NASA people actually use has these properties, which F24–F26 now add:
- It respects their data: credits PSI DOIs first, never alters values, shows provenance for every number.
- It is reproducible: one command rebuilds every number; hashes prove it.
- Other tools can use it: an open API with a spec, FAIR metadata, citations.
- It works where they work: offline ZIP, accessible (WCAG 2.2 AA covers the Section 508 web requirements US agencies follow).
- It keeps itself current: it watches PSI for new investigations (LUCI and FM2 are expected) and grades its own forecast when results arrive.

**Realistic path to NASA eyes:** (1) a global nomination puts the project page in front of NASA experts; (2) after the hackathon, send the live link to the PSI team and the authors of the investigations you used, through their published contact channels, asking for corrections; (3) submit a short abstract about the blind-test method to a gravitational/space research conference (for example, ASGSR's annual meeting accepts student and early-career abstracts). That is how a hackathon tool becomes something researchers cite.

### 3.1 The story the product is built around (all sources are NASA documents; open each one yourself)

- NASA's exploration-atmosphere work recommends **8.2 psia (56.5 kPa) with 34% O₂** for Moon-to-Mars habitats, to shorten pre-breathe before spacewalks. The ISS uses 14.7 psia with 21% O₂. Source: NTRS 20240003211, https://ntrs.nasa.gov/citations/20240003211
- A NASA study of life-support systems at reduced pressure found material flammability to be the hardest problem at 8.2 psia with 34–40% O₂. Source: NTRS 20260003925, https://ntrs.nasa.gov/citations/20260003925
- NASA reports that lunar gravity can widen flammability limits for some materials, and is sending FM2 (Flammability of Materials on the Moon) on a CLPS lander. Sources: NTRS 20240015307, https://ntrs.nasa.gov/citations/20240015307; FM2 test plan at LPSC 2026, NTRS 20260001966.

- The first long fire tests in simulated Moon gravity (LUCI) flew in February 2025 on a spinning Blue Origin New Shepard capsule; NASA's FM2 is planned to burn materials on the Moon itself. Sources: NTRS 20250010653; NASA Glenn LUCI article.
- NASA's own hypothesis: some materials may burn more easily in lunar gravity, which matters for NASA's Earth-gravity material screening method. Source: NTRS 20210020516.

**One-liner (v4):** *The Moon base will breathe 30% oxygen or more, but NASA's space-station data on burning solids stops at 23%. FlameSense summarizes, ranks and interprets every NASA combustion investigation for the habitat you're designing, predicts only where the data supports it, tests itself on experiments it never saw, and shows exactly where NASA needs to test next.*

### 3.2 Why this beats the crowd (research, 28 Oct)

Public GitHub repositories show many teams worldwide on this challenge already building the obvious version: mission presets for ISS/Moon/Mars, an evidence-gap map, a grounded AI chat, a scenario brief, flame visuals, droplet models on FLEX. If FlameSense only does that, it looks like everyone else. The four things almost nobody is doing:

1. **Graded by reality, honestly:** the FLEX chronological blind test (real statistics, 274 rows), the LUCI bounds case study, the frozen FM2 test plan with a DOI, and the 23%-vs-30%+ oxygen gap made visible (Phase 5B, PLAN §1.0).
2. **FireFacts:** structured, verbatim-checked findings with consensus and conflict, ranked per mission (Phase 12B). This is the challenge's "summarize, rank, interpret" done rigorously.
3. **Material screening:** the real engineer workflow, a list in, a test plan out (Phase 11C).
4. **Coverage atlas:** every PSI combustion investigation indexed, including honest reasons why some can't feed a model (Phase 3C).

With the official statement, the order is: **answer the ask** (Investigations hub: summarize, rank, compare), **prove it** (blind test + frozen forecast, FireFacts), **show the user value** (screening, extractor, safety tech). The Gravity Twin stays as the 5-second hook.

### 3.3 Data reality (from teams who already downloaded it)

- The BASS-II experimental table has 129 solid-fuel tests but **no flame-spread-rate column**; spread rates must come from reports (digitize) or video.
- The FLEX droplet table has 274 rows with a test-end label (extinction, disruption, completion), which supports a real droplet model.
- Several PSI tables don't carry a row-level outcome label, so they can't train a model directly. The coverage atlas says so instead of hiding it.

Verify all of this yourself on 28–29 Oct; plan the models around what is really there.

---

## 4. Science work you now own

These tasks are yours. Do them **before** the phases that need them. They are the difference between a Validity score of 10 and one of 18.

| Task | File | Needed by | How |
|---|---|---|---|
| Map raw columns to the schema, answer agent questions | `docs/QUESTIONS.md` | Phase 2 | Read each raw file's documentation; never guess a unit |
| Digitize tables from papers (if the statement data is thin) | `data/manual/*.csv` | Phase 2 | Exact §3.1 columns, `quality_flag=digitized`, a citation on every row; re-check 10% of the rows the next day |
| Physics parameters with sources | `data/manual/physics_params.json` | Phase 4 | Take values from published microgravity flame-spread papers (de Ris 1969 thin-fuel theory and later NASA work). Write the source next to every number. Leave `null` if you can't source it; the app then shows "physics check unavailable" |
| Physics sign-off | `docs/PHYSICS_SPEC.md` | Phase 4 | Compare every symbol and unit with the source. Optional: ask a Space Apps mentor with a physics or mechanical background to read it |
| Monotone-constraint signs | `docs/QUESTIONS.md` | Phase 5 | Confirm: more O₂ never lowers burning chance or spread; thicker fuel never speeds spread. If unsure, use 0 (no constraint) |
| Mission presets | `data/manual/missions.json` | Phase 11B | A draft with sources is already in the repo folder (`data/manual/missions.json`). Open every source and confirm each number, then set `"signed_off_by_lead": true` |
| Third-party / partner data (NASA data usage 5/5) | `data/manual/third_party/` + DATA_SOURCES `source_type` | Phase 2 | Add at least one clearly labeled non-NASA source: data from a Space Agency Partner (check JAXA, ESA, CSA microgravity combustion publications, e.g., JAXA's FLARE project) or tables from a peer-reviewed paper. Verify the license; cite it |
| Safety tech content draft | `data/manual/lessons_draft.md` | Phase 13 | Write each item only from a cited source: pillar insights (prevention, detection, suppression), the 4 NASA spinoffs from the challenge Resources tab, Apollo 1, Apollo 13 and Mir lessons |
| Cached Ask answers | `app/assets/data/ask_cache.json` | Phase 12 | Read all 12 answers against their cited pages; replace any wrong question |
| Download all PSI combustion investigations | `data/raw/psi/` | Phase 3C | Every investigation's metadata + experimental table, not just BASS-II and FLEX (use `docs/PREP_PROMPTS.md`) |
| Investigation summaries and mappings | `investigations.json` review | Phase 3D | Read every AI summary against its quotes; confirm hardware family, pillars and measurements for each investigation |
| Droplet monotone signs | `docs/QUESTIONS.md` | Phase 5 | Confirm: more CO₂ or helium never lowers extinction chance; more O₂ never raises it |
| Safety tech content | `lessons.json` | Phase 13 | Pillar insights + the 4 NASA spinoffs + Apollo 1, Apollo 13, Mir (all links are in the challenge Resources tab) |
| LUCI holdout data | `data/manual/holdout_luci.csv` | Phase 5B | Digitize LUCI's lunar-gravity oxygen limits per material from NTRS 20250010653 (and any LUCI paper). Two digitizing passes on different days; keep both files; use their average and note differences |
| Oxygen limits pairs (optional) | `data/manual/o2_limits.csv` | Phase 5B | Only values printed in NASA sources, with page numbers |
| FM2 test-plan freeze | git tag `fm2-plan-v1` + Zenodo DOI | Phase 5B, on 9 Nov | A plan of checks, no numeric predictions (PLAN §1.0); never edit a frozen plan |
| FireFacts verification | `docs/FINDINGS_REVIEW.csv` | Phase 12B | Verify every finding in the demo flow + at least 20% of the rest. Reject anything not exactly supported by its quote |
| Mission interpretations | `findings.json` | Phase 12B | Read each 3-sentence "What this means" against its cited findings |
| Every science sentence in the app, videos and NASA page | ARB files, scripts | Phase 14 and 17 | Read each one against its source |

---

## 5. The plan (rules-compliant): prepare everything except code, then build fast

### 5.1 Allowed before the event, and how it speeds you up

| Prep (before 13 Nov) | Why it's allowed | Time it saves on Friday |
|---|---|---|
| All plans, designs, prompts (PLAN, DESIGN, AUDIT, CLAUDE.md) | Planning is allowed | The agent never has to think |
| Data downloaded, transcribed, verified twice (PREP_PROMPTS rounds 1–2) | Research and data collection; disclosed in JOURNEY.md and README | 5–8 hours of the most error-prone work |
| Curated investigation facts (instruments, sizes) verified | Research notes | 3 hours |
| Physics parameters with sources, `missions.json` with sources | Research | 2 hours |
| Accounts: GitHub, Cloudflare (Pages project name reserved, DNS ready), Anthropic key with spend limit, Zenodo | Environment setup (the guide asks for it) | 1 hour |
| Toolchain installed and tested; fonts downloaded | Environment setup | 1 hour |
| Video scripts, narration rehearsal, title-card template, slide template | The guide says to start the slide template and demo script before day one | 3 hours for the team |
| Testers and an expert booked for Fri 19:00–22:00 | Logistics | – |
| Practice Claude Code on an **unrelated** toy project (parallel sessions, git worktrees) | Skill, not project work | Faster, calmer Friday |

**Do not before the event:** create the FlameSense repo, write or generate any project code, deploy anything, run the FireFacts extraction or train models, or freeze the FM2 plan / mint the DOI. These happen during the event, so every timestamp proves the project was built there.

### 5.2 Prep calendar

| Date | You |
|---|---|
| 3 Nov | PREP Round 2 prompts 8–11; download the CC BY papers; send the Local Lead email |
| 4–5 Nov | Verify transcriptions (pass 1); curate instruments; confirm FLEX burning-rate unit |
| 6–7 Nov | Verify transcriptions (pass 2, other day); digitize LUCI values twice; physics params; `missions.json` |
| 8 Nov | Accounts and environment check; practice parallel Claude Code sessions on a toy project |
| 9 Nov | Read DESIGN.md end to end; write the real-numbers sheet template; final prep bundle (Prompt 7) |
| 10–11 Nov | Rehearse the event plan: time yourself reading each phase prompt; rest |
| 12 Nov | Rest. Sleep early |

### 5.3 Event build (all code), with two parallel agent sessions

Run **two Claude Code sessions** in separate git worktrees: **A = pipeline + functions**, **B = Flutter app**. You review and merge.

| Fri 13 Nov | Session A (pipeline) | Session B (app) | You |
|---|---|---|---|
| Start (≈ 09:00) | Phase 1 scaffold (shared), then 2, 3 with the verified prep data | wait for scaffold, then Phase 6 foundation | Create repo; copy prep bundle; JOURNEY entry |
| +1 h | 3C, 3D (investigations data; AI summaries generated) | 6 continues | Review summaries as they arrive |
| +2.5 h | 5 (FLEX droplet model + solid logistic), 5B step 3 (FLEX blind test) | 7 (predictor + logit evaluator), 8 (Home) | Mentor round (15 min max) |
| +4 h | 16 steps 1–6 (first deploy) | 9B (Investigations list + detail) | – |
| +5.5 h | – | 10 (Suppression Lab), 11 (Map with the gap) | Check numbers |
| ≈ 16:00 | **Deploy Tier 1** | – | Record demo clips for video 2 |
| 16:00–18:30 | 12 corpus + Ask (cached), 11B (Missions) | Compare page (9B), 9 (Data + extractor) | Team edits video 2 → **upload 18:30** |
| 19:00–22:00 | 12B FireFacts (top 25), 5B step 4 (LUCI bounds), F27 data-quality | 13 (Safety tech, Methods, About, Tour), 11.25 | Usability tests + expert run by the team on the live link |
| 22:00–02:00 | 5B steps 5–6: **freeze FM2 plan, tag, Zenodo DOI** (now, during the event); 16B static API + CITATION.cff | 14 polish, 15 audit Blockers | Add usability results; redeploy |
| 02:00–06:00 | Sleep | Sleep | Sleep |
| Sat 06:00–08:30 | Final deploy; smoke test | – | Real-numbers sheet to team; check page fields |
| **Sat 09:00** | – | – | **Submit NASA page; video 3 linked** |
| 10:00–11:00 | – | – | Rehearse; 11:00 local judging |

**Tier 1 (must exist by 16:00 Friday for video 2):** Home (Gravity Twin), Investigations list + detail with ranking, Suppression Lab (FLEX), Map with the 23%-vs-30% gap, deployed. **Tier 2 (by Sat 02:00):** Compare, Data + extractor, Missions, Evidence (25 verified findings), Reality checks (FLEX blind test, LUCI bounds, frozen FM2 plan), Safety tech, Methods, Tour, data-quality report. **Tier 3 (only if time):** static API, CITATION.cff, changelog, PSI watcher, screening, Student/Expert toggle. Never cut Tier 1 or the honesty features.

## 6. Handoffs to the team (they can't do their part without these)

| What | When (event) | Format |
|---|---|---|
| One-liner + challenge name | 28 Oct / 28 Oct | WhatsApp message |
| Staging URL | Fri 16:00 | Link |
| String export for copy review | skip | Google Sheet: key, English, Bangla, notes column for their fixes |
| Usability test build + 3 tasks | Fri 19:00 | Link + PLAYBOOK_TEAM §7 |
| **Real numbers sheet** (runs, experiments, materials, dataset names, key metric in plain words, usability results) | Fri 16:00 | Short doc; video scripts use only these numbers |
| Production URL + screenshots (dark and light) | Fri 16:00 | Link + PNGs from `docs/img/screens/` |
| Demo screen recordings (1080p, dark theme, cursor highlighted, no voice) | Fri 16:00–17:00 | MP4 per segment: Home, Explore, Lab, Map, Missions, Methods |
| `SUBMISSION.md`, `AI_USAGE.md`, `VIDEO_SCRIPT.md`, `.srt` drafts | Fri 22:00 | Repo files (send links) |
| GitHub repo link (public) | Fri 16:00 | Link |

---

## 7. Your part of the submission

- Technical NASA page fields you check yourself: Final Project (URL, repo), NASA data sources (each dataset, what for, how), tools and technologies, Use of AI (from `AI_USAGE.md`; it must list every AI tool, the prompts, the reasoning and the data the AI worked on).
- The team writes and polishes the rest from `SUBMISSION.md`. You read the final page once, in a private window, then click **Submit** before Sat 09:00.
- Keep the repo public and the site live through December/January, because global judging happens then.

---

## 8. Technical questions judges may ask (fill the numbers on the day)

| Question | Answer |
|---|---|
| How much data? | "[N] runs from [M] NASA experiments, each linked to its source." |
| How accurate? | "On whole experiment series the model never saw: [metric in plain words]." |
| Outside the data? | "The badge drops to low, the map is hatched, Mission Mode says 'unknown'." |
| Why physics and ML? | "ML learns from real runs; physics is an independent check and shows where simple theory breaks." |
| How does this answer the challenge? | "Summarize: every PSI investigation has a page with objectives, fuels, conditions, what varied, and what was measured. Rank: a transparent formula per habitat you can adjust. Interpret: findings with consensus, gravity bounds, and insights for prevention, detection and suppression." |
| PSI has no Moon-gravity data. How can you say anything about the Moon? | "We don't pretend to. We show microgravity and Earth-gravity results as bounds, as the challenge suggests, and we tested our method on NASA's 2025 simulated-Moon-gravity results, which aren't in PSI yet." |
| Why should we trust your predictions? | "Only where NASA has data. On FLEX tests the model never saw it scored [metric]. Above 23% oxygen there is no NASA solid data, so we don't predict; we show the gap and froze a public plan to check NASA's Moon results." |
| What if the backtest was poor? | "Then we say so. It shows exactly how little we know about fire on the Moon, which is why FM2 matters." |
| How do you stop the AI inventing facts? | "Every extracted finding must contain a quote that matches the source word for word, or code rejects it. I verified every finding we show." |
| Is the wishlist real science? | "It's a ranking aid: least certain, least covered conditions. NASA scientists still design experiments." |
| How did you use AI? | "A coding agent wrote code under my review, phase by phase; every prompt is in AI_USAGE.md. The Ask feature uses Claude only over retrieved NASA documents. The predictions are LightGBM models trained on NASA data." |
| What's next? | "Add FM2 and other new results as they're published; open data corrections on GitHub." |

---

## 9. Your final checklist

- [ ] All AUDIT.md Blockers closed; Majors closed or excepted in writing
- [ ] Every number in the app traceable to a source; every science sentence checked by you
- [ ] `missions.json` and `physics_params.json` signed off (or features shown as unavailable)
- [ ] LUCI values digitized twice; FLEX blind test and LUCI bounds test published as computed; FM2 test plan frozen with tag + DOI
- [ ] FireFacts verification done for all demo findings + ≥ 20% of the rest
- [ ] Production URL works on a phone over mobile data; repo public; `check_secrets.sh` passes
- [ ] Handoffs in §6 delivered on time
- [ ] Demo rehearsed 3 times; the Tour runs without notes
- [ ] NASA page technical fields checked; **Submitted** before Sat 09:00
