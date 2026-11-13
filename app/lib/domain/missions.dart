import 'package:flutter/foundation.dart';

import '../data/models/missions_file.dart';
import '../data/models/run_record.dart';
import 'gravity.dart';
import 'lab_input.dart';
import 'materials.dart';
import 'predictor.dart';
import 'slider_scale.dart';
import 'support_index.dart';

/// Material verdict for a mission (PLAN.md Phase 11B step 2).
/// [outsideRange]: the mission's conditions are outside the solid model's valid
/// range at every swept airflow, so there is no number (PLAN.md §1.0).
enum Verdict { likelyBurns, uncertain, unknown, outsideRange, likelyOut }

/// Verdict rule: unknown if support is low or the task is unavailable; else by worst-case probability.
Verdict verdictFor(double? worstProb, SupportLevel? support) {
  if (worstProb == null || support == null || support == SupportLevel.low) {
    return Verdict.unknown;
  }
  if (worstProb >= 0.6) return Verdict.likelyBurns;
  if (worstProb <= 0.4) return Verdict.likelyOut;
  return Verdict.uncertain;
}

/// One row of a mission's material table.
class MaterialAssessment {
  const MaterialAssessment({
    required this.material,
    required this.worstProb,
    required this.worstFlowMmS,
    required this.worstDirection,
    required this.support,
    required this.verdict,
    required this.input,
  });

  final Material material;
  final double? worstProb, worstFlowMmS;
  final String? worstDirection;
  final SupportLevel? support;
  final Verdict verdict;

  /// Lab conditions at the worst case (row → Lab).
  final LabInput input;
}

/// `n` log-spaced (log1p) airflow values from [min] to [max].
List<double> airflowSweep(double min, double max, int n) => [
  for (var i = 0; i < n; i++)
    FsSliderScale.log1p.fromPosition(i / (n - 1), min, max),
];

/// Missions to show: release builds hide unsourced ones (PLAN.md §3.10 rules).
List<Mission> visibleMissions(MissionsFile f, {bool release = kReleaseMode}) =>
    f.missions.where((m) => !release || m.isSourced).toList();

/// Planned experiments to show for a mission (sourced only in release).
List<PlannedExperiment> visiblePlanned(
  MissionsFile f,
  String missionId, {
  bool release = kReleaseMode,
}) => f.planned
    .where((p) => p.missionId == missionId && (!release || p.isSourced))
    .toList();

/// Runs in the mission's gravity class.
int runsInGravityClass(List<RunRecord> runs, double g) =>
    runs.where((r) => r.gravityClass == gravityClassOf(g)).length;

/// Worst case over the in-range part of the airflow sweep and every flow direction,
/// per material. Sweep points outside the valid range are skipped; when none is
/// inside (O₂, pressure or gravity untested), the verdict is [Verdict.outsideRange].
List<MaterialAssessment> assessMission(
  Predictor p,
  Mission m,
  List<Material> materials, {
  required List<double> sweep,
  required List<String> directions,
  required LabInput defaults,
}) {
  final out = <MaterialAssessment>[];
  for (final mat in materials) {
    final base = defaults.copyWith(
      fuelClass: mat.fuelClass,
      thicknessMm: mat.thicknessMm,
      densityKgM3: mat.densityKgM3,
      o2: m.o2,
      pressureKpa: m.pressureKpa,
      gravityG: m.gravityG,
      material: () => mat.name,
    );
    double? worst;
    LabInput at = base.copyWith(flowMmS: sweep.first);
    if (p.sustainAvailable) {
      for (final dir in directions) {
        for (final flow in sweep) {
          final x = base.copyWith(flowMmS: flow, flowDirection: dir);
          final prob = p.sustainProbability(x);
          if (prob == null) continue; // outside the valid range: no number
          if (worst == null || prob > worst) {
            worst = prob;
            at = x;
          }
        }
      }
    }
    final support = worst == null ? null : p.support(at).level;
    final outside = p.sustainAvailable && worst == null;
    out.add(
      MaterialAssessment(
        material: mat,
        worstProb: worst,
        worstFlowMmS: worst == null ? null : at.flowMmS,
        worstDirection: worst == null ? null : at.flowDirection,
        support: support,
        verdict: outside ? Verdict.outsideRange : verdictFor(worst, support),
        input: at,
      ),
    );
  }
  out.sort((a, b) {
    final v = a.verdict.index.compareTo(b.verdict.index);
    return v != 0 ? v : (b.worstProb ?? -1).compareTo(a.worstProb ?? -1);
  });
  return out;
}

/// Counts of (likely to burn, likely to go out, unknown, outside the tested range).
(int, int, int, int) verdictCounts(List<MaterialAssessment> rows) => (
  rows.where((r) => r.verdict == Verdict.likelyBurns).length,
  rows.where((r) => r.verdict == Verdict.likelyOut).length,
  rows.where((r) => r.verdict == Verdict.unknown).length,
  rows.where((r) => r.verdict == Verdict.outsideRange).length,
);

/// Lowest O₂ in the challenge statement's Moon-base atmosphere ("30% or greater").
const kStatementMinO2 = 0.30;

/// Highest pressure in the statement ("10.2 psi or less"), in kPa.
const kStatementMaxPressureKpa = 70.3;

/// Kilopascals per psi.
const kKpaPerPsi = 6.894757;

/// NTRS record of NASA's 8.2 psia / 34% O₂ recommendation (PLAN.md §1.0).
const kNtrsRecommendation = '20240003211';

/// Whether the mission uses the Moon-base-type atmosphere the statement describes.
bool usesStatementAtmosphere(Mission m) =>
    m.o2 >= kStatementMinO2 && m.pressureKpa <= kStatementMaxPressureKpa;
