import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';

/// Gradient bar, hatch swatch and run symbols (DESIGN.md §10.4–10.5, §11.4).
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final tick = context.text.labelSmall!;
    Widget swatch(Widget child, String label) => Padding(
      padding: const EdgeInsets.only(top: FsSpace.s2),
      child: Row(
        children: [
          SizedBox.square(dimension: 16, child: child),
          const SizedBox(width: FsSpace.s2),
          Expanded(child: Text(label, style: context.text.bodyMedium)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FsRadius.xs),
            gradient: LinearGradient(colors: c.ramp, stops: FsColors.rampStops),
          ),
        ),
        const SizedBox(height: FsSpace.s1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(l.mapLegendLow, style: tick)),
            Flexible(
              child: Text(
                l.mapLegendHigh,
                style: tick,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        swatch(CustomPaint(painter: _HatchSwatch(c)), l.mapHatch),
        swatch(
          Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: c.textPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          l.mapKeptBurning,
        ),
        swatch(
          Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.textPrimary, width: 1.5),
              ),
            ),
          ),
          l.mapWentOut,
        ),
      ],
    );
  }
}

class _HatchSwatch extends CustomPainter {
  _HatchSwatch(this.c);
  final FsColors c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.rampAt(0.5));
    canvas.clipRect(Offset.zero & size);
    final p = Paint()
      ..color = c.textPrimary.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(_HatchSwatch o) => o.c != c;
}
