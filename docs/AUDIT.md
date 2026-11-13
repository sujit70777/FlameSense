# FlameSense — Release Audit Checklist

Tick a box only after **testing it**, not after reading the code. Each item has a severity:

- **[B] Blocker** — cannot submit or deploy with this open.
- **[M] Major** — must fix before submission unless `[LEAD]` signs a written exception in PROGRESS.md.
- **[m] Minor** — fix if time allows; log if not.

"How to test" is given where it isn't obvious. Record every failure and its fix in `docs/PROGRESS.md`.

---

## 1. Hackathon compliance and legal

- [ ] [B] Official 2026 rules re-read on submission day; code-creation timing rule followed (PLAN §0.3).
- [ ] [B] Team registered for the Rajshahi local event; every member has joined the team on spaceappschallenge.org.
- [ ] [B] Submission includes every required field of the 2026 form (compare `docs/SUBMISSION.md` field by field).
- [ ] [B] AI usage disclosed exactly as the rules require (About page and submission text match).
- [ ] [B] No NASA insignia, worm logo, or Space Apps logo used in the app, favicon, OG image, video, or slides; no wording that implies NASA endorsement. "Not affiliated with or endorsed by NASA" appears on About and in the footer.
- [ ] [B] Every dataset used is listed with its link in DATA_SOURCES.md, the Methods page, README, and submission.
- [ ] [M] Every corpus document's license allows public serving (`license_note` filled for each row of `corpus_meta.csv`; journal papers without redistribution rights removed).
- [ ] [M] Font licenses (SIL OFL) included in `app/assets/fonts/LICENSES/` and shown via `showLicensePage` / About.
- [ ] [M] `LICENSE` (Apache-2.0) present; README states license.
- [ ] [m] Third-party package licenses reviewed (`flutter pub deps`, `npm ls`) — all permissive.

## 2. Data integrity

- [x] [B] `python -m flamesense.cli validate` exits 0 on the final data.
- [x] [B] No synthetic or fixture rows in `app/assets/data/`. How to test: `grep -ri "fixture" app/assets/data` returns nothing; row count in `runs.json` equals `n_runs` in `app_meta.json` equals the processed parquet count.
- [x] [B] Every row has a non-empty `source_citation` and `source_file`.
- [ ] [B] Unit conversions verified by `[LEAD]` on 5 random rows per source against the raw file (write the 5 run_ids checked in PROGRESS.md).
- [x] [M] Dropped-row counts and reasons logged for every source.
- [ ] [M] Suspect rows are flagged, not deleted, and excluded from training.
- [x] [M] `docs/DATA_REPORT.md` numbers match the app (Home sentence, Explore count, Methods table).
- [ ] [M] Digitized rows (`quality_flag=digitized`) double-checked by a second person for 10% of rows.
- [ ] [m] Video-derived rows (if any) have QA plots with R² ≥ 0.95.
- [ ] [m] CSV export from Explore re-imports with identical values (round-trip test).

## 3. Science validity

- [ ] [B] `docs/PHYSICS_SPEC.md` sign-off ticked by `[LEAD]`, or the physics feature shows "unavailable" everywhere.
- [ ] [B] Every equation in the app matches PHYSICS_SPEC.md symbol for symbol.
- [ ] [B] Every science sentence in the app (Home, Lab notices, Map notice, Earth, Methods) reviewed by `[LEAD]`. How to test: export `app_en.arb`, `[LEAD]` initials each science string in PROGRESS.md.
- [ ] [B] All Earth lessons shown have `status: approved`, a reviewer, and at least one working source link.
- [ ] [M] Monotone constraint signs confirmed by `[LEAD]` in QUESTIONS.md.
- [ ] [M] Physics applicability rules enforced (not-applicable state appears for thick solids, concurrent flow, droplets).
- [ ] [M] Claims about Moon/Mars are framed as extrapolation / data gap, never as predictions with confidence.
- [ ] [M] Methods "Limitations" section lists: small dataset, test-series dependence, extrapolation outside tested ranges, physics model simplifications, no operational use.
- [ ] [m] Gravity constants (Moon 0.1652 g, Mars 0.3783 g, from NASA Planetary Fact Sheet) and unit conversion factors double-checked.

## 4. Models and predictor

- [ ] [B] Parity test passes: Dart vs LightGBM within 1e-9 for every exported model.
- [ ] [B] Grouped cross-validation used (or warning shown when groups < 3); metrics in the app equal `metrics.json`.
- [ ] [B] Tasks below the data threshold show the "unavailable" state instead of a prediction.
- [ ] [M] Spread quantiles never cross in the UI (q10 ≤ q50 ≤ q90) across a 1,000-point random input sweep (test).
- [ ] [M] Sustain probability increases (or stays equal) when only oxygen increases, across a 1,000-point sweep (monotonicity test).
- [ ] [M] Data-support badge: inputs equal to a training row → high; far outside → low with outside-range notice (test).
- [ ] [M] Calibration chart and metrics shown on Methods; model card honest about weak metrics if they are weak.
- [ ] [M] Derived features computed identically in Python and Dart (test with 3 hand rows).
- [ ] [m] 1,000 predictions < 200 ms in browser (test).

## 5. UI fidelity and states (every page)

General:
- [ ] [M] No hardcoded colors/font sizes outside `core/theme` (`grep -rn "Color(0x" app/lib --include=*.dart | grep -v core/theme` is empty).
- [ ] [M] No hardcoded user-facing strings in widgets (spot-check 20 widgets; `grep -rn "Text('" app/lib` reviewed).
- [ ] [M] Design rules in DESIGN.md §1.4 respected (no all-caps, no eyebrows, no middle dots, no arrows in buttons, no NASA marks).
- [ ] [M] `/dev/gallery` does not exist in the release build (open `/dev/gallery` on production → Not found page).
- [ ] [m] Visual comparison of every page against DESIGN.md §11 at 1440 and 390, both themes; screenshots in `docs/img/screens/`.

Per page — every listed state reachable and correct:

| Page | Happy | Loading | Empty | Error | Special states |
|---|---|---|---|---|---|
| Home | [ ] | [ ] splash→app seamless | – | [ ] asset error | [ ] reduced motion static flame, [ ] ignition only once per session, [ ] snaps work |
| Explore | [ ] | [ ] skeleton | [ ] no-match filters | – | [ ] one-experiment notice, [ ] run detail dialog + page, [ ] CSV download, [ ] Load in Lab |
| Fire Lab | [ ] | – | – | [ ] numeric field errors | [ ] outside-range, [ ] low support, [ ] partial-g notice, [ ] task unavailable, [ ] physics ok/n-a/near-ext/unavailable, [ ] compare mode, [ ] copy link reproduces state |
| Map | [ ] | [ ] first-draw skeleton | [ ] sustain unavailable | – | [ ] hatching, [ ] contour, [ ] Moon/Mars gap notice, [ ] pinned cell, [ ] Open in Lab |
| Ask | [ ] | [ ] searching skeleton | – | [ ] rate-limit, [ ] upstream, [ ] offline, [ ] invalid | [ ] cached answers, [ ] not-grounded, [ ] citation chip → source highlight, [ ] copy |
| Earth | [ ] | – | [ ] no approved lessons | – | [ ] drafts hidden |
| Methods | [ ] | – | – | – | [ ] equations render, [ ] ToC anchors, [ ] physics sign-off line |
| About | [ ] | – | – | – | [ ] licenses page opens |
| 404 | [ ] | – | – | – | [ ] `/nope` and `/explore/run/does-not-exist` |
| Missions | [ ] | [ ] skeleton | [ ] no sourced missions | – | [ ] unsourced missions hidden in release, [ ] counts match detail page |
| Mission detail | [ ] | [ ] skeleton table + map | [ ] sustain unavailable | – | [ ] verdict colors + text, [ ] data-gap notice, [ ] wishlist 5 diverse picks, [ ] planned-test percentile equals computed value, [ ] CSV, [ ] PDF numbers equal screen, [ ] row → Lab |
| Tour | [ ] all 8 steps | – | – | – | [ ] `?tour=1`, [ ] keyboard, [ ] Esc, [ ] reduced motion |

## 6. Accessibility (WCAG 2.2 AA)

- [ ] [B] Every interactive element reachable and operable by keyboard alone (Tab, Shift+Tab, Enter, Space, arrows on sliders, Esc on dialogs/tour). How to test: unplug the mouse and complete the Judge Tour plus one Lab prediction.
- [ ] [B] Visible focus ring on every focusable element in both themes.
- [ ] [M] Text contrast ≥ 4.5:1 (normal) / 3:1 (large, UI parts) for every token pair actually used. How to test: list pairs from DESIGN.md §3 and check with any WCAG contrast checker; record results.
- [ ] [M] Screen reader (NVDA on Windows or VoiceOver on macOS) reads: nav items, page titles, slider name + value, gauge value, data-support level, chart summary sentences, notices.
- [ ] [M] Icon-only buttons have tooltips and semantic labels.
- [ ] [M] Information never conveyed by color alone (outcomes have text; chart series have shapes; support badge has text).
- [ ] [M] Reduced motion honored everywhere (OS setting on → no flicker, no ignition, no shimmer).
- [ ] [M] Touch targets ≥ 44 × 44 on compact.
- [ ] [m] Page zoom to 200% (browser) keeps everything usable without horizontal page scroll (tables may scroll inside their panel).
- [ ] [m] Dialog focus is trapped and returns to the opener on close.

## 7. Responsive and cross-browser

- [ ] [B] Every page usable at 360, 390, 768, 1024, 1280, 1440, 1920 px — no overflow stripes, no clipped text. How to test: Chrome DevTools device toolbar; `flutter test` overflow tests at 360.
- [ ] [M] Latest Chrome, Edge, Firefox, Safari (macOS) and Chrome Android + Safari iOS: load, navigate, Lab, Map, Ask.
- [ ] [M] Orientation change on a phone keeps state.
- [ ] [M] Browser back/forward works across routes and restores Lab state from the URL.
- [ ] [m] Deep links open directly: `/lab?o2=0.25&g=1e-6`, `/map?g=0.1654`, `/explore/run/<id>`.

## 8. Performance

- [ ] [M] First load transfer ≤ 4.5 MB compressed (DevTools Network, cache disabled). Record the number.
- [ ] [M] Splash visible < 1 s; app interactive < 5 s on "Fast 4G" throttling. Record numbers.
- [ ] [M] Hero drag at 60 fps (no frames > 16 ms in the performance overlay during a 5-second drag).
- [ ] [M] Map recompute < 250 ms; Explore filter < 100 ms. Record numbers.
- [ ] [m] `runs.json` ≤ 1.5 MB; `corpus_chunks.json` not downloaded by the app.
- [ ] [m] CanvasKit self-hosted (`--no-web-resources-cdn`); no requests to gstatic.com in Network tab.

## 9. Language (Bangla) and formatting

- [x] ~~[B] Switching to বাং changes every visible string (no English left except scientific terms in parentheses, units, and data values).~~ N/A: Bangla UI cut (PLAN §1.0); Phase 16 removed the toggle, `app_bn.arb` and the Bengali font.
- [x] ~~[M] All Bangla strings reviewed by a native speaker (no `bn-pending` left in `app_bn.arb`).~~ N/A: Bangla UI cut (PLAN §1.0); Phase 16 removed the toggle, `app_bn.arb` and the Bengali font.
- [x] ~~[M] No clipped Bangla glyphs (check headings, buttons, chips, table headers) at 360 and 1440.~~ N/A: Bangla UI cut (PLAN §1.0); Phase 16 removed the toggle, `app_bn.arb` and the Bengali font.
- [x] ~~[M] Numbers use Bangla digits in বাং; units unchanged; decimal separators correct.~~ N/A: Bangla UI cut (PLAN §1.0); Phase 16 removed the toggle, `app_bn.arb` and the Bengali font.
- [ ] [m] Locale and theme persist after reload.

## 10. Ask (LLM) quality and safety

- [ ] [B] `ask-eval`: ≥ 80% answerable questions cite a correct document; ≥ 80% unanswerable marked not grounded; 100% injection attempts refused. Record scores.
- [ ] [B] All 6 cached answers (English; Bangla cut) reviewed by `[LEAD]` for accuracy; wrong ones replaced.
- [ ] [M] Every citation number in an answer maps to a shown source; no orphan `[Sn]` markers.
- [ ] [M] The model never gives building-specific or spacecraft-specific operational instructions (test 3 such questions).
- [ ] [M] Footnote about AI mistakes visible under every answer.
- [ ] [m] Answer latency p50 < 6 s (10 live questions, record).

## 11. Security and privacy

- [ ] [B] `scripts/check_secrets.sh` passes on repo and `app/build/web`; `git log -p | grep -c "sk-ant-"` is 0. — Phase 16: check_secrets passes on repo + build; the git-log count is 18, all self-references (this line, check_secrets patterns, the `sk-ant-your…` placeholder), no real key.
- [ ] [B] API key only in Cloudflare secret + local `.dev.vars` (gitignored).
- [x] [B] `/api/ask` rejects: empty, > 500 chars, non-JSON, wrong method (405), unknown origin (403). (Phase 16: vitest `handler` suite)
- [x] [M] Rate limit works: 31st request in an hour from one IP returns 429 with `retry_after_s`. (vitest; production needs the RATE_KV id in wrangler.toml)
- [ ] [M] Function logs contain no question text, no IP addresses.
- [ ] [M] Anthropic console spend limit set.
- [ ] [M] Security headers from PLAN Phase 16 present on production (`curl -I https://flamesense.ehsanur.com`).
- [ ] [M] No analytics, trackers, cookies, or third-party requests (Network tab shows only own origin).
- [ ] [m] External links open in a new tab with `noopener`.

## 12. Reliability and demo-proofing

- [ ] [B] Production URL works in a private window on a phone using mobile data.
- [ ] [B] If the Anthropic API is unreachable (test by temporarily setting a wrong model id in a preview deploy), Ask still serves cached answers and shows the upstream error for new questions.
- [ ] [M] Demo laptop has: production URL bookmarked, `?tour=1` link bookmarked, local `wrangler pages dev` ready as offline backup, video file stored locally, phone hotspot tested.
- [x] [M] No console errors on any page (smoke test captures console). (Phase 16: smoke vs local `wrangler pages dev`, 0 errors; re-run on preview)
- [ ] [M] Hard refresh after redeploy loads the new version (cache headers verified).
- [ ] [m] Lab and Map work with the network disconnected after first load.

## 13. Deployment

- [ ] [B] `scripts/smoke.mjs` passes against production.
- [ ] [B] Custom domain active with valid HTTPS (or `*.pages.dev` used consistently in all submission links).
- [ ] [M] `git tag v1.0-submission` pushed; deployed build matches the tag (`app_meta.json` git_sha equals the tag's commit).
- [ ] [M] GitHub repo public; README renders with screenshots; clone + README "Run locally" steps work on a clean machine (test on the second laptop).
- [ ] [m] OG preview correct (paste the URL into a messaging app and check the card).

## 14. Submission and presentation

- [ ] [B] Submitted on spaceappschallenge.org before the deadline; confirmation screenshot saved.
- [ ] [B] Rajshahi local event form submitted (project name, category, team URL, description, NASA data source).
- [ ] [B] Every link in the submission opens in a private window (app, repo, video, slides).
- [ ] [M] Video within the 2026 length limit, captions readable on a phone, no copyrighted music, no NASA logos.
- [ ] [M] Slides ≤ the 2026 limit, each slide one message, numbers match the app.
- [ ] [M] Pitch rehearsed 3 times with a timer; every presenter can run the Tour without notes.
- [ ] [M] Answers prepared for likely judge questions: "How much data?", "How accurate?", "What happens outside the data?", "Why physics and ML?", "Who would use this?", "What's next?"
- [ ] [m] Bangla one-line pitch ready for local judges.

## 15. Ship-readiness after the hackathon (for real-world use)

- [ ] [M] CONTRIBUTING.md and DATA_UPDATE.md written.
- [ ] [M] CI runs all tests on every push.
- [ ] [M] Issue templates for data corrections (run_id, correction, source).
- [ ] [m] Uptime check on the production URL (free monitor) with email alerts.
- [ ] [m] Version and data version shown in About (from `app_meta.json`).
- [ ] [m] Privacy note on About: no personal data collected; questions sent to the AI provider only to generate answers.

---

## 15b. Signature features (graded-by-the-future, evidence, screening)

- [ ] [B] Leakage test passes: holdout (LUCI) rows never touch training, scaling, ranges or support index.
- [ ] [B] Backtest numbers in the app, videos and page equal `backtest.json` exactly, including if the result is weak.
- [ ] [B] FM2 forecast frozen before submission: git tag `fm2-forecast-v1` exists, Zenodo DOI resolves, the app shows the same date, commit and DOI.
- [ ] [B] No finding with a failed quote check or a rejected review is visible anywhere (export check + UI search).
- [ ] [B] Every finding used in the demo, video or interpretation cards is `verified: true`.
- [ ] [M] Verification rate shown on Methods equals `metrics.json.findings`.
- [ ] [M] Consensus "Compare the sources" dialog shows real disagreeing quotes, each with page and link.
- [ ] [M] Screening: sample list works; CSV parser handles quotes/commas/CRLF; 500-row and 1 MB limits enforced; zero network calls during screening (DevTools Network tab empty).
- [ ] [M] Screening PDF numbers equal the on-screen table.
- [ ] [M] Coverage atlas lists every downloaded investigation with an honest `why_not_used`.
- [ ] [M] No claim says NASA has "no" Moon-gravity fire data; copy reflects LUCI (2025) and planned FM2.
- [ ] [m] Conservatism chart shows only sourced pairs; empty state otherwise.

## 15e. Data decisions (2 Nov)

- [x] [B] The solid model never returns a number outside `valid_range`; Missions shows "Outside NASA's tested range" for the Moon base and rover (test with 0.30, 0.34 O₂ and 56.5–70.3 kPa).
- [ ] [B] No numeric FM2 prediction anywhere (app, videos, page); the FM2 card shows the frozen plan and DOI.
- [ ] [B] Every transcribed row (BASS-II Tables 5.1/7.1, Saffire Table 1, SAME tables, LUCI, third-party) is `verified=yes` with doc + page.
- [ ] [B] FLEX burning-rate unit confirmed from FLEX documentation before training; the 0 mmHg row is flagged and excluded.
- [ ] [M] LUCI g-level derivation and pressure assumption are shown on the Forecast page with page references.
- [ ] [M] Data quality report lists every issue in FEASIBILITY §8 with source and status; CSV downloads.
- [x] [M] Sharma 2024 labeled "NASA co-authored"; at least one independent CC BY source transcribed, or the page says none was usable.

## 15f. Prototype review fixes

- [x] [B] Home never shows a predicted spread rate; the same predicted value never appears for 1 g and orbit anywhere.
- [x] [B] Every count in the app equals `app_meta.json`; counts by `source_type` are shown on Methods and Data.
- [ ] [B] `/api/ask` returns JSON in production (not HTML); with the API key removed in a preview deploy, cached answers still work and new questions show the notice. — Phase 16: verified on local Pages runtime without the key (503 JSON, unknown /api/* → JSON 404, widget tests for HTML/stall); production/preview pending wrangler login.
- [x] [B] No empty page or tour step: hide a feature in the registry and confirm nav, Home links and Tour all skip it. (Phase 16: `features_registry_test.dart`; shipped data hides Ask + Earth)
- [x] [B] No language toggle and no `bn-pending` text anywhere. (Phase 16)
- [x] [M] Mission and Home copy say "expected/likely" for Moon-base atmospheres with the statement cited; no "NASA plans" as fact.
- [x] [M] Key findings panel numbers equal the computed values in `app_meta.json`.
- [ ] [M] Wishlist shows the formula and per-term values; labeled "Priority candidate experiments".
- [ ] [M] Model cards show folds, baseline, 95% CI, calibration, Brier, n, and the not-certified statement.
- [ ] [M] Interactive in < 8 s on a real phone over mobile data (record the number).

## 15c. Official statement alignment

- [ ] [B] Every row in `docs/CHALLENGE_REQUIREMENTS.md` is demonstrably working in the deployed app (walk through each one).
- [ ] [B] Every PSI combustion investigation that was downloadable has an Investigation page; none is silently missing.
- [ ] [B] "Varied vs kept the same" is computed from the test matrix, never written by AI; spot-check 3 investigations against their tables.
- [ ] [B] Every AI-written investigation summary is reviewed (`reviewed: true`); every number in a summary appears in its source quotes.
- [ ] [B] Ranking: weights visible and adjustable; "why this rank" terms sum to the shown score; default weights match PLAN Phase 3D.
- [ ] [M] Compare page: computed similarities/differences correct for 2 known pairs (e.g., BASS-II vs FLEX; FLEX vs FLEX-2).
- [ ] [M] Data extractor ZIP opens; CSV row count matches the preview count; dictionary lists every column with unit; citations list every included investigation's DOI.
- [ ] [M] Copy states that PSI has no partial-gravity data; LUCI and FM2 are labeled as NASA reports outside PSI.
- [ ] [M] Gravity bounds shown for every partial-gravity mission row; "biggest unknowns" sort works.
- [ ] [M] Habitats cover all five from the statement (spacecraft, space station, lunar base, Martian base, pressurized rover); unsourced ones hidden in release.
- [ ] [M] Safety tech page covers prevention, detection and suppression, and the four Earth spinoffs with working NASA links.

## 15d. NASA-ready (F24–F26)

- [ ] [M] `/api/v1/` files load; `openapi.yaml` validates; paths are stable.
- [ ] [M] JSON-LD validates (Google Rich Results Test or schema.org validator); `CITATION.cff` validates (`cffconvert --validate`).
- [ ] [M] Cite buttons produce correct BibTeX/APA and always mention the original PSI DOI.
- [ ] [M] `reproduce` run twice on a clean clone gives identical hashes, equal to `app_meta.json`.
- [ ] [M] Offline ZIP runs with Wi-Fi off; Ask shows the offline notice; everything else works.
- [ ] [M] PSI watcher workflow runs manually once (workflow_dispatch) and opens a test issue.
- [ ] [M] Forecast grader scores a fixture correctly; the Forecast page shows a grade only when real results exist.
- [ ] [M] Student and Expert summaries both reviewed for every investigation.
- [ ] [m] `docs/JOURNEY.md` has an entry for every working day, committed by team members.

## 16. Bangladesh 2026 guide compliance (from the Participants Guide)

Registration and team
- [ ] [B] Bangladesh pre-registration complete and seat confirmed by the Rajshahi Local Lead (in writing).
- [ ] [B] NASA team page: every member listed with photo and role; team photo added (no one under 18 recognisable).
- [ ] [M] Women members listed on the NASA team page (women participation bonus +5%).
- [ ] [B] Every member's age confirmed for 13–14 Nov. Any member under 18: registered by a parent/guardian, guardian present throughout, and no name, face or voice in any video or submission (credited as the Local Lead instructs).
- [ ] [M] All three members registered on both the Bangladesh form and the NASA team page, each with a role.
- [ ] [B] Timeline disclosure: README, JOURNEY.md and the NASA page state what was built before and during the event; organizer instructions about timing are saved (screenshots) in `docs/ORGANIZER_NOTES/`.

Videos
- [ ] [B] Video 2 (240 s) uploaded by **Fri 13 Nov 18:30**: YouTube link in the Google Form **and** file in the Local Lead's Drive folder.
- [ ] [B] Video 2 contains: team name, every member's name, problem and challenge statement, solution, **working demo**, NASA datasets **named out loud**.
- [ ] [B] Video 3 under 30 s, on the NASA project page by **Sat 14 Nov 09:00**; contains team name, all names, challenge, demo, NASA data usage.
- [ ] [B] English subtitles burned into every demo video.
- [ ] [B] No names, faces or voices of anyone under 18 in any video or submission.
- [ ] [M] Every third-party or AI-generated asset in the videos credited, with the reason, in the description and on the NASA page.
- [ ] [M] Each video length checked in the file properties (< 240 s, < 30 s). Over-length is cut off.

NASA project page
- [ ] [B] High-Level Summary includes the 240-s video link and the GitHub link.
- [ ] [B] Use of AI names every tool, with prompts, reasoning and data (AI_USAGE.md linked).
- [ ] [B] NASA data sources: each dataset with what it was used for and how.
- [ ] [B] All three Project Details blocks filled; References complete.
- [ ] [B] All links open in a private window; page **Submitted**.
- [ ] [M] Partner-agency or third-party data shown clearly (NASA data usage 5/5).

Official video structures
- [ ] [B] Video 2 follows the four blocks: WHO 0:00–0:45, WHY 0:45–1:45, WHAT 1:45–2:45, SO WHAT NEXT 2:45–4:00; the first 15 s contain the hook.
- [ ] [B] Video 2 shows the demo working in WHAT and again at the close.
- [ ] [B] Video 3: hook 0–5 s, problem 5–12 s, thing working 12–22 s with the NASA dataset name on screen, impact 22–30 s, **ends on the project name**; under 30.0 s.
- [ ] [M] Every story and number in the scripts is true and sourced (team story from the members themselves; numbers from the real numbers sheet).

Score-sheet evidence
- [ ] [M] Usability baseline done: PSI website vs FlameSense times recorded with counterbalanced order; results on Methods and in both videos.
- [ ] [M] At least one expert quote from the target audience, with written permission, quoted exactly.
- [ ] [M] At least one non-NASA source (partner agency or third-party) used and shown with its `source_type` badge.
- [ ] [M] Usability test with ≥ 5 non-developers done; results on Methods page and in video 2.
- [ ] [M] Teamwork evidence: members named and visible in video 2 (under-18 rule permitting), commits from the team, MENTOR_NOTES.md kept.
- [ ] [M] Every claim about NASA atmospheres, FM2, or flammability in the app/videos checked by `[LEAD]` against the NASA source.

## 17. Sign-off

| Area | Checked by | Date/time | Open Blockers | Open Majors |
|---|---|---|---|---|
| 1 Compliance | LEAD | | | |
| 2 Data | LEAD | | | |
| 3 Science | LEAD | | | |
| 4 Models | LEAD | | | |
| 5 UI | LEAD | | | |
| 6 Accessibility | LEAD | | | |
| 7 Responsive | LEAD | | | |
| 8 Performance | LEAD | | | |
| 9 Bangla | TEAM + LEAD | | | |
| 10 Ask | LEAD | | | |
| 11 Security | LEAD | | | |
| 12 Reliability | LEAD | | | |
| 13 Deploy | LEAD | | | |
| 14 Submission | LEAD + TEAM | | | |
| 16 Bangladesh guide | LEAD + TEAM | | | |

Release rule: deploy the submission build only when the "Open Blockers" column is 0 everywhere and "Open Majors" is 0 or has a written exception.
