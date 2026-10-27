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
| 6 | Decide Plan A or Plan B (§5) as soon as the Local Lead answers question 2. If no answer by 10 Nov, use Plan B | [ ] |

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
> 2. May we prepare project code before the hackathon starts on 13 November (in a public repository),
>    or must all project code be written during the event?
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
| Fri 13 Nov 07:00 | Hackathon Day 1 | Plan A: deployed app. Plan B: start Phase 1 |
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

### 3.1 The story the product is built around (all sources are NASA documents; open each one yourself)

- NASA's exploration-atmosphere work recommends **8.2 psia (56.5 kPa) with 34% O₂** for Moon-to-Mars habitats, to shorten pre-breathe before spacewalks. The ISS uses 14.7 psia with 21% O₂. Source: NTRS 20240003211, https://ntrs.nasa.gov/citations/20240003211
- A NASA study of life-support systems at reduced pressure found material flammability to be the hardest problem at 8.2 psia with 34–40% O₂. Source: NTRS 20260003925, https://ntrs.nasa.gov/citations/20260003925
- NASA reports that lunar gravity can widen flammability limits for some materials, and is sending FM2 (Flammability of Materials on the Moon) on a CLPS lander. Sources: NTRS 20240015307, https://ntrs.nasa.gov/citations/20240015307; FM2 test plan at LPSC 2026, NTRS 20260001966.

**One-liner:** *NASA is about to put astronauts in 34% oxygen on the Moon. FlameSense uses NASA's space-station fire data to show which materials are likely to burn there, where the data runs out, and which experiments NASA should run next.*

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
| Earth lessons | `data/manual/lessons_draft.md` | Phase 13 | Write each lesson only from a cited source. Lead with oxygen-enriched rooms on Earth (hospital oxygen therapy, home oxygen cylinders), as general guidance from official fire-safety or medical sources |
| Cached Ask answers | `app/assets/data/ask_cache.json` | Phase 12 | Read all 12 answers against their cited pages; replace any wrong question |
| Every science sentence in the app, videos and NASA page | ARB files, scripts | Phase 14 and 17 | Read each one against its source |

---

## 5. Build plans

### Plan A: preparing code before 13 Nov is allowed

| Date | Phases (PLAN.md) | Your science/content tasks the same day | Hand to the team |
|---|---|---|---|
| 26–27 Oct | – | §1 urgent list; start reading physics sources | – |
| 28 Oct | – | Requirements, data sources, download | Send them the challenge name and one-liner (§3.1) |
| 29–30 Oct | 1, 2, 3 (+3B if video data) | Column mapping, digitizing | – |
| 31 Oct – 1 Nov | 4, 5 | Physics params + sign-off; monotone signs | – |
| 2–3 Nov | 6, 7 | Verify `missions.json` sources | – |
| 4 Nov | 8, 9 | – | **Staging URL** for their first look and device testing |
| 5 Nov | 10 | – | – |
| 6 Nov | 11, 11B | – | – |
| 7 Nov | 12 | Check cached answers | – |
| 8 Nov | 13 | Lessons | **String export** (English + Bangla) for their copy review |
| 9 Nov | 14 | Apply their copy fixes | Usability test version (they run the sessions) |
| 10 Nov | 15, 16 | Add usability results (`data/manual/usability.csv`) | **Production URL**, screenshots, real numbers sheet (§6) |
| 11 Nov | 17 (agent drafts README, SUBMISSION, AI_USAGE, scripts, `.srt`) | Read all science claims | `SUBMISSION.md`, `VIDEO_SCRIPT.md`, demo screen recordings |
| 12 Nov | Freeze | Rehearse the demo (Tour) 3 times | – |
| 13–14 Nov | Fixes only | – | Join mentor rounds; record the demo; final technical fields; Submit |

Code freeze: **11 Nov 23:59**. After that, only fixes for audit Blockers or mentor feedback.

### Plan B: all code must be written during the event (about 26 hours)

**Keep:** Phases 1, 2, 3, 5, 6, 7, 8, 10, 11, a simple Missions table (11B steps 1, 2, 5), 16.
**Cut first:** Ask live API (keep 6 cached answers), Bangla, Tour, Brief PDF, video tracking, Methods charts (keep tables), Wishlist (add back Friday night if time allows).
Do the science tasks in §4 **before** 13 Nov anyway. Reading sources and filling JSON values isn't code.

| Fri 13 Nov | You |
|---|---|
| 07:00–08:30 | Registration; agent runs Phase 1 |
| 08:30–10:30 | Phases 2, 3, 5 |
| 10:30–11:30 | Keep the agent running while the team attends the opening |
| 11:30–12:30 | Phase 6 (join the mentor round for 10 minutes) |
| 12:30–15:00 | Phases 7, 8, 10 |
| 15:00–16:00 | Phase 11 + simple Missions table; **first deploy** |
| 16:00–17:00 | Record the demo screen recording per the video 2 script; hand it to the team |
| 17:00–23:00 | Explore, Ask (cached), Earth, Methods, About; redeploy |
| 23:00–03:00 | Wishlist if time; audit Blockers; redeploy; technical page fields |
| 03:00–07:00 | Sleep |
| Sat 07:00–09:00 | Final check of the page; **Submit by 09:00** |
| 10:00–11:00 | Rehearse the live demo |

---

## 6. Handoffs to the team (they can't do their part without these)

| What | When (Plan A / Plan B) | Format |
|---|---|---|
| One-liner + challenge name | 28 Oct / 28 Oct | WhatsApp message |
| Staging URL | 4 Nov / Fri 16:00 | Link |
| String export for copy review | 8 Nov / skip | Google Sheet: key, English, Bangla, notes column for their fixes |
| Usability test build + 3 tasks | 9 Nov / Fri 19:00 | Link + PLAYBOOK_TEAM §7 |
| **Real numbers sheet** (runs, experiments, materials, dataset names, key metric in plain words, usability results) | 10 Nov / Fri 16:00 | Short doc; video scripts use only these numbers |
| Production URL + screenshots (dark and light) | 10 Nov / Fri 16:00 | Link + PNGs from `docs/img/screens/` |
| Demo screen recordings (1080p, dark theme, cursor highlighted, no voice) | 11 Nov / Fri 16:00–17:00 | MP4 per segment: Home, Explore, Lab, Map, Missions, Methods |
| `SUBMISSION.md`, `AI_USAGE.md`, `VIDEO_SCRIPT.md`, `.srt` drafts | 11 Nov / Fri 22:00 | Repo files (send links) |
| GitHub repo link (public) | 10 Nov / Fri 16:00 | Link |

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
| Is the wishlist real science? | "It's a ranking aid: least certain, least covered conditions. NASA scientists still design experiments." |
| How did you use AI? | "A coding agent wrote code under my review, phase by phase; every prompt is in AI_USAGE.md. The Ask feature uses Claude only over retrieved NASA documents. The predictions are LightGBM models trained on NASA data." |
| What's next? | "Add FM2 and other new results as they're published; open data corrections on GitHub." |

---

## 9. Your final checklist

- [ ] All AUDIT.md Blockers closed; Majors closed or excepted in writing
- [ ] Every number in the app traceable to a source; every science sentence checked by you
- [ ] `missions.json` and `physics_params.json` signed off (or features shown as unavailable)
- [ ] Production URL works on a phone over mobile data; repo public; `check_secrets.sh` passes
- [ ] Handoffs in §6 delivered on time
- [ ] Demo rehearsed 3 times; the Tour runs without notes
- [ ] NASA page technical fields checked; **Submitted** before Sat 09:00
