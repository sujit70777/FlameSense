import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/browser.dart';
import '../../core/providers.dart';
import '../../domain/gravity.dart';
import '../../domain/lab_input.dart';
import '../../domain/predictor.dart';
import '../../domain/providers.dart';

/// "Compare with Earth" toggle (DESIGN.md §11.3).
class CompareNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// Flips compare mode.
  void toggle() => state = !state;
}

final compareModeProvider = NotifierProvider<CompareNotifier, bool>(
  CompareNotifier.new,
);

/// The same conditions at 1 g for compare mode.
final earthPredictionProvider = Provider<PredictionResult>(
  (ref) => ref
      .watch(predictorProvider)
      .predict(ref.watch(labInputProvider).copyWith(gravityG: kEarthG)),
);

/// Log axis for the spread band: min/max measured spread rate in the data (fallback 0.1–10 mm/s).
final spreadAxisProvider = Provider<(double, double)>((ref) {
  final rates = ref
      .watch(loadedDataProvider)
      .runs
      .records
      .map((r) => r.spreadMmS)
      .nonNulls
      .where((v) => v > 0);
  if (rates.isEmpty) return (0.1, 10.0);
  final lo = rates.reduce(math.min), hi = rates.reduce(math.max);
  return hi > lo ? (lo, hi) : (lo / 2, hi * 2);
});

/// `/lab?...` for [x].
String labPath(LabInput x) =>
    Uri(path: '/lab', queryParameters: x.toQuery()).toString();

/// Absolute shareable link for [x] (relative outside the browser).
String labShareLink(LabInput x) => '${currentOrigin()}${labPath(x)}';
