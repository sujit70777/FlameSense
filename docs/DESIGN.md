# FlameSense — Design System & UI Specification

Every value in this file is final. The coding agent implements it exactly. If something is
not specified, use the nearest specified token and log a question in `docs/QUESTIONS.md`.

---

## 1. Design concept: "Two flames"

### 1.1 The idea

The whole product is built on one picture every judge understands in two seconds:

- **On Earth** a flame is an orange **teardrop**: hot gas rises, pulls in air, makes soot that glows yellow.
- **In orbit** a flame is a dim blue **sphere**: nothing rises, oxygen arrives slowly by diffusion, little soot.

So the interface has **two meaningful colors, never decorative ones**:

| Color role | Means | Used for |
|---|---|---|
| **Microgravity blue** | Space, orbit, the ISS, "no up" | Primary actions, ISS data points, links, brand |
| **Ember orange** | Earth gravity, buoyancy, heat | Earth comparisons, 1 g data points, "keeps burning" end of risk scales |
| Violet (secondary data color) | Partial gravity: Moon and Mars | Moon/Mars snaps, partial-gravity data (mostly "data gap") |

A user who learns "blue = space, orange = Earth" on the Home page can read every chart in the app without a legend. That is the point of the system.

### 1.2 Surfaces

- **Dark theme, "Orbit night":** deep blue-black, like the view from the Cupola, with a faint measurement grid.
- **Light theme, "Lab notebook":** cool paper white with a faint millimetre grid, like a combustion lab notebook.
- **The Chamber window:** the flame viewport is always dark in both themes, because you watch a combustion experiment through a window into a dark chamber. This is the single bold element; everything around it stays quiet and precise.

### 1.3 Principles

1. **One memorable thing per screen.** Home: the morphing flame. Lab: the live prediction. Map: the heatmap. Everything else is calm.
2. **Every number has a unit and a source.** Never show a bare number.
3. **Honesty is a visible feature.** Data support, extrapolation, and "not enough data" states are designed as carefully as the happy path.
4. **Instrument, not dashboard.** Readouts look like lab instruments (condensed numerals), not marketing stat cards.
5. **Motion answers actions.** The only non-user motion is the flame itself and one ignition moment on first load.

### 1.4 Things this design never does

- No ALL-CAPS labels, no tracked-out eyebrow text above headings.
- No "→" appended to buttons or links. Buttons say exactly what happens.
- No meta strings joined with middle dots ("A · B · C"). Use commas or separate lines.
- No accenting one word of a headline in a different color or style.
- No monospace fonts. Numbers use Archivo condensed with tabular figures.
- No identical card grids with the same shadow everywhere. Panels, rows, and windows have different roles and look different.
- No NASA logos, insignia, or Space Apps logo inside the app.

---

## 2. Brand

### 2.1 Name and tagline

- Name: **FlameSense** (one word, capital F and S).
- Tagline (EN): **See how fire behaves where "up" doesn't exist.**
- Tagline (BN): **যেখানে "উপর" বলে কিছু নেই, সেখানে আগুন কেমন আচরণ করে, দেখুন।**

### 2.2 Voice

Plain, precise, calm. Short sentences. Active voice. Sentence case everywhere (titles, buttons, tabs). Science words are explained the first time on each page. Never hype ("revolutionary", "powerful"). Never apologize in errors; say what happened and what to do.

### 2.3 Brand mark (SVG, also used for favicon and splash)

A teardrop outline (Earth flame) holding a sphere (space flame).

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" width="64" height="64">
  <path d="M32 5 C32 5 51 25 51 39 A19 19 0 0 1 13 39 C13 25 32 5 32 5 Z"
        fill="none" stroke="#FF8A3D" stroke-width="4" stroke-linejoin="round"/>
  <circle cx="32" cy="39" r="9" fill="#6CB6FF"/>
</svg>
```

- On light backgrounds use stroke `#E2621B` and circle `#1F66D6`.
- Minimum size 20 px. Clear space = 25% of the mark's width on all sides.
- Favicon: 32 px and 16 px PNG renders of the dark-variant mark on `#0A1020` rounded square (radius 22%). App icons 192 and 512 px (maskable: mark at 60% size, centered on `#0A1020`).

### 2.4 Wordmark

"FlameSense" in Archivo, weight 700, width 112, letter spacing −0.4 px, single color `textPrimary`. Mark + wordmark gap: 10 px. Mark height = 1.25 × wordmark cap height.

---

## 3. Color tokens

All pairs used for text meet WCAG 2.2 AA (≥ 4.5:1 for normal text, ≥ 3:1 for large text and UI parts). Contrast values below are approximate; Phase 14 verifies them.

### 3.1 Dark theme — "Orbit night"

| Token | Hex | Use |
|---|---|---|
| `bg` | `#0A1020` | App background |
| `bgGrid` | `#16203A` | Grid lines on background (drawn at 55% opacity) |
| `surface1` | `#10182B` | Panels, rail, top bar |
| `surface2` | `#17213A` | Inputs, table header, raised rows |
| `surface3` | `#1E2A47` | Hover, selected rows, tooltips |
| `outline` | `#2A3756` | 1 px borders, dividers, slider track |
| `outlineStrong` | `#3B4A6E` | Focused input border (with ring), chart axes |
| `textPrimary` | `#EAF0FA` | Main text (≈ 16:1 on bg) |
| `textSecondary` | `#A9B6CC` | Supporting text (≈ 9:1) |
| `textTertiary` | `#7E8CA6` | Hints, captions, axis labels (≈ 5.6:1 on bg, ≈ 4.7:1 on surface2) |
| `microg` | `#6CB6FF` | Links, ISS data, icons, selected text (≈ 8.9:1) |
| `microgStrong` | `#3D8BFF` | Primary button fill, slider active track |
| `onMicrog` | `#06101F` | Text/icons on `microgStrong` (≈ 5.8:1) |
| `microgTint` | `#6CB6FF` @ 16% | Selected chip/nav fill |
| `ember` | `#FF8A3D` | Earth data, Earth flame UI, "keeps burning" end (≈ 8.2:1) |
| `emberStrong` | `#FF6A1A` | Ember fills (bars, markers) |
| `onEmber` | `#1A0A00` | Text on ember fills |
| `emberTint` | `#FF8A3D` @ 14% | Earth comparison column background |
| `partial` | `#C79BFF` | Moon/Mars snaps and data |
| `success` | `#5BD6A0` | Data support high, success toasts |
| `warn` | `#F5C451` | Data support medium, warnings |
| `danger` | `#FF6B7A` | Errors, data support low |
| `successTint` / `warnTint` / `dangerTint` | same hex @ 14% | Notice backgrounds |
| `focusRing` | `#FFD27A` | 2 px focus ring, 2 px offset |
| `scrim` | `#000000` @ 60% | Dialog/tour backdrop |
| `chamberBg` | `#070C19` | Chamber window background (both themes) |
| `chamberEdge` | `#26324F` | Chamber window inner border (both themes) |

### 3.2 Light theme — "Lab notebook"

| Token | Hex | Use |
|---|---|---|
| `bg` | `#F5F7FA` | App background |
| `bgGrid` | `#E3E8F0` | Grid lines (100% opacity) |
| `surface1` | `#FFFFFF` | Panels, rail, top bar |
| `surface2` | `#F0F3F8` | Inputs, table header |
| `surface3` | `#E6ECF5` | Hover, selected rows, tooltips |
| `outline` | `#D5DCE7` | Borders, dividers, slider track |
| `outlineStrong` | `#B3BFD1` | Focused border, chart axes |
| `textPrimary` | `#0D1526` | Main text (≈ 17:1 on white) |
| `textSecondary` | `#42506A` | Supporting text (≈ 8:1) |
| `textTertiary` | `#5E6C85` | Hints, captions (≈ 5.3:1 on white, ≈ 4.7:1 on surface2) |
| `microg` | `#1F66D6` | Links, ISS data, icons (≈ 5.3:1) |
| `microgStrong` | `#1F66D6` | Primary button fill |
| `onMicrog` | `#FFFFFF` | Text on primary (≈ 5.3:1) |
| `microgTint` | `#1F66D6` @ 10% | Selected chip/nav fill |
| `ember` | `#E2621B` | Earth markers, icons, fills (not for small text) |
| `emberText` | `#B4480C` | Ember-colored text (≈ 5.3:1) |
| `emberStrong` | `#D9560B` | Bars, markers |
| `onEmber` | `#FFFFFF` | Text on ember fills (use only ≥ 18 px bold) |
| `emberTint` | `#E2621B` @ 10% | Earth comparison column background |
| `partial` | `#7B4FD6` | Moon/Mars |
| `success` | `#1E8E5A` | |
| `warn` | `#9A6A00` | |
| `danger` | `#C8283C` | |
| `successTint` / `warnTint` / `dangerTint` | same hex @ 10% | |
| `focusRing` | `#1F66D6` | 2 px ring, 2 px offset (offset filled `surface1`) |
| `scrim` | `#0D1526` @ 45% | |
| `chamberBg` | `#070C19` | Same as dark |
| `chamberEdge` | `#26324F` | Same as dark |

In dark theme `emberText` = `ember` (`#FF8A3D`).

### 3.3 Gradients (only these exist)

| Name | Definition | Use |
|---|---|---|
| `chamberGlowSpace` | Radial, center of flame, `#2F6BFF` @ 28% → transparent at 2.2 R | Behind space flame |
| `chamberGlowEarth` | Radial, `#FF6A1A` @ 28% → transparent at 2.2 R | Behind Earth flame |
| `heroSeam` | Linear left→right `ember @ 0%` → `ember @ 18%` (50%) → `microg @ 18%` (50%) → `microg @ 0%`; 1 px tall | Single line separating the two flames' readouts under the Chamber window |

No other gradients. No gradient buttons or backgrounds.

### 3.4 Background grid

`GridBackground` widget, painted once behind the shell content (not behind the rail):
- Minor lines every 24 px, 1 px, `bgGrid` (dark: 55% opacity; light: 100%).
- Major lines every 120 px, 1 px, `bgGrid` (dark: 90%; light: `outline`).
- A radial fade mask: full strength at top-left, 35% strength at bottom-right, so text areas stay calm.
- Hidden inside panels (panels are solid `surface1`).

---

## 4. Typography

### 4.1 Families (bundled assets, OFL)

| Family | File | Role |
|---|---|---|
| **Archivo** (variable: `wght` 100–900, `wdth` 62–125) | `assets/fonts/Archivo[wdth,wght].ttf` | Everything. Wide widths for display headings; normal for text; condensed widths for instrument readouts |
| **Noto Sans Bengali** (variable) | `assets/fonts/NotoSansBengali[wdth,wght].ttf` | Bangla, as `fontFamilyFallback` on every style |

Why Archivo: a grotesque designed with a width axis. One family gives three distinct voices (expanded headings, neutral body, condensed numerals) that feel like engineering labels on lab hardware, without a second typeface.

All numbers in readouts, tables, and charts use `FontFeature.tabularFigures()`.

### 4.2 Type scale

Desktop/tablet (width ≥ 600) and compact (width < 600). `wght`/`wdth` are variation axis values. Line height is in px.

| Style | Material slot | Size / line (≥600) | Size / line (<600) | wght | wdth | Letter spacing | Color |
|---|---|---|---|---|---|---|---|
| `display` | displayLarge | 60 / 66 | 38 / 44 | 720 | 116 | −1.2 | textPrimary |
| `h1` | headlineLarge | 40 / 48 | 30 / 36 | 680 | 110 | −0.6 | textPrimary |
| `h2` | headlineMedium | 28 / 34 | 23 / 29 | 650 | 106 | −0.3 | textPrimary |
| `h3` | titleLarge | 20 / 26 | 19 / 25 | 620 | 102 | −0.1 | textPrimary |
| `title` | titleMedium | 17 / 24 | 16 / 22 | 600 | 100 | 0 | textPrimary |
| `body` | bodyLarge | 16 / 26 | 16 / 25 | 420 | 100 | 0 | textPrimary |
| `bodySmall` | bodyMedium | 14 / 22 | 14 / 21 | 420 | 100 | 0.05 | textSecondary |
| `label` | labelLarge | 14 / 20 | 14 / 20 | 580 | 100 | 0.1 | textPrimary |
| `caption` | labelSmall | 12 / 16 | 12 / 16 | 520 | 100 | 0.2 | textTertiary |
| `numHero` | (extension) | 52 / 54 | 40 / 44 | 640 | 78 | −0.5 | textPrimary |
| `numLg` | (extension) | 32 / 36 | 28 / 32 | 620 | 80 | −0.3 | textPrimary |
| `numMd` | (extension) | 22 / 26 | 20 / 24 | 600 | 82 | 0 | textPrimary |
| `numSm` | (extension) | 14 / 20 | 14 / 20 | 520 | 88 | 0 | textPrimary |

Units next to numbers: `bodySmall`, color `textTertiary`, 4 px gap, baseline aligned.

### 4.3 Reading width

Body paragraphs max 68 characters (≈ 640 px at 16 px). Methods and Earth pages use a 720 px reading column.

### 4.4 Bangla rules

- When locale is `bn`, multiply every line height by **1.15** (Bangla conjuncts and vowel signs are taller).
- Do not use `wdth` < 90 for Bangla text (Noto Sans Bengali narrows poorly); numeric styles keep Archivo for digits.
- Numbers in `bn` locale use Bangla digits (০১২৩৪৫৬৭৮৯) through `NumberFormat` with locale `bn`; units stay in SI symbols (mm/s, kPa, g).
- Never letter-space Bangla (set letter spacing 0 when locale is `bn`).

---

## 5. Spacing, sizing, radii

### 5.1 Spacing scale (px)

`s1 4 · s2 8 · s3 12 · s4 16 · s5 20 · s6 24 · s8 32 · s10 40 · s12 48 · s16 64 · s20 80`
(Agent: implement as `FsSpace.s1` … `FsSpace.s20` constants.)

### 5.2 Radii (px) — hierarchy, not one radius for everything

| Token | Value | Used on |
|---|---|---|
| `rXs` | 6 | Citation chips, small badges, table row hover |
| `rSm` | 10 | Buttons, inputs, segmented controls, tooltips |
| `rMd` | 14 | Notices, list rows with background, dialogs on mobile |
| `rLg` | 20 | Panels |
| `rXl` | 28 | Chamber window, dialogs on desktop |
| `rPill` | 999 | Filter chips, nav active indicator, gravity snaps |

### 5.3 Sizes

| Item | Size |
|---|---|
| Min touch target | 44 × 44 |
| Button heights | md 44, sm 36 |
| Input height | 44 |
| Top bar height | 64 (≥ 1024), 56 (< 1024) |
| Nav rail width | 248 expanded (≥ 1280), 80 compact (1024–1279) |
| Bottom nav height | 72 + safe area |
| Icon sizes | 18 (in buttons), 20 (inline), 22 (nav), 24 (icon buttons), 40 (empty states) |
| Slider thumb | 20 px circle |
| Chart point radius | 4 (default), 6 (hover), 7 (map overlay) |

---

## 6. Surfaces, borders, elevation

| Element | Dark | Light |
|---|---|---|
| Panel (`FsPanel`) | `surface1`, 1 px `outline`, inner top highlight 1 px `#FFFFFF` @ 4% | `surface1`, 1 px `outline`, shadow `0 1 2 rgba(13,21,38,.06)` |
| Raised (dialog, menu, tooltip) | `surface3`, 1 px `outlineStrong` | `surface1`, 1 px `outline`, shadow `0 12 32 rgba(13,21,38,.12)` |
| Input | `surface2`, 1 px `outline`; focus 1 px `microg` + focus ring | `surface2`, 1 px `outline`; focus 1 px `microg` + ring |
| Chamber window | `chamberBg`, 1 px `chamberEdge`, radius `rXl`, inner shadow `inset 0 0 40 rgba(0,0,0,.6)` | same |

Dark theme uses no drop shadows; depth comes from surface steps and borders.

---

## 7. Motion

| Token | Duration | Curve | Use |
|---|---|---|---|
| `mFast` | 120 ms | `Curves.easeOut` | Hover, press, chip toggle |
| `mBase` | 200 ms | `Cubic(0.2, 0, 0, 1)` | Panels expanding, tab switch, notice appear |
| `mSlow` | 320 ms | `Cubic(0.2, 0, 0, 1)` | Dialog/sheet open, page transition (fade 0→1 + 8 px upward on the new page only) |
| `mIgnite` | 700 ms | `Cubic(0.16, 1, 0.3, 1)` | Home first load only: both flames scale 0.55→1 and fade 0→1, Earth flame starts 0 ms, space flame 120 ms later |
| `mValue` | 260 ms | `Curves.easeOutCubic` | Gauge arc and numbers animating to new prediction values |

Rules:
- Reduced motion (`MediaQuery.disableAnimations == true`): all durations become 0 except `mValue` (becomes 0 too), flame is drawn static (no flicker), ignition skipped, tour spotlight jumps instantly.
- Never animate list items in sequence on page load.
- Numbers animate with a tween; text never types out.

---

## 8. Layout and navigation

### 8.1 Breakpoints

| Name | Width | Columns | Margin | Gutter |
|---|---|---|---|---|
| compact | < 600 | 4 | 16 | 16 |
| medium | 600–1023 | 8 | 24 | 20 |
| expanded | 1024–1279 | 12 | 32 | 24 |
| large | 1280–1599 | 12 | 40 | 24 |
| xl | ≥ 1600 | 12 | auto (content max 1440) | 24 |

Content max width 1440 for tool pages (Lab, Map, Explore); 1200 for Home; 720 reading column for Methods/Earth/About text.

### 8.2 App shell (≥ 1024)

```
┌──────────┬───────────────────────────────────────────────────────────────┐
│ [mark]   │  Page title (h3)                 [Take the tour] [☾] [EN|বাং] │ 64
│ FlameSense├───────────────────────────────────────────────────────────────┤
│          │                                                               │
│ ⌂ Home   │                                                               │
│ ▤ Explore│                   page content (on grid bg)                   │
│ ⚗ Lab    │                                                               │
│ ▦ Map    │                                                               │
│ ✉ Ask    │                                                               │
│ ─────    │                                                               │
│ ◍ Earth  │                                                               │
│ ✓ Methods│                                                               │
│ ⓘ About  │                                                               │
└──────────┴───────────────────────────────────────────────────────────────┘
  248 (80 compact: icons only + tooltips)
```

Rail: `surface1`, right border 1 px `outline`. Items: 44 px tall, radius `rSm`, padding 12 h; icon 22 + label `label`. Active: `microgTint` fill, icon + label `microg`, a 3 px × 20 px `microg` bar on the left edge, radius 2. Hover: `surface3`. Divider between primary (Home…Ask) and secondary (Earth, Methods, About). Brand block at top: 72 px tall, mark 28 px + wordmark (wordmark hidden in compact rail).

Top bar: `surface1` @ 92% with 12 px background blur, bottom border 1 px `outline`, sticky.

Icons (Material, rounded variants): Home `home_rounded`, Explore `table_chart_rounded`, Lab `science_rounded`, Map `layers_rounded`, Ask `forum_rounded`, Earth `public_rounded`, Methods `fact_check_rounded`, About `info_rounded`, Tour `play_circle_rounded`, theme `dark_mode_rounded` / `light_mode_rounded`, language `translate_rounded`.

### 8.3 App shell (< 1024)

```
┌──────────────────────────────────────┐
│ [mark] Page title          [⋯]       │ 56  (⋯ opens menu: Tour, Theme, Language)
├──────────────────────────────────────┤
│                                      │
│            page content              │
│                                      │
├──────────────────────────────────────┤
│  ⌂     ▤      ⚗      ▦      ≡       │ 72  Home, Explore, Lab, Map, More
│ Home Explore  Lab    Map   More      │
└──────────────────────────────────────┘
```

"More" opens `FsSheet` with Ask, Earth, Methods, About, Tour, theme, language. Active bottom item: pill indicator 56 × 32 `microgTint` behind the icon, icon + label `microg`.

> Note: Ask moves into "More" on mobile only because five slots are full; on Home, the "Where to go next" list includes Ask so it stays one tap away.

### 8.4 Page header (all pages except Home)

`h1` title, then 8 px, then a one-sentence description in `body` `textSecondary` (max 68 ch), then 24 px before content. Optional trailing actions aligned to the title's baseline on ≥ 1024.

---

## 9. Components

Every component exists in `/dev/gallery` with all states in both themes.

### 9.0 Interaction states (apply to every interactive element)

| State | Treatment |
|---|---|
| Hover (pointer) | Overlay `textPrimary` @ 6% (dark) / 4% (light), `mFast` |
| Pressed | Overlay @ 10% / 8% |
| Focus (keyboard) | 2 px `focusRing` ring, 2 px offset, follows the element's radius. Never removed |
| Disabled | 38% opacity, no hover, cursor `forbidden` |
| Selected | `microgTint` fill + `microg` foreground |

Ripple: `InkRipple.splashFactory`. Cursor `click` on all clickable elements.

### 9.1 `FsButton`

| Variant | Fill | Text/icon | Border |
|---|---|---|---|
| primary | `microgStrong` | `onMicrog` | none |
| secondary | transparent | `textPrimary` | 1 px `outlineStrong` |
| ghost | transparent | `microg` | none |
| danger | `danger` | dark: `#1A0006` / light: `#FFFFFF` | none |

Sizes: md 44 h, padding 20 h; sm 36 h, padding 14 h. Radius `rSm`. Label style `label`. Optional leading icon 18 px, 8 px gap. Loading: replace label with 16 px spinner (same color), keep width. Full-width on compact when inside forms.

### 9.2 `FsIconButton`

40 × 40 visual, 44 × 44 hit, radius `rSm`, icon 24 `textSecondary` (hover `textPrimary`). **Tooltip required** (label = the action, e.g., "Switch to dark theme").

### 9.3 `FsChip` (filter/toggle)

32 h, padding 12 h, radius `rPill`, 1 px `outline`, `label` text `textSecondary`. Selected: `microgTint` fill, `microg` text, leading check icon 16. Dropdown chips show trailing `expand_more_rounded` 18.

### 9.4 `GravityChip`

Read-only pill showing the gravity class: 8 px dot + text.
- ISS / microgravity: dot `microg`, text "ISS orbit (10⁻⁶ g)" or computed value.
- Partial: dot `partial`, "Moon (0.17 g)" / "Mars (0.38 g)".
- Earth: dot `ember`, "Earth (1 g)".

### 9.5 `FsPanel`

Surface per §6, radius `rLg`, padding 24 (compact 16). Optional header: `h3` title left, actions right, 16 px below header. Panels never nest inside panels; inside a panel use `Divider` (1 px `outline`) or `surface2` blocks with `rMd`.

### 9.6 `MetricReadout`

```
Chance it keeps burning        ← label: bodySmall, textSecondary
72 %                           ← numMd/numLg/numHero + unit (bodySmall, textTertiary)
80% range 1.9–4.6 mm/s         ← optional caption
```

### 9.7 `FsSlider`

- Track 4 px, radius 2, inactive `outline`, active `microgStrong` (gravity slider: active color interpolates `microg` → `ember` by position, matching the flame).
- Thumb 20 px circle `textPrimary` (dark) / `surface1` with 2 px `microgStrong` border (light); 3 px ring `surface1`; focus adds `focusRing`.
- Label row above: name (`label`) left, current value (`numSm` + unit) right.
- Number field (96 w, 36 h) to the right of the track on ≥ 600; below on compact. Invalid entry: field border `danger`, helper text (`caption`, `danger`) e.g., "Enter a value between 15 and 40".
- Markers: 2 px × 8 px ticks under the track with `caption` labels (e.g., "Earth air 21%", "ISS cabin 101 kPa"). Snaps for gravity: Earth, Mars, Moon, ISS, as small pills `rPill` under the track; tap to jump; snap magnetism within 2% of track width while dragging.
- Log option: track position maps to log10(value).
- Keyboard: ←/→ = 1 step, Shift+←/→ = 10 steps, Home/End = min/max. `Semantics(slider: true, value: "21 percent")`.

### 9.8 `FsSegmented`

Height 36, radius `rSm`, container `surface2` with 1 px `outline`, segments equal width, selected segment `surface1` (light) / `surface3` (dark) with 1 px `outlineStrong` and `label` `textPrimary`; unselected `textSecondary`.

### 9.9 `DataSupportBadge`

Pill 28 h, radius `rPill`, tint background, 1 px border in the solid color, icon 16 + `label`.

| Level | Color | Icon | Text | Tooltip |
|---|---|---|---|---|
| high | success | `verified_rounded` | "Data support: high" | "Many NASA test runs were done near these conditions." |
| medium | warn | `info_rounded` | "Data support: medium" | "Some NASA test runs are near these conditions. Treat the prediction as approximate." |
| low | danger | `report_rounded` | "Data support: low" | "Few or no NASA test runs are near these conditions. This is an extrapolation." |

### 9.10 `CitationChip`

22 h, min width 22, radius `rXs`, 1 px `microg`, text `numSm` `microg` ("1"). Hover: tooltip with source title + page. Click: scroll to and pulse-highlight (background `microgTint` 0→1→0 over 900 ms; static highlight in reduced motion) the matching source card.

### 9.11 `FsTooltip`

`surface3` (dark) / `textPrimary` bg with `surface1` text (light, inverted), radius `rSm`, padding 8 × 10, `bodySmall`, max width 280, delay 400 ms, appears below by default.

### 9.12 `SectionHeader`

`h2` + optional description `body textSecondary` (max 68 ch), 8 px gap, 24 px bottom margin. No eyebrow above.

### 9.13 States

- **`EmptyState`**: centered in its container, icon 40 `textTertiary`, title `h3`, body `body textSecondary` (max 48 ch), optional primary/secondary buttons. Copy in §12.
- **`ErrorState`**: like empty, icon `error_outline_rounded` in `danger`, title says what failed, body says what to do, button "Try again".
- **`SkeletonBlock`**: `surface2` blocks with radius matching the real element; shimmer = linear sweep of `textPrimary` @ 4% over 1200 ms; static in reduced motion. Use skeletons, never spinners, for page-level loading.
- **`InlineNotice`**: radius `rMd`, padding 12 × 16, tint background, 1 px border solid color @ 40%, icon 20 solid color, text `bodySmall` `textPrimary`, optional action (ghost button sm). Variants: info (microg), warn, danger, success.

### 9.14 `SustainGauge` (Fire Lab, Map inspector)

- Semicircle, outer diameter 240 (compact 200), stroke 14, round caps.
- Track: `outline`. Value arc: from 0 to p, colored by the heatmap ramp (§10.4) at value p.
- Center: `numHero` "72" + "%" (`numMd`, `textSecondary`), below it `bodySmall` "chance the flame keeps burning".
- End labels under the arc ends: `caption` "Goes out" (left) and "Keeps burning" (right).
- Unavailable: arc track only, center "—", caption "Not enough data to predict this", plus info button explaining.
- Animates with `mValue`. Semantics label: "Chance the flame keeps burning: 72 percent."

### 9.15 `SpreadBand`

```
Flame spread rate
3.4 mm/s                               (numLg)
├─────────[████████●██████]──────────┤ (track 8 h, band = q10..q90 microg @ 28%, dot = q50 microg 12 px)
0.5                                12 mm/s
80% range: 1.9 to 4.6 mm/s            (caption)
```

Axis is log scale from the slider-derived min/max of the training data. In Compare mode the Earth column uses `ember` instead of `microg`.

### 9.16 `PhysicsCard`

Panel section titled "Physics check". States:
- ok: `MetricReadout` "Thin-fuel theory predicts" `numMd` value mm/s; one line comparing to ML ("ML prediction is 18% lower — expected near extinction, where the simple theory over-predicts."); link "See the equation" → Methods#physics.
- notApplicable: InlineNotice info "The physics check covers thin materials in opposing airflow. These conditions are outside it."
- nearExtinction: InlineNotice warn "Near extinction the simple theory over-predicts spread. Trust the data-driven prediction more here."
- unavailable: InlineNotice info "The physics check is switched off until its parameters are verified."

### 9.17 `SensitivityList` ("What moves the risk")

Up to 4 rows: feature name (`label`), direction icon (`trending_up_rounded` in `ember` if increasing the input raises sustain/spread, `trending_down_rounded` in `microg` if it lowers it), and text `bodySmall` "Raising oxygen by 2.5 points: +14 points". A 4 px bar under each row, length ∝ |delta| (max = largest delta), color as the icon. Caption at bottom: "Each row nudges one setting by 10% of its range and keeps the rest fixed."

### 9.18 `FsDialog` / `FsSheet`

Dialog: max width 640 (run detail) / 480 (confirm), radius `rXl`, padding 28, title `h2`, close icon button top-right, scrim. Esc closes. Focus trapped and returned to the opener.
Sheet (compact): from bottom, radius `rXl` top corners, drag handle 36 × 4 `outlineStrong`, max height 90%.

### 9.19 `FsTabs`

Text tabs `label`, 44 h, underline indicator 2 px `microg` width = text width, unselected `textSecondary`. Scrollable on compact.

### 9.20 `FlameTwin` (the hero element) — exact drawing spec

A `CustomPainter` drawing one flame for a gravity value. Used twice on Home, once in the Lab, small in 404 and tour.

Inputs: `gravityG`, `phase` (0–1 animation value, 4 s loop), `animate` (false when reduced motion), canvas `W × H`.

1. `s = (log10(clamp(gravityG, 1e-6, 1)) + 6) / 6` (0 = ISS, 1 = Earth). Buoyancy `b = pow(s, 1.4)`.
2. `R = min(W, H) × 0.22`. Base point `B = (W/2, H × 0.74)`. Flame center `C = (W/2, H × 0.60 − b × H × 0.10)`.
3. Outline: 96 points, θ from 0 to 2π measured from straight up. `u = max(0, cos θ)`, `d = max(0, −cos θ)`.
   `r(θ) = R × (1 + b × 1.7 × u³) × (1 − b × 0.18 × d²)`.
   Point = `C + (r sin θ, −r cos θ)`. If `animate && b > 0.25`: add flicker to points with `u > 0`:
   `dx = R × b × u³ × (0.04 sin(2π·1.3·phase) + 0.02 sin(2π·3.1·phase))`,
   vertical stretch factor `1 + 0.03 × b × sin(2π·2.2·phase)` applied to `−r cos θ` for `u > 0`.
   For `b ≤ 0.25` the flame is perfectly steady (physically correct: no buoyant flicker in microgravity).
   Close the path with quadratic smoothing between points.
4. Colors (lerp by `b`; space value → Earth value):
   - glow: `#2F6BFF → #FF6A1A`, radial at C, radius 2.2 R, alpha 0.28 → 0.
   - outer fill: radial gradient at C, radius = 1.15 × max r: stops 0.0 core `#DCEBFF → #FFF4CF`; 0.55 mid `#5AA0FF → #FFA640`; 1.0 edge `#2F5BFF → #FF5A14` with alpha 0.
   - inner core: same path scaled 0.55 about B + (0, −0.15 R), fill `#F2F8FF → #FFFBEA` alpha 0.85.
   - overall opacity: `0.78 → 1.0` (space flames are dimmer).
   - soot halo (Earth only, `b > 0.5`): stroke the outline 2 px `#FFC46B` alpha `0.35 × (b − 0.5) × 2`.
5. Fuel sample: rounded rect centered at B, width 0.9 R, height 4, radius 2, `#3B4A6E`.
6. Label (outside the painter, below the window): `title` text, e.g., "Earth (1 g)" / "ISS orbit (10⁻⁶ g)", plus readouts.

Always drawn inside the Chamber window (`chamberBg`). Repaint only when gravity or phase changes.

### 9.21 Toast

Bottom-center (bottom-right ≥ 1024), max width 420, `surface3` dark / `textPrimary` light (inverted), radius `rMd`, `bodySmall`, icon 18, auto-dismiss 4 s, action optional. Used for: "Link copied", "CSV downloaded", "Answer copied".

### 9.22 Data table

Header row 40 h `surface2`, `label` `textSecondary`, sort icon 16 on hover/active. Rows 44 h, `bodySmall` `textPrimary`, numbers right-aligned `numSm` with units in header ("O₂ (%)"). Row hover `surface3`. Zebra: none. Sticky header. Horizontal scroll on narrow widths with the first column (Run) pinned. Outcome cell: 8 px dot (`ember` = kept burning, `microg` = went out) + text.

### 9.23 Theme and language toggles

Theme: icon button cycling System → Light → Dark (tooltip states the next mode); long-press/right-click shows a menu with all three. Language: `FsSegmented` "EN | বাং" (36 h) in top bar ≥ 1024; in menu on compact.

---

## 10. Data visualization

### 10.1 General

- Background: inside a panel (`surface1`). Plot area padding: 16 top, 16 right, 44 bottom, 56 left.
- Gridlines: horizontal only, 1 px `outline` @ 60%. Axes 1 px `outlineStrong`. Axis labels `caption` `textTertiary`; axis titles `bodySmall` `textSecondary` with units ("Oxygen (%)", "Airflow (mm/s, log scale)").
- Number formatting: 3 significant digits, unit in axis title only.
- Tooltip: `FsTooltip` style, lines: run id (`label`), then key values with units.
- Every chart has a one-sentence `Semantics` summary, e.g., "Scatter of 212 runs: spread rate rises with oxygen; ISS runs are slower than Earth runs at the same oxygen."

### 10.2 Gravity encoding (all charts)

| Class | Color (dark / light) | Point style |
|---|---|---|
| Microgravity (ISS, free flyer, drop tower, parabolic) | `#6CB6FF` / `#1F66D6` | filled circle |
| Partial (Moon/Mars) | `#C79BFF` / `#7B4FD6` | filled diamond |
| Earth (ground) | `#FF8A3D` / `#D9560B` | hollow circle, 2 px stroke |

### 10.3 Experiment palette (when coloring by experiment; max 6, then "Other")

Dark: `#6CB6FF`, `#FF8A3D`, `#5BD6A0`, `#F5C451`, `#C79BFF`, `#FF7FAE`, Other `#7E8CA6`.
Light: `#1F66D6`, `#D9560B`, `#1E8E5A`, `#9A6A00`, `#7B4FD6`, `#C2306E`, Other `#5E6C85`.
Always pair color with point shape (circle, square, triangle, diamond, cross, star) so it works without color.

### 10.4 Sustain-probability ramp (heatmap, gauge)

Monotonic in lightness so it reads in grayscale. Linear interpolation in sRGB between stops.

| p | Dark | Light |
|---|---|---|
| 0.00 | `#172038` | `#EEF3FA` |
| 0.20 | `#1F3A66` | `#C9DBF3` |
| 0.40 | `#2F65A8` | `#8DB3E6` |
| 0.55 | `#6F6FC0` | `#9C8FD1` |
| 0.70 | `#C4607A` | `#D9707F` |
| 0.85 | `#FF8A3D` | `#E2621B` |
| 1.00 | `#FFD27A` | `#9C3A06` |

Meaning: cool and dark = "likely to go out", hot = "likely to keep burning". Legend labels exactly: "Likely to go out" and "Likely to keep burning".

### 10.5 Low-support hatching

Cells with data support `low`: 45° diagonal lines, 1 px, spacing 6 px, color `textPrimary` @ 30%, clipped to the cell. Legend item: small hatched square + "Little or no NASA data here".

### 10.6 50% contour

2 px line `textPrimary` @ 85%, with a 4 px halo in `surface1` @ 60% underneath for contrast. Label "50%" (`caption`) at the line's right end.

---

## 11. Pages

Each page lists: purpose, layout (desktop ≥ 1280, compact < 600; medium/expanded interpolate), components, copy, states.

### 11.0 Global loading and error screens

- **Loading (assets):** full-screen `bg`, centered brand mark 56 px with the space flame circle gently pulsing opacity 0.6↔1 (1.6 s; static in reduced motion), below it `bodySmall` "Loading NASA experiment data". The HTML splash (`#fs-splash`) looks identical so the handoff is invisible.
- **Error (assets):** `ErrorState`: title "FlameSense couldn't load its data", body "The file {file} is missing or damaged. Reload the page. If this keeps happening, the deployment is incomplete.", button "Reload".

### 11.1 Home (`/`)

**Purpose:** In 10 seconds the judge understands what fire does in space and why the app matters.

Desktop:
```
┌───────────────────────────────────────────────────────────────────────────────┐
│ Fire has no "up"                       ┌──────── Chamber window ───────────┐  │
│ in space.                    (display) │                                   │  │
│                                        │    (teardrop)        (sphere)     │  │
│ On Earth, rising hot air stretches a   │      Earth            Your gravity │  │
│ flame into a teardrop. On the space    │                                   │  │
│ station nothing rises, so flames turn  │ ───────── heroSeam ─────────────  │  │
│ round, blue and slow. FlameSense turns │ Earth (1 g)        ISS orbit (10⁻⁶ g)│
│ NASA's space-station fire experiments  │ Buoyant airflow     Buoyant airflow │  │
│ into predictions you can explore.      │ 92 mm/s             0.9 mm/s       │  │
│                                        └───────────────────────────────────┘  │
│ [Open the Fire Lab]  [Take the tour]    Gravity  ●━━━━━━━━━━━━━━━━━━━○        │
│                                          (ISS) (Moon) (Mars)        (Earth)   │
│                                                                               │
│ Built on 412 test runs from 5 NASA experiments across 9 materials.            │
│ ───────────────────────────────────────────────────────────────────────────── │
│ Where to go next                                                    (h2)      │
│ ▤  Explore the experiments   Every run, filterable, with its NASA source   ›  │
│ ▦  See the flammability map  Where flames survive, by oxygen and airflow   ›  │
│ ✉  Ask the NASA papers       Answers with citations                        ›  │
│ ◍  Lessons for Earth         What space fires teach us about safety here   ›  │
│ ───────────────────────────────────────────────────────────────────────────── │
│ footer: disclaimer · credits                                                  │
└───────────────────────────────────────────────────────────────────────────────┘
```
- Grid: text column spans 5/12, Chamber window 7/12 (min 560 × 400). Text is left-aligned, vertically centered with the window.
- Chamber window: two flames each 260 × 340 area. Left fixed at 1 g. Right follows the gravity slider (default ISS). Readouts under each: label "Buoyant airflow" + `numMd` value + "mm/s" (from physics buoyant velocity if available; otherwise hide the readout row). If the spread model is available, a second readout "Predicted spread" for the default material.
- Gravity slider spans the window width beneath it, snaps ISS, Moon, Mars, Earth (left to right, log scale). Active track color lerps microg → ember.
- The data sentence uses `body` with numbers in `numSm` weight 600; values from `app_meta.json`.
- "Where to go next": a list, not cards. Rows 64 h, divider 1 px `outline`, icon 22 `microg`, title `title`, description `bodySmall`, chevron `chevron_right_rounded`. Whole row is a link.
- Footer: `caption` text: disclaimer (§12) on one line, credits on the next ("Data: NASA open data. Code: Apache-2.0. Built for NASA Space Apps Challenge 2026, Rajshahi.").

Compact: headline (display compact) → subhead → Chamber window full width 320 h with both flames at 140 × 200 → slider with snaps → two CTAs stacked full width → data sentence → list → footer.

Signature moment: `mIgnite` on first visit per session only.

States: if `sustain` and `spread` both unavailable, readouts show only buoyant airflow; nothing else changes.

### 11.2 Explore (`/explore`)

**Purpose:** Prove the data is real and traceable.

- Header: title "Explore the experiments", description "Every NASA test run FlameSense uses, in one table. Each row links to its source."
- Filter bar (wrapping row of `FsChip` dropdowns): Experiment (multi), Platform, Material type, Gravity (Microgravity / Moon or Mars / Earth), Oxygen range (dialog with range slider), Pressure range, Quality ("Include estimated", "Include digitized", "Include video-derived", "Include flagged" — all on except flagged). Right side: result count `bodySmall` "Showing 186 of 412 runs" + ghost button "Clear filters" + secondary button "Download CSV" (icon `download_rounded`).
- Charts panel (height 440, compact 320) with tabs: "Spread vs oxygen", "Burning vs airflow", "Runs per experiment".
- Table panel below (height fills, min 480).
- Compact: filter bar becomes one secondary button "Filters" with count badge → opens sheet; charts panel then table (horizontal scroll, pinned Run column).

Run detail (dialog ≥ 1024 / page < 1024): title "Run {run_id}", GravityChip, outcome line ("Kept burning" with ember dot / "Went out" with microg dot / "Did not ignite"), then a two-column definition list of all non-null fields with units (labels `bodySmall textSecondary`, values `numSm`/`body`), quality badge, "Source" block: citation text + ghost button "Open source" (`open_in_new_rounded`). Footer actions: secondary "Close", primary "Load these conditions in the Fire Lab".

States:
- Loading: skeleton chips + chart block + 8 skeleton rows.
- Empty filters: `EmptyState` icon `filter_alt_off_rounded`, title "No runs match these filters", body "Widen the oxygen or pressure range, or include more experiments.", button "Clear filters".
- Only one experiment in data: `InlineNotice` info "All runs come from one experiment, so comparisons across experiments aren't possible yet."

### 11.3 Fire Lab (`/lab`)

**Purpose:** Ask "what if" and get an honest answer.

Desktop ≥ 1280 (three columns: 360 | flexible | 400, gap 24):
```
┌─ Conditions ──────────┐┌─ Chamber window ──────────────┐┌─ Prediction ──────────────┐
│ Material  [Cotton-fg ▾]││                               ││  [Data support: high]     │
│ Thin solid, 0.08 mm    ││          (flame)              ││     ◜‾‾‾‾‾‾‾◝             │
│                        ││                               ││    72 %                   │
│ Oxygen          21 %   ││ ISS orbit (10⁻⁶ g)            ││ chance it keeps burning   │
│ ━━━━━●━━━━━━━━  [21  ] ││ Effective airflow  100 mm/s   ││ Goes out    Keeps burning │
│ Pressure     101.3 kPa ││ (forced 100 + buoyant 0.9)    ││ ───────────────────────── │
│ ━━━━━━━●━━━━━  [101.3] │└───────────────────────────────┘│ Flame spread rate         │
│ Airflow       100 mm/s │[ ] Compare with Earth           │ 3.4 mm/s  [band]          │
│ ━━━━━━━━●━━━━  [100  ] │                                 │ ───────────────────────── │
│ Gravity  ISS orbit     │                                 │ Physics check  ...        │
│ ━●━━━━━━━━━━━  snaps   │                                 │ ───────────────────────── │
│ Airflow direction      │                                 │ What moves the risk       │
│ [Opposed|Concurrent|None]                                │  ↑ Oxygen  +14 pts        │
│ [Reset]  [Copy link]   │                                 │  ↓ Thickness −9 pts       │
└────────────────────────┘                                 │ notices…                  │
                                                           └───────────────────────────┘
```
- Conditions panel: material dropdown (options = fuels present in data; selecting fills fuel class, thickness, density; a "Custom" option unlocks thickness and density sliders), sliders per `feature_spec` (O₂ shown in %, pressure kPa with markers "Sea level 101.3 kPa" and any ISS-relevant value present in data, airflow log 0–max with marker "Typical ISS ventilation" only if `[SCI]` provides a sourced value, gravity log with snaps), airflow direction `FsSegmented` (Opposed / Concurrent / None), then a row: secondary "Reset to defaults", ghost "Copy link to this setup" (toast "Link copied").
- Chamber window: single flame 320 × 360 area; under it `title` gravity label and `MetricReadout` "Effective airflow" with caption "(forced {x} + buoyant {y})". Below the window: checkbox-style `FsChip` "Compare with Earth".
- Prediction panel order: DataSupportBadge (top-right of panel header), SustainGauge, divider, SpreadBand, divider, PhysicsCard, divider, SensitivityList, then all InlineNotices stacked.
- Compare mode: the Prediction panel becomes two columns: "At your gravity" (microg accents) and "On Earth (1 g)" (`emberTint` background, ember accents); a delta line above both: "{x} points more likely to keep burning on Earth" or "less likely", and spread "×{ratio} faster on Earth". On < 1280 the two columns stack.

Expanded 1024–1279: Conditions 340 left; right column stacks Chamber window (height 300) then Prediction.

Compact: (1) Chamber window 240 h with gravity label; (2) sticky result bar under the top bar once the gauge scrolls out of view: "72% keeps burning, 3.4 mm/s" + DataSupportBadge dot; (3) Prediction panel; (4) Conditions panel; (5) Compare toggle.

Warnings (InlineNotice, warn unless noted):
- `outside_range`: "{feature} is outside the range NASA tested ({min}–{max} {unit}). The prediction is an extrapolation."
- low support (danger): "Few NASA test runs are near these conditions. Use this as a rough estimate."
- partial gravity (info): "NASA has little or no fire data at Moon or Mars gravity. Predictions here are extrapolations between Earth and orbit. This is a real research gap."
- task unavailable (info): "There isn't enough NASA data to predict {output} reliably, so FlameSense doesn't show one."
- quantiles reordered (info, only in debug builds).

Numeric field errors: "Enter a number between {min} and {max}."

### 11.4 Flammability Map (`/map`)

**Purpose:** One picture of where flames survive, and where NASA has no data.

Desktop:
```
Header: "Flammability map" / "How likely a flame is to keep burning across oxygen levels and airflow speeds."
Controls row: [Material type ▾] [Pressure 101.3 kPa ▾] [Gravity: ISS orbit ▾] [Airflow direction ▾]  Overlays: (NASA runs ✓) (50% line ✓)
┌──────────────────────────── heatmap (4:3, max 880 w) ───────────┐┌─ Inspector (300) ─────┐
│ O₂ %                                                             ││ Hover a cell          │
│ 40 ┤ ████████████████████████████████████                        ││ Oxygen 24%            │
│    │ ███ hot ███████████   ●  ○                                  ││ Airflow 40 mm/s       │
│ 21 ┤ ▒▒▒ cool ▒▒▒▒   ── 50% ──                                   ││ 64% keeps burning     │
│ 15 ┤ ////hatched little data////                                 ││ [Data support: med]   │
│    └──────┬───────┬───────┬───────┬─────── Airflow (mm/s, log)   ││ [Open in Fire Lab]    │
└──────────────────────────────────────────────────────────────────┘│ Legend (gradient bar) │
                                                                    │ Hatch legend          │
                                                                    │ ● kept burning        │
                                                                    │ ○ went out            │
                                                                    └───────────────────────┘
```
- Gravity dropdown includes ISS, Moon, Mars, Earth, and "Custom" (opens slider). When Moon or Mars: InlineNotice (info) above the map: "No NASA fire tests at {Moon|Mars} gravity are in this dataset ({n} runs). The colors here are extrapolated, which is why most of the map is hatched. Filling this gap matters for Artemis and future Mars missions."
- Overlay points: only runs whose gravity class matches the selected one and material type matches.
- Clicking a cell pins it in the Inspector (pinned state shows a 2 px `focusRing` outline on the cell).
- Compact: controls in a "Map settings" sheet; map full width (aspect 1:1); inspector below the map; tap a cell to inspect.

States:
- sustain unavailable: `EmptyState` inside the map area: icon `layers_clear_rounded`, title "Not enough data to draw the map", body "FlameSense needs at least 40 NASA runs with a known outcome. You can still see every run that exists.", button "Show the runs in Explore". Real-run scatter still draws on an empty grid.
- Loading grid: skeleton block with the map's aspect ratio (only on first draw).

### 11.5 Ask (`/ask`)

**Purpose:** Get answers from NASA documents, with citations you can check.

Layout: centered 760 column.
```
Header: "Ask the NASA papers" / "Answers come only from the NASA documents FlameSense has read. Every sentence cites its source."
Suggested questions (2-column list of buttons, 1 column on compact; each 56 h, surface2, rMd, label text, leading forum icon):
  1. Why are flames round in microgravity?
  2. Can a material burn in space but not on Earth?
  3. What did NASA's Saffire experiments test?
  4. How does airflow affect flame spread in microgravity?
  5. Why are flames in space blue?
  6. How is spacecraft material flammability tested?
  (Agent: replace any question whose cached answer the science lead rejects.)
Input: multiline (min 3 lines, max 8), placeholder "Ask about fire in microgravity", counter "0 / 500" caption bottom-right, primary button "Ask" (icon send_rounded) bottom-right; Enter sends, Shift+Enter adds a line.
Answer card (FsPanel):
  Status line: success icon + "Answered from NASA sources" | info icon + "Not found in FlameSense's NASA sources"
  Answer text: body, paragraphs + bullets, inline CitationChips.
  Tag "Saved answer" (caption pill) when served from cache.
  Actions: ghost "Copy answer" (toast "Answer copied").
Sources (below answer): numbered source rows: chip number, title (title style), "Page {n}" caption, snippet (bodySmall, 3 lines), ghost "Open document".
Earlier questions (collapsed list, last 5, this session only).
Footer note (caption): "Answers are generated by an AI model from the cited documents and can contain mistakes. Check the source before relying on it."
```
States:
- Waiting: answer card with skeleton lines (4) and caption "Searching NASA documents".
- Errors (InlineNotice danger in the answer slot, with retry): rate limited, upstream, offline, invalid (inline under input).
- Not grounded: status line info + the model's one-sentence answer + suggested related question as a button.

### 11.6 Earth Lessons (`/earth`)

**Purpose:** Turn space findings into understanding for life on Earth.

- Header: title "Lessons for Earth", description "What fire experiments in orbit teach us about fire safety in rooms, vehicles and workplaces here."
- Each approved lesson is a full-width row panel with two halves (stack on compact):
  - Left half (microg accent, 3 px left border `microg`): small `GravityChip` "In orbit", `h3` title, `body` space finding.
  - Right half (ember accent, 3 px left border `ember`, `emberTint` background): chip "On Earth", `body` Earth meaning, then `label` "What this means in practice" + `body` text.
  - Bottom: sources as ghost link buttons with `open_in_new_rounded`.
- Order: as in `lessons.json`. No numbers on lessons (they are not a sequence).
- Footer InlineNotice info: "These are general findings from research, not safety rules for a specific building. Follow your local fire service's guidance."
- Empty (no approved lessons): `EmptyState` "Lessons are being reviewed" / "Each lesson is checked against its sources before it appears here."

### 11.7 Methods (`/methods`)

**Purpose:** Earn the validity score. Show the work.

Desktop: sticky table of contents (220 w, left) + 720 reading column. Compact: ToC as a dropdown at top.

Sections (anchors):
1. `#data` "Where the data comes from" — table: source, experiment, runs, link; quality-flag explanation table; total counts.
2. `#predictions` "How predictions work" — plain-language paragraph; feature list with units; "Two models: one estimates the chance a flame keeps burning; three estimate the slow, typical and fast spread rate (10th, 50th and 90th percentiles)."; "Oxygen is constrained so that more oxygen can never lower the risk, matching combustion science."
3. `#validation` "How well it works" — metrics tables from `metrics.json` with a sentence explaining each metric in plain words; calibration chart (fl_chart line: predicted vs observed with the diagonal); baseline comparison; cross-validation note ("Tested on whole test series the model never saw, so results aren't inflated by near-duplicate runs.").
4. `#physics` "Physics check" — equations rendered with `flutter_math_fork` (display mode), each followed by a symbol table; applicability; sign-off status line "Verified by the team's science lead on {date}" or "Pending verification".
5. `#support` "Data support and extrapolation" — explains the badge levels and hatching.
6. `#limitations` "Limitations" — list from MODEL_CARD.
7. `#honesty` "What FlameSense will never do" — no synthetic data, no hidden extrapolation, no safety certification claims.

### 11.8 About (`/about`)

Reading column. Sections: "What FlameSense is" (2 sentences), "Team" (two rows: "Lead developer, AI and app" and "Science and math lead (M.Sc. Applied Mathematics, University of Dhaka)"; names only if the team chooses to show them), "Challenge" ("NASA Space Apps Challenge 2026: Flame in Freefall"), "Open source" (GitHub link button), "AI use" (disclosure text from SUBMISSION.md), "Licenses and credits" (code Apache-2.0; fonts SIL OFL: Archivo, Noto Sans Bengali; data credits per source; "Not affiliated with or endorsed by NASA."), "Contact" (email link).

### 11.9 Not found (any unknown route)

Centered: Chamber window 280 × 240 with a small space flame (gravity 1e-6, R small) slowly drifting ±6 px horizontally over 6 s (static in reduced motion). `h1` "This page drifted off", `body` "The address may be mistyped, or the page has moved.", primary "Go to Home".

### 11.10 Judge Tour (overlay, `?tour=1` or "Take the tour")

- Scrim `scrim`, spotlight cutout around the target with radius `rLg` and 8 px padding; cutout border 2 px `microg`.
- Caption card (max 360 w, `surface3`/`surface1`, radius `rLg`, padding 20): step counter `caption` "Step 2 of 7", title `title`, body `bodySmall`, buttons ghost "Back", primary "Next" (last step: "Finish"), icon button close (tooltip "Exit tour"). Placed beside the target (right, else below, else above).
- Steps (route → target → title → body):
  1. `/` → gravity slider + Chamber window → "Fire changes shape without gravity" → "Drag gravity from Earth to orbit. The flame turns from an orange teardrop into a slow blue sphere."
  2. `/lab` → Conditions panel → "Set up a fire test" → "Pick a material and set oxygen, pressure, airflow and gravity, like NASA's space-station experiments."
  3. `/lab` → Prediction panel → "An honest prediction" → "The model is trained only on NASA test runs. The badge shows how much real data supports this answer."
  4. `/map` → heatmap → "Where flames survive" → "Hot colors keep burning. Hatched areas have little NASA data, including Moon and Mars gravity."
  5. `/explore` → first table row → "Every number has a source" → "Open any run to see the NASA dataset or report it came from."
  6. `/ask` → first suggested question → "Ask the NASA papers" → "Answers cite the exact document and page."
  7. `/earth` → first lesson → "Lessons for Earth" → "What space fire research means for fire safety in rooms, vehicles and workplaces."
- Keyboard: → Next, ← Back, Esc exit. Focus moves to the caption card each step.

---

## 12. Microcopy (English source of truth)

### 12.1 Global

| Key | English |
|---|---|
| `appName` | FlameSense |
| `tagline` | See how fire behaves where "up" doesn't exist. |
| `navHome` / `navExplore` / `navLab` / `navMap` / `navAsk` / `navEarth` / `navMethods` / `navAbout` / `navMore` | Home / Explore / Fire Lab / Map / Ask / Earth lessons / Methods / About / More |
| `takeTour` | Take the tour |
| `themeSystem` / `themeLight` / `themeDark` | Use system theme / Light theme / Dark theme |
| `langEnglish` / `langBangla` | EN / বাং |
| `disclaimer` | FlameSense is a research and education tool. It is not a certified fire-safety system and must not be used for operational safety decisions. |
| `notAffiliated` | Not affiliated with or endorsed by NASA. Uses NASA open data. |
| `credits` | Data: NASA open data. Code: Apache-2.0. Built for NASA Space Apps Challenge 2026, Rajshahi. |
| `loadingData` | Loading NASA experiment data |
| `loadErrorTitle` | FlameSense couldn't load its data |
| `loadErrorBody` | The file {file} is missing or damaged. Reload the page. If this keeps happening, the deployment is incomplete. |
| `reload` / `tryAgain` / `close` / `back` / `next` / `finish` / `exitTour` | Reload / Try again / Close / Back / Next / Finish / Exit tour |
| `linkCopied` / `csvDownloaded` / `answerCopied` | Link copied / CSV downloaded / Answer copied |

### 12.2 Gravity and units

| Key | English |
|---|---|
| `gEarth` / `gMars` / `gMoon` / `gIss` / `gCustom` | Earth / Mars / Moon / ISS orbit / Custom |
| `gravityValue` | {label} ({value} g) |
| `unitMmS` / `unitKpa` / `unitPercent` / `unitMm` / `unitKgM3` | mm/s / kPa / % / mm / kg/m³ |
| `featO2` / `featPressure` / `featFlow` / `featGravity` / `featThickness` / `featDensity` / `featFuelClass` / `featFlowDir` | Oxygen / Pressure / Airflow / Gravity / Thickness / Density / Material type / Airflow direction |
| `fuelThinSolid` / `fuelThickSolid` / `fuelDroplet` / `fuelGasJet` / `fuelOther` | Thin solid / Thick solid / Fuel droplet / Gas jet / Other |
| `dirOpposed` / `dirConcurrent` / `dirQuiescent` | Opposed / Concurrent / None |

### 12.3 Page copy

All headings and descriptions given in §11 are the exact English strings. Keys follow the pattern `<page><Element>`, e.g., `homeHeadline` = 'Fire has no "up" in space.', `homeSubhead`, `homeCtaLab` = "Open the Fire Lab", `homeDataSentence` = "Built on {runs} test runs from {experiments} NASA experiments across {fuels} materials.", `homeNextTitle` = "Where to go next", `homeNextExplore` …, `exploreTitle`, `exploreDesc`, `exploreShowing` = "Showing {shown} of {total} runs", `exploreClear` = "Clear filters", `exploreDownload` = "Download CSV", `exploreEmptyTitle`, `exploreEmptyBody`, `runTitle` = "Run {id}", `runKeptBurning` = "Kept burning", `runWentOut` = "Went out", `runNoIgnition` = "Did not ignite", `runOpenSource` = "Open source", `runLoadLab` = "Load these conditions in the Fire Lab", `labTitle` = "Fire Lab", `labDesc` = "Set the conditions of a fire test and see what NASA's data predicts.", `labReset` = "Reset to defaults", `labCopyLink` = "Copy link to this setup", `labCompare` = "Compare with Earth", `labGaugeCaption` = "chance the flame keeps burning", `labGoesOut` = "Goes out", `labKeepsBurning` = "Keeps burning", `labSpreadTitle` = "Flame spread rate", `labRange80` = "80% range: {low} to {high} mm/s", `labEffectiveFlow` = "Effective airflow", `labEffectiveFlowCaption` = "(forced {forced} + buoyant {buoyant})", `labSensTitle` = "What moves the risk", `labSensCaption`, `labPhysicsTitle` = "Physics check", `mapTitle` = "Flammability map", `mapDesc`, `mapLegendLow` = "Likely to go out", `mapLegendHigh` = "Likely to keep burning", `mapHatch` = "Little or no NASA data here", `mapOpenLab` = "Open in Fire Lab", `askTitle` = "Ask the NASA papers", `askDesc`, `askPlaceholder` = "Ask about fire in microgravity", `askButton` = "Ask", `askGrounded` = "Answered from NASA sources", `askNotGrounded` = "Not found in FlameSense's NASA sources", `askSaved` = "Saved answer", `askSearching` = "Searching NASA documents", `askCopy` = "Copy answer", `askOpenDoc` = "Open document", `askFootnote`, `earthTitle` = "Lessons for Earth", `earthDesc`, `earthInOrbit` = "In orbit", `earthOnEarth` = "On Earth", `earthPractice` = "What this means in practice", `earthFooter`, `methodsTitle` = "Methods", `aboutTitle` = "About", `notFoundTitle` = "This page drifted off", `notFoundBody`, `notFoundCta` = "Go to Home", tour keys `tour1Title` … `tour7Body`.

### 12.4 Errors and notices

| Key | English |
|---|---|
| `askErrRate` | Too many questions in a short time. Try again in {minutes} min. |
| `askErrUpstream` | The answer service didn't respond. Try again, or pick a suggested question; those answers are saved. |
| `askErrOffline` | You're offline. Suggested questions still work. |
| `askErrInvalid` | Write a question between 3 and 500 characters. |
| `askErrServer` | Something went wrong on the server. Try again in a minute. |
| `numErrRange` | Enter a number between {min} and {max}. |
| `noticeOutside` | {feature} is outside the range NASA tested ({min}–{max} {unit}). The prediction is an extrapolation. |
| `noticeLowSupport` | Few NASA test runs are near these conditions. Use this as a rough estimate. |
| `noticePartialG` | NASA has little or no fire data at Moon or Mars gravity. Predictions here are extrapolations between Earth and orbit. This is a real research gap. |
| `noticeUnavailable` | There isn't enough NASA data to predict {output} reliably, so FlameSense doesn't show one. |
| `noticeOneExperiment` | All runs come from one experiment, so comparisons across experiments aren't possible yet. |
| `mapGapNotice` | No NASA fire tests at {body} gravity are in this dataset ({n} runs). The colors here are extrapolated, which is why most of the map is hatched. Filling this gap matters for Artemis and future Mars missions. |
| `physicsNotApplicable` / `physicsNearExt` / `physicsUnavailable` | (texts in §9.16) |
| `supportHigh` / `supportMedium` / `supportLow` + `…Tip` | (texts in §9.9) |

## 13. Bangla

- Every key above exists in `app_bn.arb`. The agent writes a first draft; native speakers (`[LEAD]`, `[SCI]`) approve in Phase 14.
- Keep scientific terms recognizable: e.g., "মাইক্রোগ্র্যাভিটি (microgravity)" on first use per page.
- Gravity labels: পৃথিবী / মঙ্গল / চাঁদ / আইএসএস কক্ষপথ.
- Tagline: see §2.1.

---

## 14. Flutter implementation (copy into `app/lib/core/theme/`)

### 14.1 `fs_theme_ext.dart`

```dart
import 'package:flutter/material.dart';

/// All FlameSense color tokens (DESIGN.md §3). Access with `context.fs`.
@immutable
class FsColors extends ThemeExtension<FsColors> {
  const FsColors({
    required this.bg, required this.bgGrid, required this.bgGridOpacity,
    required this.surface1, required this.surface2, required this.surface3,
    required this.outline, required this.outlineStrong,
    required this.textPrimary, required this.textSecondary, required this.textTertiary,
    required this.microg, required this.microgStrong, required this.onMicrog, required this.microgTint,
    required this.ember, required this.emberText, required this.emberStrong, required this.onEmber,
    required this.emberTint, required this.partial,
    required this.success, required this.warn, required this.danger,
    required this.successTint, required this.warnTint, required this.dangerTint,
    required this.focusRing, required this.scrim,
    required this.chamberBg, required this.chamberEdge,
    required this.ramp, required this.experimentPalette,
  });

  final Color bg, bgGrid, surface1, surface2, surface3, outline, outlineStrong;
  final double bgGridOpacity;
  final Color textPrimary, textSecondary, textTertiary;
  final Color microg, microgStrong, onMicrog, microgTint;
  final Color ember, emberText, emberStrong, onEmber, emberTint, partial;
  final Color success, warn, danger, successTint, warnTint, dangerTint;
  final Color focusRing, scrim, chamberBg, chamberEdge;
  /// Sustain-probability ramp stops at p = 0, .2, .4, .55, .7, .85, 1 (DESIGN.md §10.4).
  final List<Color> ramp;
  final List<Color> experimentPalette;

  static const rampStops = [0.0, 0.2, 0.4, 0.55, 0.7, 0.85, 1.0];

  /// Color of probability [p] on the ramp.
  Color rampAt(double p) {
    final x = p.clamp(0.0, 1.0);
    for (var i = 0; i < rampStops.length - 1; i++) {
      final a = rampStops[i], b = rampStops[i + 1];
      if (x <= b) return Color.lerp(ramp[i], ramp[i + 1], (x - a) / (b - a))!;
    }
    return ramp.last;
  }

  static const dark = FsColors(
    bg: Color(0xFF0A1020), bgGrid: Color(0xFF16203A), bgGridOpacity: 0.55,
    surface1: Color(0xFF10182B), surface2: Color(0xFF17213A), surface3: Color(0xFF1E2A47),
    outline: Color(0xFF2A3756), outlineStrong: Color(0xFF3B4A6E),
    textPrimary: Color(0xFFEAF0FA), textSecondary: Color(0xFFA9B6CC), textTertiary: Color(0xFF7E8CA6),
    microg: Color(0xFF6CB6FF), microgStrong: Color(0xFF3D8BFF), onMicrog: Color(0xFF06101F),
    microgTint: Color(0x296CB6FF),
    ember: Color(0xFFFF8A3D), emberText: Color(0xFFFF8A3D), emberStrong: Color(0xFFFF6A1A),
    onEmber: Color(0xFF1A0A00), emberTint: Color(0x24FF8A3D), partial: Color(0xFFC79BFF),
    success: Color(0xFF5BD6A0), warn: Color(0xFFF5C451), danger: Color(0xFFFF6B7A),
    successTint: Color(0x245BD6A0), warnTint: Color(0x24F5C451), dangerTint: Color(0x24FF6B7A),
    focusRing: Color(0xFFFFD27A), scrim: Color(0x99000000),
    chamberBg: Color(0xFF070C19), chamberEdge: Color(0xFF26324F),
    ramp: [Color(0xFF172038), Color(0xFF1F3A66), Color(0xFF2F65A8), Color(0xFF6F6FC0),
           Color(0xFFC4607A), Color(0xFFFF8A3D), Color(0xFFFFD27A)],
    experimentPalette: [Color(0xFF6CB6FF), Color(0xFFFF8A3D), Color(0xFF5BD6A0),
                        Color(0xFFF5C451), Color(0xFFC79BFF), Color(0xFFFF7FAE), Color(0xFF7E8CA6)],
  );

  static const light = FsColors(
    bg: Color(0xFFF5F7FA), bgGrid: Color(0xFFE3E8F0), bgGridOpacity: 1.0,
    surface1: Color(0xFFFFFFFF), surface2: Color(0xFFF0F3F8), surface3: Color(0xFFE6ECF5),
    outline: Color(0xFFD5DCE7), outlineStrong: Color(0xFFB3BFD1),
    textPrimary: Color(0xFF0D1526), textSecondary: Color(0xFF42506A), textTertiary: Color(0xFF5E6C85),
    microg: Color(0xFF1F66D6), microgStrong: Color(0xFF1F66D6), onMicrog: Color(0xFFFFFFFF),
    microgTint: Color(0x1A1F66D6),
    ember: Color(0xFFE2621B), emberText: Color(0xFFB4480C), emberStrong: Color(0xFFD9560B),
    onEmber: Color(0xFFFFFFFF), emberTint: Color(0x1AE2621B), partial: Color(0xFF7B4FD6),
    success: Color(0xFF1E8E5A), warn: Color(0xFF9A6A00), danger: Color(0xFFC8283C),
    successTint: Color(0x1A1E8E5A), warnTint: Color(0x1A9A6A00), dangerTint: Color(0x1AC8283C),
    focusRing: Color(0xFF1F66D6), scrim: Color(0x730D1526),
    chamberBg: Color(0xFF070C19), chamberEdge: Color(0xFF26324F),
    ramp: [Color(0xFFEEF3FA), Color(0xFFC9DBF3), Color(0xFF8DB3E6), Color(0xFF9C8FD1),
           Color(0xFFD9707F), Color(0xFFE2621B), Color(0xFF9C3A06)],
    experimentPalette: [Color(0xFF1F66D6), Color(0xFFD9560B), Color(0xFF1E8E5A),
                        Color(0xFF9A6A00), Color(0xFF7B4FD6), Color(0xFFC2306E), Color(0xFF5E6C85)],
  );

  @override
  FsColors copyWith() => this; // Tokens are fixed; themes switch whole objects.

  @override
  FsColors lerp(covariant FsColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    List<Color> ll(List<Color> a, List<Color> b) =>
        List.generate(a.length, (i) => l(a[i], b[i]));
    return FsColors(
      bg: l(bg, other.bg), bgGrid: l(bgGrid, other.bgGrid),
      bgGridOpacity: bgGridOpacity + (other.bgGridOpacity - bgGridOpacity) * t,
      surface1: l(surface1, other.surface1), surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3), outline: l(outline, other.outline),
      outlineStrong: l(outlineStrong, other.outlineStrong),
      textPrimary: l(textPrimary, other.textPrimary), textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      microg: l(microg, other.microg), microgStrong: l(microgStrong, other.microgStrong),
      onMicrog: l(onMicrog, other.onMicrog), microgTint: l(microgTint, other.microgTint),
      ember: l(ember, other.ember), emberText: l(emberText, other.emberText),
      emberStrong: l(emberStrong, other.emberStrong), onEmber: l(onEmber, other.onEmber),
      emberTint: l(emberTint, other.emberTint), partial: l(partial, other.partial),
      success: l(success, other.success), warn: l(warn, other.warn), danger: l(danger, other.danger),
      successTint: l(successTint, other.successTint), warnTint: l(warnTint, other.warnTint),
      dangerTint: l(dangerTint, other.dangerTint), focusRing: l(focusRing, other.focusRing),
      scrim: l(scrim, other.scrim), chamberBg: l(chamberBg, other.chamberBg),
      chamberEdge: l(chamberEdge, other.chamberEdge),
      ramp: ll(ramp, other.ramp), experimentPalette: ll(experimentPalette, other.experimentPalette),
    );
  }
}

extension FsColorsX on BuildContext {
  /// FlameSense color tokens for the current theme.
  FsColors get fs => Theme.of(this).extension<FsColors>()!;
}
```

### 14.2 `typography.dart`

```dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Builds one text style with Archivo variable axes (DESIGN.md §4.2).
TextStyle fsStyle(double size, double height, double wght, double wdth, double tracking,
    Color color, {bool tabular = false}) {
  return TextStyle(
    fontFamily: 'Archivo',
    fontFamilyFallback: const ['NotoSansBengali'],
    fontSize: size,
    height: height / size,
    fontWeight: FontWeight.values[((wght / 100).round() - 1).clamp(0, 8).toInt()],
    fontVariations: [FontVariation('wght', wght), FontVariation('wdth', wdth)],
    letterSpacing: tracking,
    color: color,
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
  );
}

/// Numeric readout styles, read with `Theme.of(context).extension<FsNumbers>()!`.
@immutable
class FsNumbers extends ThemeExtension<FsNumbers> {
  const FsNumbers({required this.hero, required this.lg, required this.md, required this.sm});
  final TextStyle hero, lg, md, sm;
  @override
  FsNumbers copyWith() => this;
  @override
  FsNumbers lerp(covariant FsNumbers? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Text theme for [compact] (< 600 px) or regular widths; [bn] applies Bangla rules (§4.4).
TextTheme fsTextTheme(Color primary, Color secondary, Color tertiary,
    {required bool compact, bool bn = false}) {
  final h = bn ? 1.15 : 1.0;
  double tr(double v) => bn ? 0 : v;
  TextStyle s(double big, double bigLh, double small, double smallLh, double wght, double wdth,
          double tracking, Color c) =>
      fsStyle(compact ? small : big, (compact ? smallLh : bigLh) * h, wght,
          bn ? wdth.clamp(90, 125).toDouble() : wdth, tr(tracking), c);
  return TextTheme(
    displayLarge: s(60, 66, 38, 44, 720, 116, -1.2, primary),
    headlineLarge: s(40, 48, 30, 36, 680, 110, -0.6, primary),
    headlineMedium: s(28, 34, 23, 29, 650, 106, -0.3, primary),
    titleLarge: s(20, 26, 19, 25, 620, 102, -0.1, primary),
    titleMedium: s(17, 24, 16, 22, 600, 100, 0, primary),
    bodyLarge: s(16, 26, 16, 25, 420, 100, 0, primary),
    bodyMedium: s(14, 22, 14, 21, 420, 100, 0.05, secondary),
    labelLarge: s(14, 20, 14, 20, 580, 100, 0.1, primary),
    labelSmall: s(12, 16, 12, 16, 520, 100, 0.2, tertiary),
  );
}

/// Numeric styles (always Archivo digits, condensed, tabular).
FsNumbers fsNumbers(Color primary, {required bool compact}) => FsNumbers(
      hero: fsStyle(compact ? 40 : 52, compact ? 44 : 54, 640, 78, -0.5, primary, tabular: true),
      lg: fsStyle(compact ? 28 : 32, compact ? 32 : 36, 620, 80, -0.3, primary, tabular: true),
      md: fsStyle(compact ? 20 : 22, compact ? 24 : 26, 600, 82, 0, primary, tabular: true),
      sm: fsStyle(14, 20, 520, 88, 0, primary, tabular: true),
    );
```

### 14.3 `theme.dart`

```dart
import 'package:flutter/material.dart';
import 'fs_theme_ext.dart';
import 'typography.dart';

/// Builds the FlameSense ThemeData for [brightness] (DESIGN.md §3, §4, §9).
ThemeData buildFsTheme(Brightness brightness, {required bool compact, bool bn = false}) {
  final c = brightness == Brightness.dark ? FsColors.dark : FsColors.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.microgStrong, onPrimary: c.onMicrog,
    secondary: c.ember, onSecondary: c.onEmber,
    tertiary: c.partial, onTertiary: c.bg,
    error: c.danger, onError: brightness == Brightness.dark ? const Color(0xFF1A0006) : Colors.white,
    surface: c.surface1, onSurface: c.textPrimary, onSurfaceVariant: c.textSecondary,
    surfaceContainerLowest: c.bg, surfaceContainerLow: c.surface1,
    surfaceContainer: c.surface2, surfaceContainerHigh: c.surface3,
    surfaceContainerHighest: c.surface3,
    outline: c.outlineStrong, outlineVariant: c.outline,
    shadow: Colors.black, scrim: c.scrim,
    inverseSurface: c.textPrimary, onInverseSurface: c.surface1, inversePrimary: c.microg,
  );
  final text = fsTextTheme(c.textPrimary, c.textSecondary, c.textTertiary,
      compact: compact, bn: bn);
  OutlineInputBorder border(Color col, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: col, width: w));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: 'Archivo',
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
    focusColor: c.focusRing.withValues(alpha: 0.0), // ring is drawn by widgets (§9.0)
    hoverColor: c.textPrimary.withValues(alpha: brightness == Brightness.dark ? 0.06 : 0.04),
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? c.surface3 : c.textPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: text.bodyMedium!.copyWith(
          color: brightness == Brightness.dark ? c.textPrimary : c.surface1),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: c.surface2, isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: border(c.outline), enabledBorder: border(c.outline),
      focusedBorder: border(c.microg), errorBorder: border(c.danger),
      focusedErrorBorder: border(c.danger, 1.5),
      hintStyle: text.bodyLarge!.copyWith(color: c.textTertiary),
      errorStyle: text.labelSmall!.copyWith(color: c.danger),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 4,
      activeTrackColor: c.microgStrong, inactiveTrackColor: c.outline,
      thumbColor: brightness == Brightness.dark ? c.textPrimary : c.surface1,
      overlayColor: c.microg.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      showValueIndicator: ShowValueIndicator.never,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface1, indicatorColor: c.microgTint,
      selectedIconTheme: IconThemeData(color: c.microg, size: 22),
      unselectedIconTheme: IconThemeData(color: c.textSecondary, size: 22),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface1, indicatorColor: c.microgTint, height: 72,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          size: 22, color: s.contains(WidgetState.selected) ? c.microg : c.textSecondary)),
    ),
    extensions: [c, fsNumbers(c.textPrimary, compact: compact)],
  );
}
```

`app.dart` builds the theme inside a `LayoutBuilder`/`MediaQuery` check: `compact = width < 600`, `bn = locale.languageCode == 'bn'`, and passes `buildFsTheme(Brightness.light, ...)` / `(Brightness.dark, ...)` to `MaterialApp.router(theme:, darkTheme:, themeMode:)`.

> If the installed Flutter version reports an API mismatch (e.g., `withValues` vs `withOpacity`, `WidgetState` vs `MaterialState`), use the equivalent API for that version and note it in PROGRESS.md. Do not change any token values.

### 14.4 `tokens.dart`

```dart
/// Spacing (DESIGN.md §5.1).
abstract final class FsSpace {
  static const s1 = 4.0, s2 = 8.0, s3 = 12.0, s4 = 16.0, s5 = 20.0, s6 = 24.0,
      s8 = 32.0, s10 = 40.0, s12 = 48.0, s16 = 64.0, s20 = 80.0;
}
/// Radii (DESIGN.md §5.2).
abstract final class FsRadius {
  static const xs = 6.0, sm = 10.0, md = 14.0, lg = 20.0, xl = 28.0, pill = 999.0;
}
/// Motion (DESIGN.md §7).
abstract final class FsMotion {
  static const fast = Duration(milliseconds: 120), base = Duration(milliseconds: 200),
      slow = Duration(milliseconds: 320), ignite = Duration(milliseconds: 700),
      value = Duration(milliseconds: 260);
}
/// Breakpoints (DESIGN.md §8.1).
abstract final class FsBreak {
  static const compact = 600.0, expanded = 1024.0, large = 1280.0, xl = 1600.0;
}
```

---

## 15. Web metadata

- `<title>`: "FlameSense: fire safety insights from NASA's space-station fire experiments"
- Meta description: "Explore NASA microgravity combustion data, predict how flames behave in orbit, on the Moon and on Mars, and learn what space fire research means for safety on Earth."
- `theme-color`: `#0A1020` (dark), `#F5F7FA` (light) via `media` attributes.
- Open Graph image `web/og.png`, 1200 × 630: `chamberBg` background, the two flames (teardrop left, sphere right) rendered from the Flutter painter (screenshot) centered-right, wordmark + tagline left in Archivo, no NASA marks.
- Per-route document titles: "Fire Lab | FlameSense", "Flammability map | FlameSense", etc.

---

## 16. Design QA checklist (agent self-check before finishing any UI phase)

- [ ] Only tokens from §3–§7 used (search the diff for `Color(0x` and numeric font sizes outside `core/theme`).
- [ ] Blue = space, orange = Earth everywhere; no decorative use of either.
- [ ] No all-caps, no eyebrows, no middle-dot meta strings, no "→" in buttons.
- [ ] Every number has a unit; every data claim has a source path.
- [ ] Every state (loading, empty, error, unavailable, extrapolation) is designed and reachable.
- [ ] Both themes, both languages, 360 → 1920 px, keyboard-only, reduced motion.
