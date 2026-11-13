import 'json_utils.dart';

/// One task of `support_index.json` (PLAN.md §3.5).
class SupportIndexData {
  const SupportIndexData({
    required this.available,
    required this.featureNames,
    required this.mean,
    required this.std,
    required this.points,
    required this.k,
    required this.p50,
    required this.p95,
  });

  /// Parses one task's support index.
  factory SupportIndexData.fromJson(Map<String, dynamic> j) => SupportIndexData(
    available: asBool(j['available']) ?? asList(j['points']).isNotEmpty,
    featureNames: asList(j['feature_names']).map((e) => e.toString()).toList(),
    mean: asDoubleList(j['mean']).map((v) => v ?? 0).toList(),
    std: asDoubleList(j['std']).map((v) => v ?? 1).toList(),
    points: asList(j['points'])
        .map((p) => asDoubleList(p).map((v) => v ?? 0).toList())
        .toList(),
    k: asInt(j['k']) ?? 5,
    p50: asDouble(j['p50']),
    p95: asDouble(j['p95']),
  );

  final bool available;
  final List<String> featureNames;
  final List<double> mean, std;
  final List<List<double>> points;
  final int k;
  final double? p50, p95;
}
