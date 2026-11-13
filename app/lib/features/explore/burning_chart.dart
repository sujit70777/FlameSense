import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'chart_style.dart';
import 'explore_filters.dart';
import 'run_tooltip.dart';

/// Kept burning / went out vs airflow (log), deterministic y jitter by run id.
class BurningChart extends ConsumerWidget {
  const BurningChart({super.key, required this.runs, required this.onOpen});

  final List<RunRecord> runs;
  final ValueChanged<RunRecord> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final st = FsChartStyle(context);
    final pts = runs
        .where((r) => r.flowMmS != null && outcomeRank(r) >= 1)
        .toList();
    if (pts.isEmpty) {
      return Center(child: Text(l.chartNoPoints, style: st.tick));
    }
    final kept = pts.where((r) => outcomeRank(r) == 2).length;
    double x(RunRecord r) => log10(r.flowMmS! + 1);
    final maxX = pts.map(x).reduce(math.max).ceilToDouble();
    final spots = [
      for (final r in pts)
        ScatterSpot(
          x(r),
          (outcomeRank(r) == 2 ? 1 : 0) + 0.18 * hashJitter(r.runId),
          dotPainter: st.dot(r.gravityClass),
        ),
    ];
    return Semantics(
      label: l.chartBurningSummary(
        fmt.integer(pts.length),
        fmt.integer(kept),
        fmt.integer(pts.length - kept),
      ),
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: maxX < 1 ? 1 : maxX,
          minY: -0.5,
          maxY: 1.5,
          gridData: st.grid,
          borderData: st.border,
          scatterSpots: spots,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              axisNameWidget: st.title(l.axisFlow),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (v, m) => Text(
                  fmt.sig(math.pow(10, v).toDouble() - 1),
                  style: st.tick,
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 96,
                getTitlesWidget: (v, m) => v == 0 || v == 1
                    ? Text(
                        v == 1 ? l.runKeptBurning : l.runWentOut,
                        style: st.tick,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          scatterTouchData: runTouchData(context, st, spots, pts, fmt, onOpen),
        ),
      ),
    );
  }
}
