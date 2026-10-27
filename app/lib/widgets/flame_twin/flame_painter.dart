import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../core/theme/colors.dart';

/// Draws one flame for a gravity value, exactly as DESIGN.md §9.20 specifies.
class FlamePainter extends CustomPainter {
  FlamePainter({
    required this.gravityG,
    required this.phase,
    required this.animate,
    this.intro = 1,
  });

  final double gravityG;

  /// 0–1 position in the 4 s loop.
  final double phase;

  /// False when reduced motion is on: the flame is drawn steady.
  final bool animate;

  /// Ignition progress 0–1: scales 0.55 → 1 and fades 0 → 1 (DESIGN.md §7 mIgnite).
  final double intro;

  /// Buoyancy b = s^1.4 with s = (log10(g) + 6) / 6 (0 = ISS, 1 = Earth).
  static double buoyancy(double g) {
    final s = (math.log(g.clamp(1e-6, 1.0)) / math.ln10 + 6) / 6;
    return math.pow(s, 1.4).toDouble();
  }

  /// The 96-point flame outline (exposed for tests).
  static List<Offset> outline(Size size, double b, double phase, bool animate) {
    final r0 = math.min(size.width, size.height) * 0.22;
    final c = Offset(
      size.width / 2,
      size.height * 0.60 - b * size.height * 0.10,
    );
    final flicker = animate && b > 0.25;
    final tw = 2 * math.pi * phase;
    final dxWave = 0.04 * math.sin(1.3 * tw) + 0.02 * math.sin(3.1 * tw);
    final stretch = 1 + 0.03 * b * math.sin(2.2 * tw);
    return List.generate(96, (i) {
      final th = 2 * math.pi * i / 96;
      final u = math.max(0.0, math.cos(th)), d = math.max(0.0, -math.cos(th));
      final r = r0 * (1 + b * 1.7 * u * u * u) * (1 - b * 0.18 * d * d);
      var x = c.dx + r * math.sin(th);
      var dy = -r * math.cos(th);
      if (flicker && u > 0) {
        x += r0 * b * u * u * u * dxWave;
        dy *= stretch;
      }
      return Offset(x, c.dy + dy);
    });
  }

  static Path _smooth(List<Offset> pts) {
    final path = Path();
    final n = pts.length;
    Offset mid(int i) => (pts[i % n] + pts[(i + 1) % n]) / 2;
    path.moveTo(mid(0).dx, mid(0).dy);
    for (var i = 1; i <= n; i++) {
      final p = pts[i % n], m = mid(i);
      path.quadraticBezierTo(p.dx, p.dy, m.dx, m.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final b = buoyancy(gravityG);
    Color lerp(Color a, Color e) => Color.lerp(a, e, b)!;
    final r0 = math.min(size.width, size.height) * 0.22;
    final c = Offset(
      size.width / 2,
      size.height * 0.60 - b * size.height * 0.10,
    );
    final base = Offset(size.width / 2, size.height * 0.74);
    final pts = outline(size, b, phase, animate);
    final path = _smooth(pts);
    final maxR = pts.map((p) => (p - c).distance).reduce(math.max);

    final introScale = 0.55 + 0.45 * intro.clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(introScale);
    canvas.translate(-base.dx, -base.dy);
    final opacity = (0.78 + 0.22 * b) * intro.clamp(0.0, 1.0);
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
    );

    final glow = lerp(FsFixedColors.glowSpace, FsFixedColors.glowEarth);
    canvas.drawCircle(
      c,
      2.2 * r0,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glow.withValues(alpha: FsFixedColors.glowAlpha),
            glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: 2.2 * r0)),
    );

    final edge = lerp(FsFixedColors.edgeSpace, FsFixedColors.edgeEarth);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          stops: const [0, 0.55, 1],
          colors: [
            lerp(FsFixedColors.coreSpace, FsFixedColors.coreEarth),
            lerp(FsFixedColors.midSpace, FsFixedColors.midEarth),
            edge.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: 1.15 * maxR)),
    );

    final pivot = base + Offset(0, -0.15 * r0);
    final inner = path.transform(
      (Matrix4.identity()
            ..translateByDouble(pivot.dx, pivot.dy, 0, 1)
            ..scaleByDouble(0.55, 0.55, 1, 1)
            ..translateByDouble(-pivot.dx, -pivot.dy, 0, 1))
          .storage,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..color = lerp(
          FsFixedColors.innerSpace,
          FsFixedColors.innerEarth,
        ).withValues(alpha: 0.85),
    );

    if (b > 0.5) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = FsFixedColors.sootHalo.withValues(
            alpha: 0.35 * (b - 0.5) * 2,
          ),
      );
    }
    canvas.restore();
    canvas.restore();

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base, width: 0.9 * r0, height: 4),
        const Radius.circular(2),
      ),
      Paint()..color = FsFixedColors.fuelSample,
    );
  }

  @override
  bool shouldRepaint(FlamePainter old) =>
      old.gravityG != gravityG ||
      old.phase != phase ||
      old.animate != animate ||
      old.intro != intro;
}
