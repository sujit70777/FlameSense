import 'dart:math' as math;

import '../data/asset_repository.dart';
import '../data/models/feature_spec.dart';
import 'gravity.dart';
import 'lab_input.dart';
import 'physics_model.dart';
import 'support_index.dart';
import 'tree_model.dart';

/// Kinds of notices attached to a prediction (DESIGN.md §11.3 warnings).
enum WarningKind {
  outsideRange,
  lowSupport,
  partialGravity,
  sustainUnavailable,
  spreadUnavailable,
  quantilesReordered,
}

/// A warning; [outside] is set for [WarningKind.outsideRange].
class PredictionWarning {
  const PredictionWarning(this.kind, [this.outside]);
  final WarningKind kind;
  final OutsideRange? outside;
}

/// Everything the Lab shows for one set of conditions.
class PredictionResult {
  const PredictionResult({
    required this.sustainProb,
    required this.spreadQ10,
    required this.spreadQ50,
    required this.spreadQ90,
    required this.support,
    required this.physics,
    required this.effectiveFlowMmS,
    required this.warnings,
  });

  final double? sustainProb, spreadQ10, spreadQ50, spreadQ90;
  final SupportResult support;
  final PhysicsResult physics;

  /// sqrt(forced² + buoyant²) when buoyancy is known, else the forced airflow.
  final double effectiveFlowMmS;
  final List<PredictionWarning> warnings;

  bool has(WarningKind k) => warnings.any((w) => w.kind == k);
}

/// Model inputs computed from [x] with the PLAN.md §3.1 formulas, by feature name.
double featureValue(String name, LabInput x, Map<String, GroupSpec> groups) {
  switch (name) {
    case 'o2_mole_fraction':
      return x.o2;
    case 'pressure_kpa':
      return x.pressureKpa;
    case 'fuel_thickness_mm':
      return x.thicknessMm;
    case 'fuel_density_kg_m3':
      return x.densityKgM3;
    case 'o2_partial_kpa':
      return x.o2 * x.pressureKpa;
    case 'log10_flow':
      return math.log(x.flowMmS + 1) / math.ln10;
    case 'log10_gravity':
      return math.log(math.max(x.gravityG, 1e-7)) / math.ln10;
    case 'areal_density_kg_m2':
      return x.thicknessMm / 1000 * x.densityKgM3;
  }
  final sep = name.indexOf('__');
  if (sep < 0) throw ArgumentError.value(name, 'feature', 'unknown feature');
  final group = name.substring(0, sep), option = name.substring(sep + 2);
  final value = switch (group) {
    'fuel_class' => x.fuelClass,
    'flow_direction' => x.flowDirection,
    _ => groups[group]?.defaultOption,
  };
  return value == option ? 1.0 : 0.0;
}

/// Runs every exported model in the browser (PLAN.md Phase 7).
class Predictor {
  Predictor({
    required this.spec,
    required this.sustain,
    required this.q10,
    required this.q50,
    required this.q90,
    required this.supportSustain,
    required this.supportSpread,
    required this.physics,
  });

  /// Builds the predictor from loaded assets.
  factory Predictor.fromData(AppData d, {bool? requireSignOff}) => Predictor(
    spec: d.featureSpec,
    sustain: TreeModel.fromJson(d.modelJson['model_sustain.json']!),
    q10: TreeModel.fromJson(d.modelJson['model_spread_q10.json']!),
    q50: TreeModel.fromJson(d.modelJson['model_spread_q50.json']!),
    q90: TreeModel.fromJson(d.modelJson['model_spread_q90.json']!),
    supportSustain: SupportIndex(d.supportSustain),
    supportSpread: SupportIndex(d.supportSpread),
    physics: PhysicsModel(d.physics, requireSignOff: requireSignOff),
  );

  final FeatureSpec spec;
  final TreeModel sustain, q10, q50, q90;
  final SupportIndex supportSustain, supportSpread;
  final PhysicsModel physics;

  bool get sustainAvailable => spec.sustain.available && sustain.available;
  bool get spreadAvailable => spec.spread.available && q50.available;

  /// Feature vector in model order for [task].
  List<double> vector(TaskSpec task, LabInput x) => [
    for (final f in task.features) featureValue(f.name, x, task.groups),
  ];

  /// Chance the flame keeps burning, or null when the task is unavailable.
  double? sustainProbability(LabInput x) =>
      sustainAvailable ? sustain.predict(vector(spec.sustain, x)) : null;

  /// (q10, q50, q90, reordered) spread in mm/s, or null when unavailable.
  (double, double, double, bool)? spread(LabInput x) {
    if (!spreadAvailable) return null;
    final v = vector(spec.spread, x);
    final q = [q10.predict(v), q50.predict(v), q90.predict(v)];
    final sorted = [...q]..sort();
    final reordered = sorted[0] != q[0] || sorted[1] != q[1];
    return (
      math.max(0.0, sorted[0]),
      math.max(0.0, sorted[1]),
      math.max(0.0, sorted[2]),
      reordered,
    );
  }

  /// Support level and outside-range inputs (sustain index first, else spread).
  SupportResult support(LabInput x) {
    final outside = <OutsideRange>[];
    for (final (name, value) in [
      ('o2_mole_fraction', x.o2),
      ('pressure_kpa', x.pressureKpa),
      ('flow_velocity_mm_s', x.flowMmS),
      ('gravity_g', x.gravityG),
      ('fuel_thickness_mm', x.thicknessMm),
    ]) {
      final s = spec.inputs[name];
      if (s != null && s.isOutside(value)) {
        outside.add(OutsideRange(name, s.trainMin!, s.trainMax!));
      }
    }
    final (index, task) = supportSustain.available
        ? (supportSustain, spec.sustain)
        : (supportSpread, spec.spread);
    if (!index.available) {
      return SupportResult(
        level: SupportLevel.low,
        distance: null,
        outside: outside,
      );
    }
    final values = [
      for (final n in index.data.featureNames) featureValue(n, x, task.groups),
    ];
    final d = index.distance(values);
    return SupportResult(
      level: index.levelFor(d),
      distance: d,
      outside: outside,
    );
  }

  /// Full prediction for the Lab.
  PredictionResult predict(LabInput x) {
    final warnings = <PredictionWarning>[];
    final p = sustainProbability(x);
    final s = spread(x);
    final sup = support(x);
    final phys = physics.evaluate(
      fuelName: x.material,
      fuelClass: x.fuelClass,
      flowDirection: x.flowDirection,
      o2: x.o2,
      gravityG: x.gravityG,
      flowMmS: x.flowMmS,
    );
    for (final o in sup.outside) {
      warnings.add(PredictionWarning(WarningKind.outsideRange, o));
    }
    if (sup.level == SupportLevel.low && (p != null || s != null)) {
      warnings.add(const PredictionWarning(WarningKind.lowSupport));
    }
    if (gravityClassOf(x.gravityG) == GravityClass.partial) {
      warnings.add(const PredictionWarning(WarningKind.partialGravity));
    }
    if (p == null) {
      warnings.add(const PredictionWarning(WarningKind.sustainUnavailable));
    }
    if (s == null) {
      warnings.add(const PredictionWarning(WarningKind.spreadUnavailable));
    }
    if (s != null && s.$4) {
      warnings.add(const PredictionWarning(WarningKind.quantilesReordered));
    }
    final ub = phys.buoyantVelocityMmS;
    return PredictionResult(
      sustainProb: p,
      spreadQ10: s?.$1,
      spreadQ50: s?.$2,
      spreadQ90: s?.$3,
      support: sup,
      physics: phys,
      effectiveFlowMmS: ub == null
          ? x.flowMmS
          : math.sqrt(x.flowMmS * x.flowMmS + ub * ub),
      warnings: warnings,
    );
  }
}
