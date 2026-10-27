import 'package:flutter/material.dart';

/// All FlameSense color tokens (DESIGN.md §3). Access with `context.fs`.
@immutable
class FsColors extends ThemeExtension<FsColors> {
  const FsColors({
    required this.bg,
    required this.bgGrid,
    required this.bgGridOpacity,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.outline,
    required this.outlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.microg,
    required this.microgStrong,
    required this.onMicrog,
    required this.microgTint,
    required this.ember,
    required this.emberText,
    required this.emberStrong,
    required this.onEmber,
    required this.emberTint,
    required this.partial,
    required this.success,
    required this.warn,
    required this.danger,
    required this.successTint,
    required this.warnTint,
    required this.dangerTint,
    required this.focusRing,
    required this.scrim,
    required this.chamberBg,
    required this.chamberEdge,
    required this.ramp,
    required this.experimentPalette,
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

  /// True for the dark ("Orbit night") palette.
  bool get isDark => bg == dark.bg;

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
    bg: Color(0xFF0A1020),
    bgGrid: Color(0xFF16203A),
    bgGridOpacity: 0.55,
    surface1: Color(0xFF10182B),
    surface2: Color(0xFF17213A),
    surface3: Color(0xFF1E2A47),
    outline: Color(0xFF2A3756),
    outlineStrong: Color(0xFF3B4A6E),
    textPrimary: Color(0xFFEAF0FA),
    textSecondary: Color(0xFFA9B6CC),
    textTertiary: Color(0xFF7E8CA6),
    microg: Color(0xFF6CB6FF),
    microgStrong: Color(0xFF3D8BFF),
    onMicrog: Color(0xFF06101F),
    microgTint: Color(0x296CB6FF),
    ember: Color(0xFFFF8A3D),
    emberText: Color(0xFFFF8A3D),
    emberStrong: Color(0xFFFF6A1A),
    onEmber: Color(0xFF1A0A00),
    emberTint: Color(0x24FF8A3D),
    partial: Color(0xFFC79BFF),
    success: Color(0xFF5BD6A0),
    warn: Color(0xFFF5C451),
    danger: Color(0xFFFF6B7A),
    successTint: Color(0x245BD6A0),
    warnTint: Color(0x24F5C451),
    dangerTint: Color(0x24FF6B7A),
    focusRing: Color(0xFFFFD27A),
    scrim: Color(0x99000000),
    chamberBg: Color(0xFF070C19),
    chamberEdge: Color(0xFF26324F),
    ramp: [
      Color(0xFF172038),
      Color(0xFF1F3A66),
      Color(0xFF2F65A8),
      Color(0xFF6F6FC0),
      Color(0xFFC4607A),
      Color(0xFFFF8A3D),
      Color(0xFFFFD27A),
    ],
    experimentPalette: [
      Color(0xFF6CB6FF),
      Color(0xFFFF8A3D),
      Color(0xFF5BD6A0),
      Color(0xFFF5C451),
      Color(0xFFC79BFF),
      Color(0xFFFF7FAE),
      Color(0xFF7E8CA6),
    ],
  );

  static const light = FsColors(
    bg: Color(0xFFF5F7FA),
    bgGrid: Color(0xFFE3E8F0),
    bgGridOpacity: 1.0,
    surface1: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0F3F8),
    surface3: Color(0xFFE6ECF5),
    outline: Color(0xFFD5DCE7),
    outlineStrong: Color(0xFFB3BFD1),
    textPrimary: Color(0xFF0D1526),
    textSecondary: Color(0xFF42506A),
    textTertiary: Color(0xFF5E6C85),
    microg: Color(0xFF1F66D6),
    microgStrong: Color(0xFF1F66D6),
    onMicrog: Color(0xFFFFFFFF),
    microgTint: Color(0x1A1F66D6),
    ember: Color(0xFFE2621B),
    emberText: Color(0xFFB4480C),
    emberStrong: Color(0xFFD9560B),
    onEmber: Color(0xFFFFFFFF),
    emberTint: Color(0x1AE2621B),
    partial: Color(0xFF7B4FD6),
    success: Color(0xFF1E8E5A),
    warn: Color(0xFF9A6A00),
    danger: Color(0xFFC8283C),
    successTint: Color(0x1A1E8E5A),
    warnTint: Color(0x1A9A6A00),
    dangerTint: Color(0x1AC8283C),
    focusRing: Color(0xFF1F66D6),
    scrim: Color(0x730D1526),
    chamberBg: Color(0xFF070C19),
    chamberEdge: Color(0xFF26324F),
    ramp: [
      Color(0xFFEEF3FA),
      Color(0xFFC9DBF3),
      Color(0xFF8DB3E6),
      Color(0xFF9C8FD1),
      Color(0xFFD9707F),
      Color(0xFFE2621B),
      Color(0xFF9C3A06),
    ],
    experimentPalette: [
      Color(0xFF1F66D6),
      Color(0xFFD9560B),
      Color(0xFF1E8E5A),
      Color(0xFF9A6A00),
      Color(0xFF7B4FD6),
      Color(0xFFC2306E),
      Color(0xFF5E6C85),
    ],
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
      bg: l(bg, other.bg),
      bgGrid: l(bgGrid, other.bgGrid),
      bgGridOpacity: bgGridOpacity + (other.bgGridOpacity - bgGridOpacity) * t,
      surface1: l(surface1, other.surface1),
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      outline: l(outline, other.outline),
      outlineStrong: l(outlineStrong, other.outlineStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      microg: l(microg, other.microg),
      microgStrong: l(microgStrong, other.microgStrong),
      onMicrog: l(onMicrog, other.onMicrog),
      microgTint: l(microgTint, other.microgTint),
      ember: l(ember, other.ember),
      emberText: l(emberText, other.emberText),
      emberStrong: l(emberStrong, other.emberStrong),
      onEmber: l(onEmber, other.onEmber),
      emberTint: l(emberTint, other.emberTint),
      partial: l(partial, other.partial),
      success: l(success, other.success),
      warn: l(warn, other.warn),
      danger: l(danger, other.danger),
      successTint: l(successTint, other.successTint),
      warnTint: l(warnTint, other.warnTint),
      dangerTint: l(dangerTint, other.dangerTint),
      focusRing: l(focusRing, other.focusRing),
      scrim: l(scrim, other.scrim),
      chamberBg: l(chamberBg, other.chamberBg),
      chamberEdge: l(chamberEdge, other.chamberEdge),
      ramp: ll(ramp, other.ramp),
      experimentPalette: ll(experimentPalette, other.experimentPalette),
    );
  }
}

extension FsColorsX on BuildContext {
  /// FlameSense color tokens for the current theme.
  FsColors get fs => Theme.of(this).extension<FsColors>()!;
}
