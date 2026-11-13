import 'dart:math' as math;

import '../data/models/investigation.dart';

/// A habitat's atmosphere ranges (O2 %, kPa) used for ranking.
class HabitatSpec {
  const HabitatSpec({required this.o2Pct, required this.pressureKpa});
  final Range o2Pct, pressureKpa;
}

/// Ranking weights (PLAN Phase 3D step 3); defaults 0.30, 0.25, 0.15, 0.15, 0.15.
class RankWeights {
  const RankWeights({
    this.atmosphere = 0.30,
    this.fuel = 0.25,
    this.airflow = 0.15,
    this.pillar = 0.15,
    this.data = 0.15,
  });
  final double atmosphere, fuel, airflow, pillar, data;
}

/// The five terms (each in [0, 1]) and the weighted score ("why this rank").
class RankBreakdown {
  const RankBreakdown(this.terms, this.weights);
  final Map<String, double> terms;
  final RankWeights weights;

  /// Weighted contribution of each term; these sum to [score].
  Map<String, double> get contributions => {
    'atmosphere': weights.atmosphere * terms['atmosphere']!,
    'fuel': weights.fuel * terms['fuel']!,
    'airflow': weights.airflow * terms['airflow']!,
    'pillar': weights.pillar * terms['pillar']!,
    'data': weights.data * terms['data']!,
  };

  double get score => contributions.values.fold(0, (a, b) => a + b);
}

/// Fraction of [need] covered by [tested]; a point range counts 1 if inside, else 0.
double coverage(Range need, Range? tested) {
  if (tested == null) return 0;
  final width = need.hi - need.lo;
  if (width <= 0) return (need.lo >= tested.lo && need.lo <= tested.hi) ? 1 : 0;
  final overlap = math.min(need.hi, tested.hi) - math.max(need.lo, tested.lo);
  return (overlap / width).clamp(0, 1).toDouble();
}

/// AtmosphereOverlap: mean coverage of the habitat O2 and pressure ranges.
double atmosphereOverlap(InvestigationRecord r, HabitatSpec h) =>
    (coverage(h.o2Pct, r.o2Pct) + coverage(h.pressureKpa, r.pressureKpa)) / 2;

/// FuelRelevance: solids 1.0, BRE (solid emulator) 0.8, smoke/dust 0.7 for detection, gas 0.6,
/// droplets 0.5; the best matching state counts.
double fuelRelevance(InvestigationRecord r, {required String? pillar}) {
  final s = r.fuelStates;
  final scores = <double>[
    if (s.contains('solid')) 1.0,
    if (r.acronym.toUpperCase().contains('BRE')) 0.8,
    if (pillar == 'detection' &&
        (s.contains('smoke') || s.contains('aerosol_dust')))
      0.7,
    if (s.contains('gas')) 0.6,
    if (s.contains('liquid_droplet')) 0.5,
  ];
  return scores.isEmpty ? 0 : scores.reduce(math.max);
}

/// AirflowRelevance: 1.0 if airflow 0–200 mm/s was tested, 0.5 if only quiescent, 0.3 if not reported.
double airflowRelevance(InvestigationRecord r) {
  final a = r.airflowMmS;
  if (a == null) return 0.3;
  if (a.hi <= 0) return 0.5;
  return a.lo <= 200 ? 1.0 : 0.3;
}

/// DataRichness: min(1, log10(rows + 1) / 3) × (has outcome ? 1 : 0.6).
double dataRichness(InvestigationRecord r) =>
    math.min(1.0, math.log(r.rows + 1) / math.ln10 / 3) *
    (r.hasOutcome ? 1 : 0.6);

/// Transparent score of one investigation for a habitat and (optional) pillar.
RankBreakdown rankInvestigation(
  InvestigationRecord r,
  HabitatSpec h, {
  String? pillar,
  RankWeights weights = const RankWeights(),
}) => RankBreakdown({
  'atmosphere': atmosphereOverlap(r, h),
  'fuel': fuelRelevance(r, pillar: pillar),
  'airflow': airflowRelevance(r),
  'pillar': pillar != null && r.pillars.contains(pillar) ? 1.0 : 0.0,
  'data': dataRichness(r),
}, weights);

/// Investigations sorted by score (highest first), each with its breakdown.
List<(InvestigationRecord, RankBreakdown)> rankAll(
  List<InvestigationRecord> all,
  HabitatSpec h, {
  String? pillar,
  RankWeights weights = const RankWeights(),
}) => [
  for (final r in all)
    (r, rankInvestigation(r, h, pillar: pillar, weights: weights)),
]..sort((a, b) => b.$2.score.compareTo(a.$2.score));
