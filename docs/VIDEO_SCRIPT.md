# FlameSense — Video scripts

From PLAYBOOK_TEAM §6.3–§6.4. Every `[VERIFY: …]` must be replaced with the real number or name
from the app (Ehsanur's numbers sheet) before recording; never round up or guess.
Subtitles: `docs/video/video2.srt`, `docs/video/video3.srt` (English; burn them in).

## Video 2 — 240 s, local judging (due Fri 13 Nov 18:30)

| Time | Screen | Voice | Script |
|---|---|---|---|
| 00:00–00:15 | Gravity Twin: drag gravity from Earth to orbit | Narrator | "This is a flame on Earth. And this is the same flame in orbit. Without gravity, fire changes its shape, its color and its behavior. And NASA is about to put astronauts somewhere fire is even harder to predict." |
| 00:15–00:30 | Members on webcam, names on screen | Each member | "We're Team FlameSense from Rajshahi. I'm [VERIFY: name]. I'm [VERIFY: name]. I'm Ehsanur." |
| 00:30–01:05 | Slides: 21% vs 34% oxygen, Moon graphic | Narrator | "Our challenge is Flame in Freefall: using AI to turn NASA's microgravity combustion data into fire safety insights. Here's why it matters now. To make spacewalks faster, NASA plans Moon habitats with lower pressure and 34 percent oxygen. More oxygen makes materials burn more easily. NASA's own studies call material flammability one of the hardest problems in that atmosphere, and Moon gravity may make some materials even more flammable. But the data is scattered across archives, and almost none of it was collected at Moon or Mars gravity." |
| 01:05–01:30 | Home, then Missions page | Narrator | "FlameSense brings NASA's space-station fire experiments together in one tool. It predicts whether a flame will keep burning and how fast it spreads, checks itself against physics, warns you when it's guessing, and tells NASA where to test next." |
| 01:30–01:55 | Explore: table, one run, its source | Ehsanur | "Everything starts with real data: [VERIFY: N from app_meta.json] test runs from [VERIFY: dataset names from DATA_SOURCES.md]. Every row links back to its NASA source." |
| 01:55–02:25 | Fire Lab: raise oxygen, Compare with Earth, badge, physics card | Ehsanur | "In the Fire Lab I set up a test. More oxygen, and the chance of the flame surviving rises. Compared with Earth, it behaves differently. This badge shows how much NASA data supports the answer, and this card checks the prediction against combustion theory." |
| 02:25–02:45 | Map: switch to Moon gravity; hatched area | Narrator | "This map shows where flames survive. At Moon gravity most of it is hatched. That's the honest answer: NASA has almost no data there yet." |
| 02:45–03:05 | Missions: Artemis lunar habitat, material table, wishlist | Ehsanur | "Mission Mode lists which materials are likely to burn in the Artemis habitat atmosphere, and ranks the five experiments that would teach NASA the most." |
| 03:05–03:35 | Methods page: validation numbers, usability results | Narrator | "FlameSense is trained only on real NASA runs and tested on whole experiment series it never saw: [VERIFY: metric in plain words from metrics.json]. Five people with no technical background tested it: [VERIFY: result from usability.csv]. Where the data is thin, it says so instead of guessing. And the same oxygen physics matters on Earth, in oxygen-rich hospital rooms." |
| 03:35–03:55 | URL and GitHub on screen; members on webcam | Ehsanur, then narrator | "FlameSense is open source and live at flamesense.ehsanur.com. Fire has no 'up' in space, but now it has a map." |

Bangla closing line (subtitled): "মহাকাশে আগুনের কোনো 'উপর' নেই, কিন্তু এখন তার একটা মানচিত্র আছে।"

## Video 3 — 30 s, global judging (due Sat 14 Nov 09:00)

| Time | Screen | Voice-over | Burned-in caption |
|---|---|---|---|
| 00:00–00:04 | Gravity Twin, Earth to orbit | "Fire has no 'up' in space." | Team FlameSense (Rajshahi): [VERIFY: member names per §5] |
| 00:04–00:09 | Missions page | "NASA plans Moon habitats with 34% oxygen, where fire is harder to predict." | Challenge: Flame in Freefall |
| 00:09–00:21 | Fast cuts: Lab, Map at Moon gravity, Wishlist | "FlameSense predicts how flames behave in orbit, on the Moon and on Mars, shows where data runs out, and ranks the experiments NASA should run next." | Predict, map the gaps, plan the next test |
| 00:21–00:26 | Explore table with dataset names | "Built on NASA's ISS combustion data: [VERIFY: dataset names]." | NASA data: [VERIFY: names] |
| 00:26–00:29 | URL and GitHub | "Open source, live now." | flamesense.ehsanur.com, github.com/sujit70777/flamesense |

Check the exported length: video 2 < 4:00, video 3 < 30.0 s.
