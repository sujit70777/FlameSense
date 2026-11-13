# Statement summary — "Flame in Freefall" (NASA Space Apps 2026)

Sources read (2026-11-02), all from the FlameSense repo:
- `CHALLENGE_STATEMENT.md` (repo root; `docs/CHALLENGE_STATEMENT.md` is an empty file)
- `RESOURCES.md` (repo root)
- `docs/CHALLENGE_REQUIREMENTS.md`: header row only, no requirements filled in yet

Nothing has been downloaded or opened online. Everything below comes from these files. Where
the statement is silent, this file says **not stated** instead of guessing.

## a) Objectives (quoted)

Core ask: "build an AI-powered, web-based dashboard that summarizes, ranks, and interprets
combustion science investigations to deliver critical foundational insights for fire safety."

1. "Identify investigations most relevant to the fire safety needs of habitable crew environments,
   including spacecraft, space stations, bases on the lunar and Martian surfaces, and pressurized rovers."
2. "Extract data that supports predictive modeling of flammability and fire scenarios in space exploration."
3. "Highlight research that informs the development of next-generation fire safety controls and equipment."
4. Optional Earth objective: "Your dashboard could also address potential applications of the PSI
   data to fire safety on Earth." (Examples given: ISS fine-water-mist extinguishers, smoke
   detection, firefighter protective clothing and air tanks.)

Scope note: "Fire safety involving rockets and propellants is generally beyond the scope of the
research available in the PSI database."

## b) Investigations named in the statement

Hardware families are those the statement gives. Pillar basis: **stated** means the statement
links the investigation to that pillar. **Inferred** means the pillar follows from the
statement's description but is not named there; [LEAD] should confirm it.

| Investigation | Full name (as in statement) | Fuel type (statement) | Hardware family (statement) | Pillar | Basis |
|---|---|---|---|---|---|
| BASS | Burning and Suppression of Solids | solid (+ gaseous across the MSG group) | MSG-SPICE duct | prevention | stated: flammability of solids |
| BASS-II | Burning and Suppression of Solids II | solid (+ gaseous across the MSG group) | MSG-SPICE duct | prevention | stated |
| Saffire-I | Spacecraft Fire Safety Demonstration | solid materials | not stated | prevention | stated |
| Saffire-II | Spacecraft Fire Safety Demonstration | solid materials | not stated | prevention | stated |
| Saffire-III | Spacecraft Fire Safety Demonstration | solid materials | not stated | prevention | stated |
| SAME | Smoke and Aerosol Measurement Experiment | smoke / aerosol | not stated | detection | stated |
| SAME-R | Smoke and Aerosol Measurement Experiment (R) | smoke / aerosol | not stated | detection | stated |
| FLEX | Flame Extinguishment Experiment | liquid droplets | CIR-MDCA | suppression | stated: CO₂ and helium dilution |
| FLEX-2 | Flame Extinguishment Experiment 2 | liquid droplets | CIR-MDCA | suppression? | inferred from FLEX; statement gives no pillar |
| CFI | Cool Flames Investigation | liquid droplets | CIR-MDCA | none stated | – |
| ACME (project) | Advanced Combustion via Microgravity Experiments | gaseous fuels; "six experiments" | CIR-ACME | – | – |
| ACME BRE | Burning Rate Emulator | gaseous (emulating solids) | CIR-ACME | prevention | inferred: "a study of materials flammability in still atmospheres" |
| ACME CFI-G | Cool Flames Investigation with Gases | gaseous (e.g., propane); up to 85% O₂ | CIR-ACME | prevention? | inferred: highest-O₂ tests, relevant to flammability limits |
| ACME E-FIELD Flames | Electric-Field Effects on Laminar Diffusion Flames | gaseous | CIR-ACME | none stated | mimicked partial gravity with an electric field |
| ACME, other 3 experiments | not named in the statement | gaseous | CIR-ACME | – | identify from PSI |
| SPICE | Smoke Point In Co-flow Experiment | gaseous (MSG group) | MSG-SPICE duct | none stated | – |
| SLICE | Structure & Liftoff In Combustion Experiment | gaseous (MSG group) | MSG-SPICE duct | none stated | – |
| DAFT | Dust and Aerosol Measurement Feasibility Test | dust | not stated | detection? | inferred: used a SAME smoke-detection instrument to detect dust |
| DAFT-2 | Dust and Aerosol Measurement Feasibility Test 2 | dust | not stated | detection? | inferred, same as DAFT |
| LUCI | Lunar-g Combustion Investigation | not stated | not stated | – | expected in PSI in the future |
| FM2 | Flammability of Materials on the Moon | materials | not stated | – | expected in PSI in the future |

The statement also says: "Other combustion investigations within the PSI database (but not
explicitly referenced above) are still relevant to fire safety, just not as strongly or directly."

## c) Resource links (from RESOURCES.md)

Login status has not been checked yet because nothing has been opened.

| Name | URL | What it is | Login needed |
|---|---|---|---|
| PSI Data Repository: Combustion Science | https://psi.nasa.gov/physci/repo/search?q=combustion | The PSI data the challenge is based on | unknown: search is likely public; downloads may need a free PSI account. Confirm when downloading |
| NASA Combustion Science | https://www.nasa.gov/glenn/glenn-expertise-space-exploration/physical-sciences-program/combustion-science/ | Basic information about most combustion investigations in PSI | no (public page) |
| NASA ScienceCasts: The Power of Studying Combustion on the ISS | https://www.youtube.com/watch?v=W1oXykoz9zg | 3.6-minute intro video (2018) | no |
| A Researcher's Guide to ISS Combustion Science | https://www.nasa.gov/missions/station/a-researchers-guide-to-combustion-science/ | 2015 review (50+ pages) of ISS combustion research | no |
| Apollo 1 | https://sma.nasa.gov/sma-disciplines/accllp/apollo-1 | Pre-launch fire: crew, investigation, lessons learned | no (public page) |
| Apollo 13 | https://sma.nasa.gov/sma-disciplines/accllp/apollo-13 | Oxygen tank explosion: investigation, lessons learned | no (public page) |
| 25 Years Ago: Fire Aboard Space Station Mir | https://www.nasa.gov/history/25-years-ago-fire-aboard-space-station-mir/ | 1997 Mir fire caused by an oxygen generator failure | no |
| Fireman's Air Tanks | https://spinoff.nasa.gov/node/9582 | Spinoff: 1970s spacesuit tech → firefighter air tanks | no |
| Fire Detector | https://spinoff.nasa.gov/node/9407 | Spinoff: 1970s shuttle smoke detector that tells smoke from dust | no |
| New Technology for the Fire Attire | https://spinoff.nasa.gov/node/9918 | Spinoff: 1980s spacesuit tech → firefighter clothing | no |

RESOURCES.md disclaimer: NASA does not endorse non-U.S. Government entities. Non-U.S.
Government websites have their own data-use terms.

## d) Key facts from the statement

- **Moon base and pressurized rover atmosphere:** "will likely be 30% or greater, with a
  corresponding pressure of 10.2 psi or less". That is "more than a 40% increase in the oxygen
  concentration making materials much more flammable."
- **Spacesuit:** "100% oxygen to only 4.3 psi" (Earth sea level: 14.7 psi). Astronauts pre-breathe
  100% O₂ to avoid the bends. The intermediate habitat atmosphere is meant to shorten that pre-breathe.
- **Highest-O₂ microgravity tests:** ACME CFI-G. An oxygen-nitrogen mixture "of up to 85% oxygen"
  flowed from a spherical burner into nitrogen plus fuel gas (e.g., propane), making an inside-out flame.
- **No partial-gravity data:** "there is currently no partial-gravity combustion data available in PSI."
- **LUCI and FM2:** partial-gravity data "will be added in the future, for example from" LUCI and FM2.
- **Simulated partial gravity:** ACME E-FIELD Flames imitated partial gravity by using an electric
  field to act on the ions in flames.
- **Bounding idea:** "Microgravity and normal-gravity results could bound what occurs at intermediate gravity levels."
- **Fire safety pillars:** prevention (ignition control, material selection, flammability limits),
  detection, suppression. Airflow matters in microgravity, and flammability depends strongly on O₂ concentration.
- **Hardware groups:** the six ACME experiments use CIR-ACME. FLEX, FLEX-2 and CFI use CIR-MDCA.
  BASS, BASS-II, SPICE and SLICE use the MSG with the SPICE fan-driven flow duct.
- **Incidents cited:** Artemis II smoke alarm, Apollo 13 oxygen tank explosion, Mir oxygen-generator fire, Apollo 1 (1967).
