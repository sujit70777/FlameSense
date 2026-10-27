import '../../core/format.dart';
import '../../core/labels.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';

/// (label, value, unit) rows for every non-null field of a run (DESIGN.md §11.2).
List<(String, String, String)> runFields(
  AppLocalizations l,
  FsFormat f,
  RunRecord r,
) {
  String n(double? v) => v == null ? '' : f.sig(v);
  String b(bool? v) => v == null ? '' : (v ? l.valueYes : l.valueNo);
  final rows = <(String, String, String)>[
    (l.fieldExperiment, r.experiment, ''),
    (l.fieldGroup, r.groupId, ''),
    (l.fieldPlatform, l.platformLabel(r.platform), ''),
    (l.fieldGravity, f.gravity(r.gravityG), l.unitG),
    (l.fieldFuelName, r.fuelName, ''),
    (l.fieldFuelClass, l.fuelClassLabel(r.fuelClass), ''),
    (l.fieldThickness, n(r.thicknessMm), l.unitMm),
    (l.fieldDensity, n(r.densityKgM3), l.unitKgM3),
    (l.fieldO2, f.sig(r.o2 * 100), l.unitPercent),
    (l.fieldPressure, f.sig(r.pressureKpa), l.unitKpa),
    (l.fieldDiluent, r.diluent == null ? '' : l.diluentLabel(r.diluent), ''),
    (l.fieldFlow, n(r.flowMmS), l.unitMmS),
    (
      l.fieldFlowDir,
      r.flowDirection == null ? '' : l.flowDirLabel(r.flowDirection),
      '',
    ),
    (l.fieldIgnited, b(r.ignited), ''),
    (l.fieldSustained, b(r.sustained), ''),
    (l.fieldSpread, n(r.spreadMmS), l.unitMmS),
    (l.fieldBurningRate, n(r.burningRate), l.unitMm2S),
    (l.fieldExtinction, r.extinctionReason ?? '', ''),
    (l.fieldSourceFile, r.sourceFile, ''),
    (l.fieldNotes, r.notes ?? '', ''),
  ];
  return rows.where((e) => e.$2.isNotEmpty).toList();
}
