import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../explore/chart_style.dart';
import 'simple_table.dart';

/// "How well it works": metrics tables from metrics.json and the calibration chart (DESIGN.md §11.7 #validation).
class MethodsValidation extends ConsumerWidget {
  const MethodsValidation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final m = ref.watch(loadedDataProvider).metrics;
    String v(double? x, {bool pct = false}) =>
        x == null ? l.notAvailable : (pct ? '${f.sig(x * 100)}%' : f.sig(x));
    Widget table(List<(String, String, String)> rows) => SimpleTable(
      headers: [l.colMetric, l.colValue, l.colPlain],
      flex: const [2, 1, 3],
      rows: [
        for (final (a, b, c) in rows)
          [
            SimpleTable.t(context, a),
            SimpleTable.t(context, b, num: true),
            SimpleTable.t(context, c),
          ],
      ],
    );
    final s = m.sustain, p = m.spread;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.methodsSustainModel, style: context.text.titleMedium),
        const SizedBox(height: FsSpace.s2),
        if (!s.available)
          Text(
            l.methodsTaskUnavailable(s.reason ?? ''),
            style: context.text.bodyMedium,
          )
        else
          table([
            (l.metricRows, f.integer(s.nRows), ''),
            (l.metricGroups, f.integer(s.nGroups), ''),
            (l.metricCv, s.cv ?? '', ''),
            (l.metricRocAuc, v(s.rocAuc), l.metricRocAucPlain),
            (l.metricBrier, v(s.brier), l.metricBrierPlain),
            (
              l.metricBaselineBrier,
              v(s.baselineBrier),
              l.metricBaselineBrierPlain,
            ),
            (l.metricAccuracy, v(s.accuracy, pct: true), l.metricAccuracyPlain),
          ]),
        if (s.available && s.calibrationBins.isNotEmpty) ...[
          const SizedBox(height: FsSpace.s4),
          Text(l.methodsCalibration, style: context.text.bodyMedium),
          const SizedBox(height: FsSpace.s2),
          SizedBox(
            height: 280,
            child: _Calibration(bins: s.calibrationBins, fmt: f),
          ),
        ],
        const SizedBox(height: FsSpace.s5),
        Text(l.methodsSpreadModel, style: context.text.titleMedium),
        const SizedBox(height: FsSpace.s2),
        if (!p.available)
          Text(
            l.methodsTaskUnavailable(p.reason ?? ''),
            style: context.text.bodyMedium,
          )
        else
          table([
            (l.metricRows, f.integer(p.nRows), ''),
            (l.metricGroups, f.integer(p.nGroups), ''),
            (l.metricCv, p.cv ?? '', ''),
            (l.metricMae, '${v(p.mae)} ${l.unitMmS}', l.metricMaePlain),
            (
              l.metricBaselineMae,
              '${v(p.baselineMae)} ${l.unitMmS}',
              l.metricBaselineMaePlain,
            ),
            (
              l.metricMedianApe,
              v(p.medianApe, pct: true),
              l.metricMedianApePlain,
            ),
            (l.metricR2, v(p.r2Log), l.metricR2Plain),
            (l.metricCoverage, v(p.coverage, pct: true), l.metricCoveragePlain),
            (
              l.metricPhysicsMae,
              p.physicsMae == null
                  ? l.notAvailable
                  : '${v(p.physicsMae)} ${l.unitMmS}',
              l.metricPhysicsMaePlain,
            ),
          ]),
        const SizedBox(height: FsSpace.s4),
        Text(l.methodsCvNote, style: context.text.bodyLarge),
        Text(l.methodsBaselineNote, style: context.text.bodyLarge),
        for (final w in {...s.warnings, ...p.warnings})
          Text('•  $w', style: context.text.bodyMedium),
      ],
    );
  }
}

class _Calibration extends StatelessWidget {
  const _Calibration({required this.bins, required this.fmt});

  final List<List<double>> bins;
  final FsFormat fmt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final st = FsChartStyle(context);
    final c = context.fs;
    return Semantics(
      label: l.methodsCalibrationSemantics(fmt.integer(bins.length)),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 1,
          minY: 0,
          maxY: 1,
          gridData: st.grid,
          borderData: st.border,
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 0), FlSpot(1, 1)],
              color: c.outlineStrong,
              dashArray: [6, 4],
              dotData: const FlDotData(show: false),
              barWidth: 1,
            ),
            LineChartBarData(
              spots: [for (final b in bins) FlSpot(b[0], b[1])],
              color: c.microg,
              barWidth: 2,
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              axisNameWidget: st.title(l.axisPredicted),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(fmt.sig(v), style: st.tick),
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: st.title(l.axisObserved),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.25,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(fmt.sig(v), style: st.tick),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
