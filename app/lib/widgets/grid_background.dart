import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';

/// The faint measurement grid behind shell content (DESIGN.md §3.4).
class GridBackground extends StatelessWidget {
  const GridBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return CustomPaint(
      painter: _GridPainter(
        bg: c.bg,
        minor: c.bgGrid.withValues(alpha: c.bgGridOpacity),
        major: c.isDark ? c.bgGrid.withValues(alpha: 0.9) : c.outline,
      ),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.bg, required this.minor, required this.major});

  final Color bg, minor, major;
  static const minorStep = 24.0, majorStep = 120.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = bg);
    canvas.saveLayer(rect, Paint());
    final minorPaint = Paint()
      ..color = minor
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = major
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += minorStep) {
      final p = x % majorStep == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(x + 0.5, 0), Offset(x + 0.5, size.height), p);
    }
    for (var y = 0.0; y <= size.height; y += minorStep) {
      final p = y % majorStep == 0 ? majorPaint : minorPaint;
      canvas.drawLine(Offset(0, y + 0.5), Offset(size.width, y + 0.5), p);
    }
    // Radial fade: full strength top-left, 35% bottom-right.
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.35)],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.bg != bg || old.minor != minor || old.major != major;
}
