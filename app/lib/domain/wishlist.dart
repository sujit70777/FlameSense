import 'dart:math' as math;

import '../data/models/feature_spec.dart';
import '../data/models/missions_file.dart';
import 'lab_input.dart';
import 'materials.dart';
import 'predictor.dart';
import 'slider_scale.dart';

/// One candidate test condition with its score terms (PLAN.md Phase 11B step 3).
class WishCandidate {
  const WishCandidate({
    required this.input,
    required this.p,
    required this.u,
    required this.n,
    required this.w,
    required this.score,
    required this.z,
  });

  final LabInput input;

  /// Sustain probability; u = 1 − |2p − 1|; n = min(d/p95, 2)/2; w = normalised spread width.
  final double p, u, n, w, score;

  /// Standardized support-feature vector (for diversity).
  final List<double> z;

  bool get unsure => u >= 0.6;
  bool get far => n >= 0.5;
  bool get wide => w >= 0.5;
}

/// A planned NASA test point with its exactly computed score and rank.
class PlannedScore {
  const PlannedScore({
    required this.experiment,
    required this.score,
    required this.topPercent,
  });

  final PlannedExperiment experiment;

  /// Mean score over the experiment's points.
  final double score;

  /// Share of candidates scoring at least as high, in percent (not rounded up).
  final double topPercent;
}

/// Wishlist result: the 5 picks plus every candidate (for percentiles and the CSV).
class Wishlist {
  const Wishlist({
    required this.picks,
    required this.candidates,
    required this.planned,
  });

  final List<WishCandidate> picks, candidates;
  final List<PlannedScore> planned;
}

List<double> _linspace(double a, double b, int n) => [
  for (var i = 0; i < n; i++) a + (b - a) * i / (n - 1),
];

/// Candidate inputs: 13 O₂ × 5 pressures × 12 airflows × each fuel class, gravity fixed.
List<LabInput> wishlistInputs(
  FeatureSpec spec,
  Mission m,
  List<String> fuelClasses,
  List<Material> mats,
  LabInput defaults,
) {
  final o2 = spec.input('o2_mole_fraction'),
      flow = spec.input('flow_velocity_mm_s');
  final o2s = _linspace(
    (m.o2 - 0.06).clamp(o2.min, o2.max),
    (m.o2 + 0.06).clamp(o2.min, o2.max),
    13,
  );
  final ps = _linspace(0.85 * m.pressureKpa, 1.15 * m.pressureKpa, 5);
  final flows = [
    for (var i = 0; i < 12; i++)
      FsSliderScale.log1p.fromPosition(i / 11, flow.min, flow.max),
  ];
  final out = <LabInput>[];
  for (final fc in fuelClasses) {
    final ofClass = mats.where((x) => x.fuelClass == fc).toList();
    final mat = ofClass.isEmpty
        ? null
        : ofClass.reduce((a, b) => a.nRuns >= b.nRuns ? a : b);
    final base = defaults.copyWith(
      fuelClass: fc,
      thicknessMm: mat?.thicknessMm,
      densityKgM3: mat?.densityKgM3,
      gravityG: m.gravityG,
      material: () => mat?.name,
    );
    for (final o in o2s) {
      for (final p in ps) {
        for (final f in flows) {
          out.add(base.copyWith(o2: o, pressureKpa: p, flowMmS: f));
        }
      }
    }
  }
  return out;
}

/// Scores inputs: score = 0.45·u + 0.45·n + 0.10·w (w normalised by the widest interval).
List<WishCandidate> scoreCandidates(
  Predictor pr,
  List<LabInput> inputs, {
  double? maxWidth,
}) {
  final idx = pr.supportSustain;
  final task = pr.spec.sustain;
  final widths = [
    for (final x in inputs)
      if (pr.spread(x) case final s?) s.$3 - s.$1 else 0.0,
  ];
  final wMax = maxWidth ?? widths.fold<double>(0, (a, b) => math.max(a, b));
  return [
    for (var i = 0; i < inputs.length; i++)
      () {
        final x = inputs[i];
        final p = pr.sustainProbability(x)!;
        final raw = [
          for (final n in idx.data.featureNames)
            featureValue(n, x, task.groups),
        ];
        final z = [
          for (var j = 0; j < raw.length; j++)
            (raw[j] - idx.data.mean[j]) / idx.data.std[j],
        ];
        final d = idx.available ? idx.distance(raw) : 0.0;
        final u = 1 - (2 * p - 1).abs();
        final n = idx.available ? math.min(d / idx.data.p95!, 2) / 2 : 1.0;
        final w = wMax > 0 ? widths[i] / wMax : 0.0;
        return WishCandidate(
          input: x,
          p: p,
          u: u,
          n: n,
          w: w,
          score: 0.45 * u + 0.45 * n + 0.10 * w,
          z: z,
        );
      }(),
  ];
}

double _dist(List<double> a, List<double> b) {
  var s = 0.0;
  for (var i = 0; i < a.length; i++) {
    s += (a[i] - b[i]) * (a[i] - b[i]);
  }
  return math.sqrt(s);
}

/// Greedy diverse selection: best score first, skipping candidates within 0.75 of a pick.
List<WishCandidate> pickDiverse(
  List<WishCandidate> all, {
  int k = 5,
  double minDist = 0.75,
}) {
  final sorted = [...all]..sort((a, b) => b.score.compareTo(a.score));
  final picks = <WishCandidate>[];
  for (final c in sorted) {
    if (picks.length == k) break;
    if (picks.every((p) => _dist(p.z, c.z) >= minDist)) picks.add(c);
  }
  return picks;
}

/// Percent of candidates scoring ≥ [score] (exact; the UI truncates, never rounds up).
double topPercent(double score, List<WishCandidate> all) => all.isEmpty
    ? 0
    : all.where((c) => c.score >= score).length / all.length * 100;

/// Full wishlist for a mission, or null when the sustain model is unavailable.
Wishlist? buildWishlist(
  Predictor pr,
  Mission m,
  List<Material> mats,
  LabInput defaults,
  List<PlannedExperiment> planned,
) {
  if (!pr.sustainAvailable) return null;
  final classes =
      pr.spec.sustain.groups['fuel_class']?.options ?? [defaults.fuelClass];
  final inputs = wishlistInputs(pr.spec, m, classes, mats, defaults);
  final wRaw = maxSpreadWidth(pr, inputs);
  final cands = scoreCandidates(pr, inputs, maxWidth: wRaw);
  final flowMin = pr.spec.input('flow_velocity_mm_s').min;
  final plannedScores = <PlannedScore>[];
  for (final e in planned.where((e) => e.points.isNotEmpty)) {
    // Planned points burn with buoyant flow only: no forced airflow (slider minimum).
    final pts = [
      for (final pt in e.points)
        defaults.copyWith(
          o2: pt.o2,
          pressureKpa: pt.pressureKpa,
          gravityG: e.gravityG,
          flowMmS: flowMin,
        ),
    ];
    final s = scoreCandidates(pr, pts, maxWidth: wRaw);
    final mean = s.map((c) => c.score).reduce((a, b) => a + b) / s.length;
    plannedScores.add(
      PlannedScore(
        experiment: e,
        score: mean,
        topPercent: topPercent(mean, cands),
      ),
    );
  }
  return Wishlist(
    picks: pickDiverse(cands),
    candidates: cands,
    planned: plannedScores,
  );
}

/// Widest 80% spread interval (q90 − q10) over [inputs]; 0 when spread is unavailable.
double maxSpreadWidth(Predictor pr, List<LabInput> inputs) => inputs
    .map(pr.spread)
    .nonNulls
    .map((s) => s.$3 - s.$1)
    .fold<double>(0, (a, b) => math.max(a, b));
