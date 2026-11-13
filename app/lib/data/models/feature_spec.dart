import 'json_utils.dart';

/// Slider metadata for one user input (feature_spec.json `inputs`, Q-3).
class InputSpec {
  const InputSpec({
    required this.name,
    required this.labelKey,
    required this.displayScale,
    required this.displayUnit,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.step,
    required this.trainMin,
    required this.trainMax,
    required this.log,
  });

  /// Parses one entry of `inputs`.
  factory InputSpec.fromJson(String name, Map<String, dynamic> j) => InputSpec(
    name: name,
    labelKey: asString(j['label_key']) ?? name,
    displayScale: asDouble(j['display_scale']) ?? 1,
    displayUnit: asString(j['display_unit']) ?? '',
    min: asDouble(j['min']) ?? 0,
    max: asDouble(j['max']) ?? 1,
    defaultValue: asDouble(j['default']) ?? 0,
    step: asDouble(j['step']),
    trainMin: asDouble(j['train_min']),
    trainMax: asDouble(j['train_max']),
    log: asBool(j['log']) ?? false,
  );

  final String name, labelKey, displayUnit;
  final double displayScale, min, max, defaultValue;
  final double? step, trainMin, trainMax;
  final bool log;

  /// True when [value] is outside the training range (when one exists).
  bool isOutside(double value) =>
      trainMin != null &&
      trainMax != null &&
      (value < trainMin! || value > trainMax!);
}

/// One model feature (PLAN.md §3.3).
class FeatureEntry {
  const FeatureEntry({
    required this.name,
    required this.input,
    this.group,
    this.formula,
    this.trainMin,
    this.trainMax,
    this.mean,
    this.std,
    this.monotone = 0,
  });

  /// Parses one entry of a task's `features` list.
  factory FeatureEntry.fromJson(Map<String, dynamic> j) => FeatureEntry(
    name: asString(j['name']) ?? '',
    input: asString(j['input']) ?? 'slider',
    group: asString(j['group']),
    formula: asString(j['formula']),
    trainMin: asDouble(j['train_min']),
    trainMax: asDouble(j['train_max']),
    mean: asDouble(j['mean']),
    std: asDouble(j['std']),
    monotone: asInt(j['monotone']) ?? 0,
  );

  final String name, input;
  final String? group, formula;
  final double? trainMin, trainMax, mean, std;
  final int monotone;

  bool get isOneHot => input == 'onehot';
}

/// A one-hot group such as fuel_class.
class GroupSpec {
  const GroupSpec({
    required this.labelKey,
    required this.options,
    required this.defaultOption,
  });

  /// Parses one entry of `groups`.
  factory GroupSpec.fromJson(Map<String, dynamic> j) {
    final options = asList(j['options']).map((o) => o.toString()).toList();
    return GroupSpec(
      labelKey: asString(j['label_key']) ?? '',
      options: options,
      defaultOption:
          asString(j['default']) ?? (options.isEmpty ? '' : options.first),
    );
  }

  final String labelKey, defaultOption;
  final List<String> options;
}

/// Spec for one prediction task.
class TaskSpec {
  const TaskSpec({
    required this.available,
    required this.reason,
    required this.link,
    required this.nRows,
    required this.features,
    required this.groups,
  });

  /// Parses one task.
  factory TaskSpec.fromJson(Map<String, dynamic> j) => TaskSpec(
    available: asBool(j['available']) ?? false,
    reason: asString(j['reason_if_unavailable']),
    link: asString(j['link']) ?? 'identity',
    nRows: asInt(j['n_rows']) ?? 0,
    features: asList(j['features'])
        .map((f) => FeatureEntry.fromJson(asMap(f)))
        .toList(),
    groups: asMap(j['groups'])
        .map((k, v) => MapEntry(k, GroupSpec.fromJson(asMap(v)))),
  );

  final bool available;
  final String? reason;
  final String link;
  final int nRows;
  final List<FeatureEntry> features;
  final Map<String, GroupSpec> groups;

  /// Feature names in model order.
  List<String> get featureNames => features.map((f) => f.name).toList();
}

/// Where the solid model may give a number (PLAN.md §1.0): per input, the range in
/// which NASA saw flames both keep burning and go out (`feature_spec.json` `valid_range`).
class ValidRange {
  const ValidRange({
    required this.o2,
    required this.pressureKpa,
    required this.flowMmS,
    required this.gravityG,
  });

  /// Parses `valid_range`; null when it is missing or incomplete.
  static ValidRange? fromJson(Object? json) {
    final j = asMap(json);
    (double, double)? pair(String k) {
      final v = asList(j[k]);
      if (v.length != 2) return null;
      final lo = asDouble(v[0]), hi = asDouble(v[1]);
      return lo == null || hi == null ? null : (lo, hi);
    }

    final o2 = pair('o2'), p = pair('pressure_kpa'), f = pair('flow_mm_s');
    final g = pair('gravity_g');
    if (o2 == null || p == null || f == null || g == null) return null;
    return ValidRange(o2: o2, pressureKpa: p, flowMmS: f, gravityG: g);
  }

  final (double, double) o2, pressureKpa, flowMmS, gravityG;

  static bool _in(double v, (double, double) r) =>
      v >= r.$1 * (1 - 1e-6) && v <= r.$2 * (1 + 1e-6);

  /// True when every input is inside its range (1e-6 relative tolerance, as export.py).
  bool contains({
    required double o2,
    required double pressureKpa,
    required double flowMmS,
    required double gravityG,
  }) =>
      _in(o2, this.o2) &&
      _in(pressureKpa, this.pressureKpa) &&
      _in(flowMmS, this.flowMmS) &&
      _in(gravityG, this.gravityG);
}

/// `feature_spec.json`.
class FeatureSpec {
  const FeatureSpec({
    required this.inputs,
    required this.sustain,
    required this.spread,
    this.validRange,
  });

  /// Parses feature_spec.json.
  factory FeatureSpec.fromJson(Map<String, dynamic> j) {
    final tasks = asMap(j['tasks']);
    return FeatureSpec(
      inputs: asMap(j['inputs'])
          .map((k, v) => MapEntry(k, InputSpec.fromJson(k, asMap(v)))),
      sustain: TaskSpec.fromJson(asMap(tasks['sustain'])),
      spread: TaskSpec.fromJson(asMap(tasks['spread'])),
      validRange: ValidRange.fromJson(j['valid_range']),
    );
  }

  final Map<String, InputSpec> inputs;
  final TaskSpec sustain, spread;

  /// Solid-model valid range; null means no prediction anywhere (safest default).
  final ValidRange? validRange;

  /// Input spec by name; throws when the asset is incomplete.
  InputSpec input(String name) =>
      inputs[name] ??
      (throw StateError('feature_spec.json has no input "$name"'));
}
