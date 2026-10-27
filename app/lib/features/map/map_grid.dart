import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../data/models/feature_spec.dart';
import '../../domain/lab_input.dart';
import '../../domain/predictor.dart';
import '../../domain/slider_scale.dart';
import '../../domain/support_index.dart';

const kMapCols = 64, kMapRows = 48;

/// Conditions that define one map (the memo key).
@immutable
class MapKey {
  const MapKey({
    required this.fuelClass,
    required this.thicknessMm,
    required this.densityKgM3,
    required this.pressureKpa,
    required this.gravityG,
    required this.flowDirection,
  });

  final String fuelClass, flowDirection;
  final double thicknessMm, densityKgM3, pressureKpa, gravityG;

  @override
  bool operator ==(Object other) =>
      other is MapKey &&
      other.fuelClass == fuelClass &&
      other.flowDirection == flowDirection &&
      other.thicknessMm == thicknessMm &&
      other.densityKgM3 == densityKgM3 &&
      other.pressureKpa == pressureKpa &&
      other.gravityG == gravityG;

  @override
  int get hashCode => Object.hash(
    fuelClass,
    flowDirection,
    thicknessMm,
    densityKgM3,
    pressureKpa,
    gravityG,
  );
}

/// Sustain probability over oxygen (rows, bottom = min) × airflow (cols, log) (PLAN.md Phase 11).
class MapGrid {
  MapGrid({
    required this.key,
    required this.flowMin,
    required this.flowMax,
    required this.o2Min,
    required this.o2Max,
    required this.prob,
    required this.lowSupport,
  });

  final MapKey key;
  final double flowMin, flowMax, o2Min, o2Max;

  /// Row-major (row 0 = lowest oxygen), length cols × rows.
  final Float64List prob;
  final List<bool> lowSupport;

  static const flowScale = FsSliderScale.log1p;

  /// Airflow (mm/s) at the centre of column [c].
  double flowAt(double c) =>
      flowScale.fromPosition((c + 0.5) / kMapCols, flowMin, flowMax);

  /// O₂ fraction at the centre of row [r].
  double o2At(double r) => o2Min + (r + 0.5) / kMapRows * (o2Max - o2Min);

  /// Fractional column of an airflow value (for overlays).
  double colOf(double flow) =>
      flowScale.toPosition(flow, flowMin, flowMax) * kMapCols;

  /// Fractional row of an O₂ value.
  double rowOf(double o2) => (o2 - o2Min) / (o2Max - o2Min) * kMapRows;

  double at(int c, int r) => prob[r * kMapCols + c];
  bool lowAt(int c, int r) => lowSupport[r * kMapCols + c];

  /// Lab input for cell (c, r).
  LabInput inputAt(int c, int r, {String? material}) => LabInput(
    fuelClass: key.fuelClass,
    thicknessMm: key.thicknessMm,
    densityKgM3: key.densityKgM3,
    o2: o2At(r.toDouble()),
    pressureKpa: key.pressureKpa,
    flowMmS: flowAt(c.toDouble()),
    flowDirection: key.flowDirection,
    gravityG: key.gravityG,
    material: material,
  );
}

final _memo = <MapKey, MapGrid>{};

/// Computes (or returns the memoized) grid; null when the sustain task is unavailable.
MapGrid? computeMapGrid(Predictor p, FeatureSpec spec, MapKey key) {
  if (!p.sustainAvailable) return null;
  final cached = _memo[key];
  if (cached != null) return cached;
  final flow = spec.input('flow_velocity_mm_s'),
      o2 = spec.input('o2_mole_fraction');
  final empty = MapGrid(
    key: key,
    flowMin: flow.min,
    flowMax: flow.max,
    o2Min: o2.min,
    o2Max: o2.max,
    prob: Float64List(kMapCols * kMapRows),
    lowSupport: List.filled(kMapCols * kMapRows, false),
  );
  for (var r = 0; r < kMapRows; r++) {
    for (var c = 0; c < kMapCols; c++) {
      final x = empty.inputAt(c, r);
      empty.prob[r * kMapCols + c] = p.sustainProbability(x)!;
      empty.lowSupport[r * kMapCols + c] =
          p.support(x).level == SupportLevel.low;
    }
  }
  if (_memo.length > 24) _memo.clear();
  return _memo[key] = empty;
}

/// Clears the memo (tests).
@visibleForTesting
void clearMapMemo() => _memo.clear();

/// Marching-squares segments of the [level] contour, in cell-centre coordinates
/// (x = column, y = row). Deterministic; ambiguous saddles split consistently.
List<(Offset, Offset)> contourSegments(
  Float64List v,
  int cols,
  int rows,
  double level,
) {
  final out = <(Offset, Offset)>[];
  double f(int c, int r) => v[r * cols + c];
  Offset lerp(
    double c0,
    double r0,
    double v0,
    double c1,
    double r1,
    double v1,
  ) {
    final t = (level - v0) / (v1 - v0);
    return Offset(c0 + (c1 - c0) * t, r0 + (r1 - r0) * t);
  }

  for (var r = 0; r < rows - 1; r++) {
    for (var c = 0; c < cols - 1; c++) {
      final a = f(c, r), b = f(c + 1, r), cc = f(c + 1, r + 1), d = f(c, r + 1);
      final idx =
          (a >= level ? 1 : 0) |
          (b >= level ? 2 : 0) |
          (cc >= level ? 4 : 0) |
          (d >= level ? 8 : 0);
      if (idx == 0 || idx == 15) continue;
      final x = c.toDouble(), y = r.toDouble();
      final bottom = lerp(x, y, a, x + 1, y, b),
          right = lerp(x + 1, y, b, x + 1, y + 1, cc);
      final top = lerp(x, y + 1, d, x + 1, y + 1, cc),
          left = lerp(x, y, a, x, y + 1, d);
      switch (idx) {
        case 1 || 14:
          out.add((left, bottom));
        case 2 || 13:
          out.add((bottom, right));
        case 3 || 12:
          out.add((left, right));
        case 4 || 11:
          out.add((right, top));
        case 6 || 9:
          out.add((bottom, top));
        case 7 || 8:
          out.add((left, top));
        case 5:
          out
            ..add((left, top))
            ..add((bottom, right));
        case 10:
          out
            ..add((left, bottom))
            ..add((right, top));
      }
    }
  }
  return out;
}
