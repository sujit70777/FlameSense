import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';

/// Draws the 2 px keyboard focus ring with a 2 px offset around [child]
/// whenever a descendant has keyboard focus (DESIGN.md §9.0). Never removed.
class FsFocusRing extends StatefulWidget {
  const FsFocusRing({
    super.key,
    required this.child,
    this.radius = FsRadius.sm,
  });

  final Widget child;

  /// Corner radius of the element; the ring follows it.
  final double radius;

  @override
  State<FsFocusRing> createState() => _FsFocusRingState();
}

class _FsFocusRingState extends State<FsFocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    final c = context.fs;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (f) => setState(() => _focused = f),
      child: CustomPaint(
        foregroundPainter: _focused && keyboard
            ? _RingPainter(
                c.focusRing,
                c.isDark ? null : c.surface1,
                widget.radius,
              )
            : null,
        child: widget.child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.color, this.offsetFill, this.radius);

  final Color color;
  final Color? offsetFill;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const w = FsSize.focusRingWidth, gap = FsSize.focusRingOffset;
    final rect = Offset.zero & size;
    if (offsetFill != null) {
      final inner = RRect.fromRectAndRadius(
        rect.inflate(gap / 2),
        Radius.circular(radius + gap / 2),
      );
      canvas.drawRRect(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = gap
          ..color = offsetFill!,
      );
    }
    final ring = RRect.fromRectAndRadius(
      rect.inflate(gap + w / 2),
      Radius.circular(radius + gap + w / 2),
    );
    canvas.drawRRect(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.offsetFill != offsetFill;
}
