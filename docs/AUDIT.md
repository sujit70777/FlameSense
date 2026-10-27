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

- [ ] [B] `python -m flamesense.cli validate` exits 0 on the final data.
- [ ] [B] No synthetic or fixture rows in `app/assets/data/`. How to test: `grep -ri "fixture" app/assets/data` returns nothing; row count in `runs.json` equals `n_runs` in `app_meta.json` equals the processed parquet count.
- [ ] [B] Every row has a non-empty `source_citation` and `source_file`.
- [ ] [B] Unit conversions verified by `[LEAD]` on 5 random rows per source against the raw file (write the 5 run_ids checked in PROGRESS.md).
- [ ] [M] Dropped-row counts and reasons logged for every source.
- [x] [M] Suspect rows are flagged, not deleted, and excluded from training.
- [ ] [M] `docs/DATA_REPORT.md` numbers match the app (Home sentence, Explore count, Methods table).
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

- [ ] [B] Switching to বাং changes every visible string (no English left except scientific terms in parentheses, units, and data values).
- [ ] [M] All Bangla strings reviewed by a native speaker (no `bn-pending` left in `app_bn.arb`).
- [ ] [M] No clipped Bangla glyphs (check headings, buttons, chips, table headers) at 360 and 1440.
- [ ] [M] Numbers use Bangla digits in বাং; units unchanged; decimal separators correct.
- [ ] [m] Locale and theme persist after reload.

## 10. Ask (LLM) quality and safety

- [ ] [B] `ask-eval`: ≥ 80% answerable questions cite a correct document; ≥ 80% unanswerable marked not grounded; 100% injection attempts refused. Record scores.
- [ ] [B] All 12 cached answers (6 EN, 6 BN) reviewed by `[LEAD]` for accuracy; wrong ones replaced.
- [ ] [M] Every citation number in an answer maps to a shown source; no orphan `[Sn]` markers.
- [ ] [M] The model never gives building-specific or spacecraft-specific operational instructions (test 3 such questions).
- [ ] [M] Footnote about AI mistakes visible under every answer.
- [ ] [m] Answer latency p50 < 6 s (10 live questions, record).

## 11. Security and privacy

- [ ] [B] `scripts/check_secrets.sh` passes on repo and `app/build/web`; `git log -p | grep -c "sk-ant-"` is 0.
- [ ] [B] API key only in Cloudflare secret + local `.dev.vars` (gitignored).
- [ ] [B] `/api/ask` rejects: empty, > 500 chars, non-JSON, wrong method (405), unknown origin (403).
- [ ] [M] Rate limit works: 31st request in an hour from one IP returns 429 with `retry_after_s`.
- [ ] [M] Function logs contain no question text, no IP addresses.
- [ ] [M] Anthropic console spend limit set.
- [ ] [M] Security headers from PLAN Phase 16 present on production (`curl -I https://flamesense.ehsanur.com`).
- [ ] [M] No analytics, trackers, cookies, or third-party requests (Network tab shows only own origin).
- [ ] [m] External links open in a new tab with `noopener`.

## 12. Reliability and demo-proofing

- [ ] [B] Production URL works in a private window on a phone using mobile data.
- [ ] [B] If the Anthropic API is unreachable (test by temporarily setting a wrong model id in a preview deploy), Ask still serves cached answers and shows the upstream error for new questions.
- [ ] [M] Demo laptop has: production URL bookmarked, `?tour=1` link bookmarked, local `wrangler pages dev` ready as offline backup, video file stored locally, phone hotspot tested.
- [ ] [M] No console errors on any page (smoke test captures console).
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

## 16. Bangladesh 2026 guide compliance (from the Participants Guide)

Registration and team
- [ ] [B] Bangladesh pre-registration complete and seat confirmed by the Rajshahi Local Lead (in writing).
- [ ] [B] NASA team page: every member listed with photo and role; team photo added (no one under 18 recognisable).
- [ ] [M] Women members listed on the NASA team page (women participation bonus +5%).
- [ ] [B] Every member's age confirmed for 13–14 Nov. Any member under 18: registered by a parent/guardian, guardian present throughout, and no name, face or voice in any video or submission (credited as the Local Lead instructs).
- [ ] [M] All three members registered on both the Bangladesh form and the NASA team page, each with a role.
- [ ] [M] Plan A or Plan B chosen based on the Local Lead's written answer about preparing code early.

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

Score-sheet evidence
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
