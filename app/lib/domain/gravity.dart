import 'dart:math' as math;

import '../core/format.dart';
import '../l10n/app_localizations.dart';

/// Gravity classes used for colors, chips and filters (DESIGN.md §10.2).
enum GravityClass { micro, partial, earth }

/// Earth surface gravity (g).
const kEarthG = 1.0;

/// Mars surface gravity: 3.71 m/s² ÷ 9.80665 (NASA Planetary Fact Sheet).
const kMarsG = 0.3783;

/// Moon surface gravity: 1.62 m/s² ÷ 9.80665 (NASA Planetary Fact Sheet).
const kMoonG = 0.1652;

/// ISS orbit, microgravity.
const kIssG = 1e-6;

/// Standard gravity used to convert g to m/s².
const kStandardGravity = 9.80665;

/// Slider position 0–1 for gravity [g], linear in log10(g) over [−6, 0].
double gravityToSlider(double g) =>
    ((math.log(g.clamp(kIssG, kEarthG)) / math.ln10) + 6) / 6;

/// Gravity for slider position [s] (inverse of [gravityToSlider]).
double sliderToGravity(double s) =>
    math.pow(10, 6 * s.clamp(0.0, 1.0) - 6).toDouble();

/// Gravity class: Earth ≥ 0.9 g, partial ≥ 0.05 g, else microgravity.
GravityClass gravityClassOf(double g) {
  if (g >= 0.9) return GravityClass.earth;
  if (g >= 0.05) return GravityClass.partial;
  return GravityClass.micro;
}

/// Named snap for [g] if within 2% of the log-scale track, else null.
String? gravityName(double g, AppLocalizations l) {
  final s = gravityToSlider(g);
  for (final (value, name) in [
    (kEarthG, l.gEarth),
    (kMarsG, l.gMars),
    (kMoonG, l.gMoon),
    (kIssG, l.gIss),
  ]) {
    if ((gravityToSlider(value) - s).abs() <= 0.02) return name;
  }
  return null;
}

/// "Earth", "Mars", "Moon", "ISS orbit", or a value like "1.2 × 10⁻³ g".
String gravityLabel(double g, AppLocalizations l, FsFormat f) =>
    gravityName(g, l) ?? '${f.gravity(g)} ${l.unitG}';

/// Chip text such as "Moon (0.165 g)" or "ISS orbit (10⁻⁶ g)" (DESIGN.md §9.4).
String gravityChipLabel(double g, AppLocalizations l, FsFormat f) =>
    l.gravityValue(gravityName(g, l) ?? l.gCustom, f.gravity(g));
