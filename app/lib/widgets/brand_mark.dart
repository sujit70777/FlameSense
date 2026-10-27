import 'package:flutter/material.dart';

import '../core/theme/colors.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/typography.dart';

/// The FlameSense mark: a teardrop (Earth flame) holding a sphere (space flame).
/// Path from DESIGN.md §2.3, drawn on a 64-unit viewBox.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 28,
    this.onDark,
    this.circleOpacity = 1,
  });

  final double size;

  /// Force the dark-background variant; defaults to the current theme.
  final bool? onDark;

  /// Opacity of the inner sphere (pulsed on the loading screen).
  final double circleOpacity;

  @override
  Widget build(BuildContext context) {
    final dark = onDark ?? context.fs.isDark;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: BrandMarkPainter(dark: dark, circleOpacity: circleOpacity),
      ),
    );
  }
}

/// Painter for [BrandMark].
class BrandMarkPainter extends CustomPainter {
  BrandMarkPainter({required this.dark, this.circleOpacity = 1});

  final bool dark;
  final double circleOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64, size.height / 64);
    final drop = Path()
      ..moveTo(32, 5)
      ..cubicTo(32, 5, 51, 25, 51, 39)
      ..arcToPoint(const Offset(13, 39), radius: const Radius.circular(19))
      ..cubicTo(13, 25, 32, 5, 32, 5)
      ..close();
    canvas.drawPath(
      drop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = dark
            ? FsFixedColors.markStrokeDark
            : FsFixedColors.markStrokeLight,
    );
    final circle = dark
        ? FsFixedColors.markCircleDark
        : FsFixedColors.markCircleLight;
    canvas.drawCircle(
      const Offset(32, 39),
      9,
      Paint()..color = circle.withValues(alpha: circleOpacity),
    );
  }

  @override
  bool shouldRepaint(BrandMarkPainter old) =>
      old.dark != dark || old.circleOpacity != circleOpacity;
}

/// Mark + "FlameSense" wordmark (DESIGN.md §2.4).
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.showWordmark = true, this.markSize = 28});

  final bool showWordmark;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final base = context.text.titleLarge!;
    final word = fsStyle(
      base.fontSize!,
      base.fontSize! * 1.2,
      700,
      112,
      -0.4,
      c.textPrimary,
    );
    return Semantics(
      label: 'FlameSense',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(size: markSize),
          if (showWordmark) ...[
            const SizedBox(width: 10),
            ExcludeSemantics(child: Text('FlameSense', style: word)),
          ],
        ],
      ),
    );
  }
}
