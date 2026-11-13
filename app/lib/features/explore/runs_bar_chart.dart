import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'chart_style.dart';

/// Runs per experiment; up to 6 palette colors, then "Other" (DESIGN.md §10.3).
class RunsBarChart extends ConsumerWidget {
  const RunsBarChart({super.key, required this.runs});

  final List<RunRecord> runs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final st = FsChartStyle(context);
    final counts = <String, int>{};
    for (final r in runs) {
      counts[r.experiment] = (counts[r.experiment] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return Center(child: Text(l.chartNoPoints, style: st.tick));
    }
    final names = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    final palette = context.fs.experimentPalette;
    return Semantics(
      label: l.chartRunsSummary(
        fmt.integer(runs.length),
        fmt.integer(names.length),
      ),
      child: BarChart(
        BarChartData(
          gridData: st.grid,
          borderData: st.border,
          barGroups: [
            for (var i = 0; i < names.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: counts[names[i]]!.toDouble(),
                    width: 22,
                    color: palette[i < 6 ? i : 6],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(FsRadius.xs),
                    ),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => st.tooltipBg,
              getTooltipItem: (g, _, rod, _) => BarTooltipItem(
                '${names[g.x]}\n${fmt.integer(rod.toY)}',
                st.tick.copyWith(color: st.tooltipFg),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              axisNameWidget: st.title(l.axisRuns),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, m) => Text(fmt.integer(v), style: st.tick),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, m) => Padding(
                  padding: const EdgeInsets.only(top: FsSpace.s1),
                  child: Text(
                    names[v.toInt()],
                    style: st.tick,
                    overflow: TextOverflow.ellipsis,
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
