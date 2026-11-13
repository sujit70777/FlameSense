import 'json_utils.dart';

/// `metrics.json` sustain block (PLAN.md §3.6).
class SustainMetrics {
  const SustainMetrics(this.j);

  final Map<String, dynamic> j;

  bool get available => asBool(j['available']) ?? false;
  String? get reason => asString(j['reason']);
  int get nRows => asInt(j['n_rows']) ?? 0;
  int get nGroups => asInt(j['n_groups']) ?? 0;
  String? get cv => asString(j['cv']);
  double? get rocAuc => asDouble(j['roc_auc']);
  double? get brier => asDouble(j['brier']);
  double? get accuracy => asDouble(j['accuracy_at_0_5']);
  double? get baselineBrier => asDouble(j['baseline_brier']);
  List<String> get warnings =>
      asList(j['warnings']).map((w) => w.toString()).toList();

  /// [pred_mean, obs_rate, count] per non-empty bin.
  List<List<double>> get calibrationBins =>
      asList(j['calibration_bins'])
          .map((b) => asDoubleList(b).map((v) => v ?? 0).toList())
          .toList();
}

/// `metrics.json` spread block.
class SpreadMetrics {
  const SpreadMetrics(this.j);

  final Map<String, dynamic> j;

  bool get available => asBool(j['available']) ?? false;
  String? get reason => asString(j['reason']);
  int get nRows => asInt(j['n_rows']) ?? 0;
  int get nGroups => asInt(j['n_groups']) ?? 0;
  String? get cv => asString(j['cv']);
  double? get mae => asDouble(j['mae_mm_s']);
  double? get medianApe => asDouble(j['median_ape']);
  double? get r2Log => asDouble(j['r2_log']);
  double? get coverage => asDouble(j['interval_80_coverage']);
  double? get baselineMae => asDouble(j['baseline_mae_mm_s']);
  double? get physicsMae => asDouble(j['physics_mae_mm_s']);
  List<String> get warnings =>
      asList(j['warnings']).map((w) => w.toString()).toList();
}

/// Both metric blocks.
class Metrics {
  const Metrics({required this.sustain, required this.spread});

  /// Parses metrics.json.
  factory Metrics.fromJson(Map<String, dynamic> j) => Metrics(
    sustain: SustainMetrics(asMap(j['sustain'])),
    spread: SpreadMetrics(asMap(j['spread'])),
  );

  final SustainMetrics sustain;
  final SpreadMetrics spread;
}
