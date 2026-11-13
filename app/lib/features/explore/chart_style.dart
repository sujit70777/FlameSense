import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/gravity.dart';
import '../../widgets/gravity_chip.dart';

/// Shared chart styling (DESIGN.md §10.1).
class FsChartStyle {
  FsChartStyle(this.context);

  final BuildContext context;

  FsColors get c => context.fs;

  /// Horizontal gridlines only, 1 px outline @ 60%.
  FlGridData get grid => FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: c.outline.withValues(alpha: 0.6), strokeWidth: 1),
  );

  /// Axes: 1 px outlineStrong on the left and bottom.
  FlBorderData get border => FlBorderData(
    show: true,
    border: Border(
      left: BorderSide(color: c.outlineStrong),
      bottom: BorderSide(color: c.outlineStrong),
    ),
  );

  TextStyle get tick => context.text.labelSmall!;

  /// Axis title widget (bodySmall, textSecondary, with units).
  Widget title(String t) => Text(t, style: context.text.bodyMedium);

  /// Tooltip background (FsTooltip style).
  Color get tooltipBg => c.isDark ? c.surface3 : c.textPrimary;
  Color get tooltipFg => c.isDark ? c.textPrimary : c.surface1;

  /// Dot for a gravity class: filled circle (µg), diamond (partial), hollow circle (Earth).
  FlDotPainter dot(GravityClass g, {double radius = FsSize.pointDefault}) {
    final color = gravityColor(context, g);
    return switch (g) {
      GravityClass.micro => FlDotCirclePainter(
        radius: radius,
        color: color,
        strokeWidth: 0,
      ),
      GravityClass.partial => DiamondDotPainter(
        color: color,
        radius: radius + 1,
      ),
      GravityClass.earth => FlDotCirclePainter(
        radius: radius,
        color: Colors.transparent,
        strokeColor: c.isDark ? color : c.emberStrong,
        strokeWidth: 2,
      ),
    };
  }
}

/// Filled diamond point for partial-gravity runs (DESIGN.md §10.2).
class DiamondDotPainter extends FlDotPainter {
  const DiamondDotPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void draw(Canvas canvas, FlSpot spot, Offset o) {
    final path = Path()
      ..moveTo(o.dx, o.dy - radius)
      ..lineTo(o.dx + radius, o.dy)
      ..lineTo(o.dx, o.dy + radius)
      ..lineTo(o.dx - radius, o.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  Size getSize(FlSpot spot) => Size.square(radius * 2);

  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) =>
      t < 0.5 ? a : b;

  @override
  List<Object?> get props => [color, radius];
}

/// Deterministic jitter in [-1, 1] from a run id (stable across rebuilds).
double hashJitter(String id) {
  var h = 0x811C9DC5;
  for (final cu in id.codeUnits) {
    h = ((h ^ cu) * 0x01000193) & 0xFFFFFFFF;
  }
  return (h / 0xFFFFFFFF) * 2 - 1;
}

/// log10 helper.
double log10(double v) => math.log(v) / math.ln10;
