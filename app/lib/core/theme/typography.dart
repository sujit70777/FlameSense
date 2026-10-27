import 'package:flutter/material.dart';

/// Builds one text style with Archivo variable axes (DESIGN.md §4.2).
TextStyle fsStyle(
  double size,
  double height,
  double wght,
  double wdth,
  double tracking,
  Color color, {
  bool tabular = false,
}) {
  return TextStyle(
    fontFamily: 'Archivo',
    fontFamilyFallback: const ['NotoSansBengali'],
    fontSize: size,
    height: height / size,
    fontWeight:
        FontWeight.values[((wght / 100).round() - 1).clamp(0, 8).toInt()],
    fontVariations: [FontVariation('wght', wght), FontVariation('wdth', wdth)],
    letterSpacing: tracking,
    color: color,
    fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
  );
}

/// Numeric readout styles, read with `Theme.of(context).extension<FsNumbers>()!`.
@immutable
class FsNumbers extends ThemeExtension<FsNumbers> {
  const FsNumbers({
    required this.hero,
    required this.lg,
    required this.md,
    required this.sm,
  });
  final TextStyle hero, lg, md, sm;
  @override
  FsNumbers copyWith() => this;
  @override
  FsNumbers lerp(covariant FsNumbers? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

/// Text theme for [compact] (< 600 px) or regular widths; [bn] applies Bangla rules (§4.4).
TextTheme fsTextTheme(
  Color primary,
  Color secondary,
  Color tertiary, {
  required bool compact,
  bool bn = false,
}) {
  final h = bn ? 1.15 : 1.0;
  double tr(double v) => bn ? 0 : v;
  TextStyle s(
    double big,
    double bigLh,
    double small,
    double smallLh,
    double wght,
    double wdth,
    double tracking,
    Color c,
  ) => fsStyle(
    compact ? small : big,
    (compact ? smallLh : bigLh) * h,
    wght,
    bn ? wdth.clamp(90, 125).toDouble() : wdth,
    tr(tracking),
    c,
  );
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
  hero: fsStyle(
    compact ? 40 : 52,
    compact ? 44 : 54,
    640,
    78,
    -0.5,
    primary,
    tabular: true,
  ),
  lg: fsStyle(
    compact ? 28 : 32,
    compact ? 32 : 36,
    620,
    80,
    -0.3,
    primary,
    tabular: true,
  ),
  md: fsStyle(
    compact ? 20 : 22,
    compact ? 24 : 26,
    600,
    82,
    0,
    primary,
    tabular: true,
  ),
  sm: fsStyle(14, 20, 520, 88, 0, primary, tabular: true),
);

extension FsTextX on BuildContext {
  /// The FlameSense text theme for the current width and locale.
  TextTheme get text => Theme.of(this).textTheme;

  /// Numeric readout styles (DESIGN.md §4.2 num*).
  FsNumbers get nums => Theme.of(this).extension<FsNumbers>()!;
}
