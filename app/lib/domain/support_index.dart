import 'dart:math' as math;

import '../data/models/support_index_data.dart';

/// How well NASA data supports a prediction (PLAN.md §3.5, DESIGN.md §9.9).
enum SupportLevel { high, medium, low }

/// A user input outside the range NASA tested.
class OutsideRange {
  const OutsideRange(this.input, this.trainMin, this.trainMax);

  /// Input name, e.g. `o2_mole_fraction`.
  final String input;
  final double trainMin, trainMax;
}

/// Support for one query point.
class SupportResult {
  const SupportResult({
    required this.level,
    required this.distance,
    required this.outside,
  });

  final SupportLevel level;

  /// Mean distance to the k nearest standardized training rows (null if no index).
  final double? distance;
  final List<OutsideRange> outside;
}

/// kNN data-support index on standardized slider features (PLAN.md §3.5).
class SupportIndex {
  SupportIndex(this.data);

  final SupportIndexData data;

  bool get available =>
      data.available && data.points.isNotEmpty && data.p50 != null;

  /// Mean Euclidean distance from raw vector [x] (in `featureNames` order) to the k nearest points.
  double distance(List<double> x) {
    final z = [
      for (var i = 0; i < x.length; i++) (x[i] - data.mean[i]) / data.std[i],
    ];
    final k = math.min(data.k, data.points.length);
    final best = List<double>.filled(k, double.infinity);
    for (final p in data.points) {
      var s = 0.0;
      for (var i = 0; i < z.length; i++) {
        final d = p[i] - z[i];
        s += d * d;
      }
      if (s < best.last) {
        var j = k - 1;
        while (j > 0 && best[j - 1] > s) {
          best[j] = best[j - 1];
          j--;
        }
        best[j] = s;
      }
    }
    return best.map(math.sqrt).reduce((a, b) => a + b) / k;
  }

  /// Level for [distance]: high ≤ p50, medium ≤ p95, else low.
  SupportLevel levelFor(double distance) {
    if (distance <= data.p50!) return SupportLevel.high;
    if (distance <= data.p95!) return SupportLevel.medium;
    return SupportLevel.low;
  }
}
