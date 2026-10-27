import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'chart_style.dart';

/// Scatter tooltip for [spots] (parallel to [pts]): (run id, fuel, key values with units) and tap → run detail.
ScatterTouchData runTouchData(
  BuildContext context,
  FsChartStyle st,
  List<ScatterSpot> spots,
  List<RunRecord> pts,
  FsFormat fmt,
  ValueChanged<RunRecord> onOpen,
) {
  final l = AppLocalizations.of(context);
  return ScatterTouchData(
    touchSpotThreshold: FsSize.pointHover,
    touchCallback: (event, response) {
      final spot = response?.touchedSpot;
      if (event is FlTapUpEvent && spot != null) onOpen(pts[spot.spotIndex]);
    },
    mouseCursorResolver: (e, r) =>
        r?.touchedSpot == null ? MouseCursor.defer : SystemMouseCursors.click,
    touchTooltipData: ScatterTouchTooltipData(
      getTooltipColor: (_) => st.tooltipBg,
      maxContentWidth: FsSize.tooltipMaxWidth,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (spot) {
        final i = spots.indexOf(spot);
        if (i < 0) return null;
        final r = pts[i];
        return ScatterTooltipItem(
          r.runId,
          textStyle: st.tick.copyWith(
            color: st.tooltipFg,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.start,
          children: [
            TextSpan(
              text:
                  '\n${r.fuelName}\n${l.featO2} ${fmt.sig(r.o2 * 100)} ${l.unitPercent}, '
                  '${fmt.sig(r.pressureKpa)} ${l.unitKpa}'
                  '${r.flowMmS == null ? '' : '\n${l.featFlow} ${fmt.sig(r.flowMmS!)} ${l.unitMmS}'}'
                  '${r.spreadMmS == null ? '' : '\n${l.fieldSpread} ${fmt.sig(r.spreadMmS!)} ${l.unitMmS}'}',
              style: st.tick.copyWith(color: st.tooltipFg),
            ),
          ],
        );
      },
    ),
  );
}
