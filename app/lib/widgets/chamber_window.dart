import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';

/// The dark viewport into a combustion chamber, identical in both themes (DESIGN.md §1.2, §6).
class ChamberWindow extends StatelessWidget {
  const ChamberWindow({
    super.key,
    required this.child,
    this.radius = FsRadius.xl,
    this.padding,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.chamberBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.chamberEdge),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          foregroundPainter: _InnerShadowPainter(radius),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}

/// `inset 0 0 40 rgba(0,0,0,.6)` (DESIGN.md §6).
class _InnerShadowPainter extends CustomPainter {
  _InnerShadowPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect.inflate(60))
      ..addRRect(rrect);
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(
      ring,
      Paint()
        ..color = FsFixedColors.chamberInnerShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerShadowPainter old) => old.radius != radius;
}
