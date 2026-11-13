import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'explore_filters.dart';

/// Column widths (px) and alignment for the runs table (DESIGN.md §9.22).
const columnWidths = {
  RunColumn.run: 200.0,
  RunColumn.experiment: 120.0,
  RunColumn.fuel: 160.0,
  RunColumn.o2: 80.0,
  RunColumn.pressure: 120.0,
  RunColumn.flow: 130.0,
  RunColumn.gravity: 110.0,
  RunColumn.outcome: 150.0,
  RunColumn.spread: 120.0,
  RunColumn.quality: 120.0,
};

const numericColumns = {
  RunColumn.o2,
  RunColumn.pressure,
  RunColumn.flow,
  RunColumn.gravity,
  RunColumn.spread,
};

/// Header label (units in the header, e.g. "O₂ (%)").
String columnLabel(AppLocalizations l, RunColumn c) => switch (c) {
  RunColumn.run => l.colRun,
  RunColumn.experiment => l.colExperiment,
  RunColumn.fuel => l.colFuel,
  RunColumn.o2 => l.colO2,
  RunColumn.pressure => l.colPressure,
  RunColumn.flow => l.colFlow,
  RunColumn.gravity => l.colGravity,
  RunColumn.outcome => l.colOutcome,
  RunColumn.spread => l.colSpread,
  RunColumn.quality => l.colQuality,
};

/// Outcome text for a run.
String outcomeText(AppLocalizations l, RunRecord r) => switch (outcomeRank(r)) {
  2 => l.runKeptBurning,
  1 => l.runWentOut,
  0 => l.runNoIgnition,
  _ => l.runUnknownOutcome,
};

/// One data cell.
Widget runCell(
  BuildContext context,
  AppLocalizations l,
  FsFormat f,
  RunRecord r,
  RunColumn c,
) {
  final fs = context.fs;
  final text = context.text.bodyMedium!.copyWith(color: fs.textPrimary);
  final num = context.nums.sm;
  String n(double? v) => v == null ? l.notAvailable : f.sig(v);
  final Widget child = switch (c) {
    RunColumn.run => Text(
      r.runId,
      style: text,
      overflow: TextOverflow.ellipsis,
    ),
    RunColumn.experiment => Text(
      r.experiment,
      style: text,
      overflow: TextOverflow.ellipsis,
    ),
    RunColumn.fuel => Text(
      r.fuelName,
      style: text,
      overflow: TextOverflow.ellipsis,
    ),
    RunColumn.o2 => Text(n(r.o2 * 100), style: num),
    RunColumn.pressure => Text(n(r.pressureKpa), style: num),
    RunColumn.flow => Text(n(r.flowMmS), style: num),
    RunColumn.gravity => Text(f.gravity(r.gravityG), style: num),
    RunColumn.spread => Text(n(r.spreadMmS), style: num),
    RunColumn.quality => Text(l.qualityLabel(r.qualityFlag), style: text),
    RunColumn.outcome => Row(
      children: [
        if (outcomeRank(r) >= 1)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: outcomeRank(r) == 2 ? fs.ember : fs.microg,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: FsSpace.s2),
        Flexible(
          child: Text(
            outcomeText(l, r),
            style: text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  };
  return Align(
    alignment: numericColumns.contains(c)
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: child,
  );
}
