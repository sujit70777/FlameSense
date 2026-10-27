import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/run_record.dart';
import 'map_grid.dart';

/// Planned-test marker or numbered pin drawn over the map (used by Mission detail).
class MapMarker {
  const MapMarker({
    required this.flow,
    required this.o2,
    this.label,
    this.square = false,
  });
  final double flow, o2;
  final String? label;
  final bool square;
}

/// Heatmap cells, low-support hatching, 50% contour, run overlay and pins (DESIGN.md §10.4–10.6).
class HeatmapPainter extends CustomPainter {
  HeatmapPainter({
    required this.grid,
    required this.colors,
    required this.runs,
    required this.showContour,
    this.pinned,
    this.hover,
    this.markers = const [],
    this.labelStyle,
  });

  final MapGrid? grid;
  final FsColors colors;
  final List<RunRecord> runs;
  final bool showContour;
  final (int, int)? pinned, hover;
  final List<MapMarker> markers;
  final TextStyle? labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final g = grid;
    final cw = size.width / kMapCols, ch = size.height / kMapRows;
    Offset at(double col, double row) =>
        Offset(col * cw, size.height - row * ch);
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.surface2);
    if (g != null) {
      for (var r = 0; r < kMapRows; r++) {
        for (var c = 0; c < kMapCols; c++) {
          final rect = Rect.fromLTWH(
            c * cw,
            size.height - (r + 1) * ch,
            cw + 0.5,
            ch + 0.5,
          );
          canvas.drawRect(rect, Paint()..color = colors.rampAt(g.at(c, r)));
        }
      }
      _hatch(canvas, size, g, cw, ch);
      if (showContour) _contour(canvas, size, g, at);
    }
    for (final run in runs) {
      if (g == null) continue;
      final o = at(g.colOf(run.flowMmS!), g.rowOf(run.o2));
      if (!(Offset.zero & size).contains(o)) continue;
      const rad = FsSize.pointMap / 2 + 1.5;
      canvas.drawCircle(o, rad + 1.5, Paint()..color = colors.surface1);
      final kept = run.sustained == true;
      canvas.drawCircle(
        o,
        rad,
        Paint()
          ..color = colors.textPrimary
          ..style = kept ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    if (g != null) _markers(canvas, g, at);
    for (final (cell, color, width) in [
      (hover, colors.textPrimary.withValues(alpha: 0.6), 1.0),
      (pinned, colors.focusRing, 2.0),
    ]) {
      if (cell == null) continue;
      final rect = Rect.fromLTWH(
        cell.$1 * cw,
        size.height - (cell.$2 + 1) * ch,
        cw,
        ch,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..color = color,
      );
    }
  }

  void _hatch(Canvas canvas, Size size, MapGrid g, double cw, double ch) {
    final paint = Paint()
      ..color = colors.textPrimary.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    final clip = Path();
    for (var r = 0; r < kMapRows; r++) {
      for (var c = 0; c < kMapCols; c++) {
        if (g.lowAt(c, r)) {
          clip.addRect(
            Rect.fromLTWH(
              c * cw,
              size.height - (r + 1) * ch,
              cw + 0.5,
              ch + 0.5,
            ),
          );
        }
      }
    }
    canvas.save();
    canvas.clipPath(clip);
    for (var x = -size.height; x < size.width; x += 6) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
    canvas.restore();
  }

  void _contour(
    Canvas canvas,
    Size size,
    MapGrid g,
    Offset Function(double, double) at,
  ) {
    final segs = contourSegments(g.prob, kMapCols, kMapRows, 0.5);
    if (segs.isEmpty) return;
    Offset p(Offset cell) => at(cell.dx + 0.5, cell.dy + 0.5);
    final halo = Paint()
      ..color = colors.surface1.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final line = Paint()
      ..color = colors.textPrimary.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final s in segs) {
      canvas.drawLine(p(s.$1), p(s.$2), halo);
    }
    for (final s in segs) {
      canvas.drawLine(p(s.$1), p(s.$2), line);
    }
    var end = p(segs.first.$1);
    for (final s in segs) {
      for (final o in [p(s.$1), p(s.$2)]) {
        if (o.dx > end.dx) end = o;
      }
    }
    _text(canvas, '50%', end + const Offset(-26, -16));
  }

  void _markers(Canvas canvas, MapGrid g, Offset Function(double, double) at) {
    for (final m in markers) {
      final o = at(g.colOf(m.flow), g.rowOf(m.o2));
      if (m.square) {
        canvas.drawRect(
          Rect.fromCenter(center: o, width: 12, height: 12),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = colors.partial,
        );
      } else {
        canvas.drawCircle(o, 11, Paint()..color = colors.textPrimary);
        _text(
          canvas,
          m.label ?? '',
          o - const Offset(4, 9),
          color: colors.surface1,
        );
      }
    }
  }

  void _text(Canvas canvas, String t, Offset o, {Color? color}) {
    final style = (labelStyle ?? const TextStyle()).copyWith(
      color: color ?? colors.textPrimary,
    );
    final b = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(style.getTextStyle())
      ..addText(t);
    final para = b.build()..layout(const ui.ParagraphConstraints(width: 60));
    canvas.drawParagraph(para, o);
  }

  @override
  bool shouldRepaint(HeatmapPainter o) =>
      o.grid != grid ||
      o.colors != colors ||
      o.runs != runs ||
      o.showContour != showContour ||
      o.pinned != pinned ||
      o.hover != hover ||
      o.markers != markers;
}
