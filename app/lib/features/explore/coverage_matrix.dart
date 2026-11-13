import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/coverage.dart';
import '../../l10n/app_localizations.dart';

/// Localized name of a coverage gravity class.
String gravityLabel(AppLocalizations l, String g) => switch (g) {
  'microgravity' => l.coverageGravityMicro,
  'moon_mars' => l.coverageGravityMoonMars,
  _ => l.coverageGravityEarth,
};

/// Band label as printed ("18-24" -> "18–24").
String bandText(String b) => b.replaceAll('-', '–');

/// Gravity class x O2 band matrix for one pressure band (DESIGN.md §11.2b).
class CoverageMatrix extends StatelessWidget {
  const CoverageMatrix({
    super.key,
    required this.file,
    required this.pressureBand,
    required this.selected,
    required this.onSelect,
  });

  final CoverageFile file;
  final String pressureBand;

  /// Selected (gravity class, O2 band), or null.
  final (String, String)? selected;
  final ValueChanged<(String, String)?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final maxRuns = file.cells.fold<int>(0, (m, x) => math.max(m, x.runs));
    final headStyle = context.text.labelMedium!.copyWith(
      color: c.textSecondary,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text(l.coverageOxygen, style: headStyle)),
            for (final o in file.o2Bands)
              Expanded(
                flex: 2,
                child: Text(
                  l.coverageO2Band(bandText(o)),
                  textAlign: TextAlign.center,
                  style: headStyle,
                ),
              ),
          ],
        ),
        const SizedBox(height: FsSpace.s2),
        for (final g in CoverageFile.gravityClasses)
          Padding(
            padding: const EdgeInsets.only(bottom: FsSpace.s1),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    gravityLabel(l, g),
                    style: context.text.bodyMedium,
                  ),
                ),
                for (final o in file.o2Bands)
                  Expanded(
                    flex: 2,
                    child: _Cell(
                      cell: file.cell(g, o, pressureBand),
                      maxRuns: maxRuns,
                      selected: selected == (g, o),
                      onTap: () => onSelect(selected == (g, o) ? null : (g, o)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.cell,
    required this.maxRuns,
    required this.selected,
    required this.onTap,
  });

  final CoverageCell cell;
  final int maxRuns;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final empty = cell.runs == 0;
    // Log scale so a few runs still read as "tested" next to hundreds.
    final t = empty
        ? 0.0
        : math.log(1 + cell.runs) / math.log(1 + math.max(maxRuns, 1));
    final bg = empty ? c.surface2 : Color.lerp(c.microgTint, c.microg, t)!;
    final fg = !empty && t > 0.55 ? c.onMicrog : c.textPrimary;
    return Semantics(
      button: !empty,
      selected: selected,
      label: l.coverageCellSemantics(
        '${cell.runs}',
        gravityLabel(l, cell.gravityClass),
        l.coverageO2Band(bandText(cell.o2Band)),
        l.coveragePressureBand(bandText(cell.pressureBand)),
      ),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: FsSpace.s1 / 2),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FsRadius.xs),
            side: BorderSide(
              color: selected ? c.textPrimary : c.outline,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: empty ? null : onTap,
            child: SizedBox(
              height: FsSize.touch,
              child: CustomPaint(
                painter: empty ? HatchPainter(c.textPrimary) : null,
                child: Center(
                  child: Text(
                    '${cell.runs}',
                    style: context.nums.sm.copyWith(color: fg),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 45° hatching, 1 px lines every 6 px at 30% of [color] (DESIGN.md §10.5).
class HatchPainter extends CustomPainter {
  HatchPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final p = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(HatchPainter o) => o.color != color;
}
