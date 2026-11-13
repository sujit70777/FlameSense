import 'dart:math' as math;
import 'dart:typed_data';

import '../data/models/json_utils.dart';

/// One decision tree stored as flat arrays (leaf when `feature[i] < 0`).
class _Tree {
  _Tree(this.feature, this.threshold, this.left, this.right, this.value);

  final Int32List feature, left, right;
  final Float64List threshold, value;

  /// Leaf value reached by [x] (PLAN.md §3.4: left if x[f] <= t).
  double eval(List<double> x) {
    var i = 0;
    while (feature[i] >= 0) {
      i = x[feature[i]] <= threshold[i] ? left[i] : right[i];
    }
    return value[i];
  }
}

/// Tree model in the `flamesense-trees-v1` format (PLAN.md §3.4).
class TreeModel {
  TreeModel._(
    this.task,
    this.link,
    this.available,
    this.featureNames,
    this.a,
    this.b,
    this._trees,
  );

  /// Parses a model JSON exported by `export.py`.
  factory TreeModel.fromJson(Map<String, dynamic> j) {
    if (j['format'] != 'flamesense-trees-v1') {
      throw const FormatException('Unknown tree model format');
    }
    final trees = <_Tree>[];
    for (final t in asList(j['trees'])) {
      final nodes = asList(asMap(t)['nodes']).map(asMap).toList();
      final n = nodes.length;
      final f = Int32List(n), l = Int32List(n), r = Int32List(n);
      final th = Float64List(n), v = Float64List(n);
      for (var i = 0; i < n; i++) {
        final node = nodes[i];
        if (node.containsKey('f')) {
          f[i] = asInt(node['f'])!;
          th[i] = asDouble(node['t'])!;
          l[i] = asInt(node['l'])!;
          r[i] = asInt(node['r'])!;
        } else {
          f[i] = -1;
          v[i] = asDouble(node['v'])!;
        }
      }
      trees.add(_Tree(f, th, l, r, v));
    }
    final cal = asMap(j['calibration']);
    return TreeModel._(
      asString(j['task']) ?? '',
      asString(j['link']) ?? 'identity',
      asBool(j['available']) ?? trees.isNotEmpty,
      asList(j['feature_names']).map((e) => e.toString()).toList(),
      asDouble(cal['a']) ?? 1,
      asDouble(cal['b']) ?? 0,
      trees,
    );
  }

  final String task, link;
  final bool available;
  final List<String> featureNames;

  /// Logistic calibration p = sigmoid(a·raw + b) (logit link only).
  final double a, b;
  final List<_Tree> _trees;

  /// Sum of leaf values; throws [ArgumentError] on wrong length or NaN/inf.
  double raw(List<double> x) {
    if (x.length != featureNames.length) {
      throw ArgumentError(
        'Expected ${featureNames.length} features, got ${x.length}',
      );
    }
    for (var i = 0; i < x.length; i++) {
      if (!x[i].isFinite) {
        throw ArgumentError.value(x[i], featureNames[i], 'not finite');
      }
    }
    var sum = 0.0;
    for (final t in _trees) {
      sum += t.eval(x);
    }
    return sum;
  }

  /// Raw score through the link: logit → calibrated probability, expm1, identity.
  double predict(List<double> x) => applyLink(raw(x));

  /// The link function applied to a raw score.
  double applyLink(double raw) => switch (link) {
    'logit' => 1 / (1 + math.exp(-(a * raw + b))),
    'expm1' => math.exp(raw) - 1,
    _ => raw,
  };
}
