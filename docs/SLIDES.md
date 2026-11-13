# FlameSense — Slides (7, English; backup for video 3 and mentors)

One message per slide. Numbers only from the app.

1. **Problem: 34% oxygen habitats.** The Moon base will likely use 30% O₂ or more at 10.2 psi or less
   (challenge statement); NASA recommends 34% O₂ at 8.2 psia (NTRS 20240003211) (ISS: 14.7 psia, 21%). More oxygen makes materials burn more easily, and NASA has almost no fire
   data at Moon or Mars gravity (NTRS 20240003211, 20260003925).
2. **Insight: two flames.** On Earth, rising hot air makes an orange teardrop; in orbit, nothing
   rises, so the flame is a slow blue sphere. (Gravity Twin screenshot, `app/web/og.png`.)
3. **Solution: Missions, Lab, Map.** Pick a mission and see which materials are likely to burn;
   ask "what if" in the Fire Lab; see where flames survive on the map, and where data runs out.
4. **Data and validation.** 123 NASA test runs from BASS, BASS-II, Saffire I–VI and two published papers, each with its
   source. Tested on whole test series the model never saw: error score (Brier) 0.19, against 0.35 for a simple guess.
5. **Physics + ML.** Machine learning learns from the runs; a thin-fuel theory checks it; a
   data-support badge and map hatching show where the model is extrapolating.
6. **Impact.** Mission Fire Brief for planners, the five experiments that would teach NASA the
   most, and lessons for oxygen-rich rooms on Earth.
7. **Team and next steps.** Team FlameSense, Rajshahi (3 members). Next: add partial-gravity
   data as NASA publishes it (FM2 on the Moon), invite researchers to correct data via GitHub.
   Open source: github.com/sujit70777/FlameSense
