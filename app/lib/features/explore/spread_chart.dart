import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'chart_style.dart';
import 'run_tooltip.dart';

/// Spread rate (log) vs oxygen, colored and shaped by gravity class (DESIGN.md §10).
class SpreadChart extends ConsumerWidget {
  const SpreadChart({super.key, required this.runs, required this.onOpen});

  final List<RunRecord> runs;
  final ValueChanged<RunRecord> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final st = FsChartStyle(context);
    final pts = runs.where((r) => (r.spreadMmS ?? 0) > 0).toList();
    if (pts.isEmpty) {
      return Center(child: Text(l.chartNoPoints, style: st.tick));
    }
    final ys = pts.map((r) => log10(r.spreadMmS!));
    final minY = ys.reduce(math.min).floorToDouble(),
        maxY = ys.reduce(math.max).ceilToDouble();
    final spots = [
      for (final r in pts)
        ScatterSpot(
          r.o2 * 100,
          log10(r.spreadMmS!),
          dotPainter: st.dot(r.gravityClass),
        ),
    ];
    return Semantics(
      label: l.chartSpreadSummary(fmt.integer(pts.length)),
      child: ScatterChart(
        ScatterChartData(
          minY: minY,
          maxY: maxY == minY ? minY + 1 : maxY,
          gridData: st.grid,
          borderData: st.border,
          scatterSpots: spots,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              axisNameWidget: st.title(l.axisO2),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, m) => Text(fmt.sig(v), style: st.tick),
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: st.title(l.axisSpread),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 48,
                getTitlesWidget: (v, m) =>
                    Text(fmt.sig(math.pow(10, v).toDouble()), style: st.tick),
              ),
            ),
          ),
          scatterTouchData: runTouchData(context, st, spots, pts, fmt, onOpen),
        ),
      ),
    );
  }
}
