import '../data/models/feature_spec.dart';
import 'slider_scale.dart';
import 'lab_input.dart';
import 'predictor.dart';

/// One "what moves the risk" row (DESIGN.md §9.17).
class SensitivityItem {
  const SensitivityItem({
    required this.input,
    required this.step,
    required this.delta,
  });

  /// Input name, e.g. `o2_mole_fraction`.
  final String input;

  /// How much the input was raised (model units).
  final double step;

  /// Change in the main output (probability 0–1, or spread mm/s).
  final double delta;

  bool get raises => delta > 0;
}

/// Slider scale used for an input (log for airflow, gravity and thickness).
FsSliderScale scaleFor(InputSpec s) => switch (s.name) {
  'flow_velocity_mm_s' => FsSliderScale.log1p,
  _ when s.log && s.min > 0 => FsSliderScale.log,
  _ => FsSliderScale.linear,
};

LabInput _with(LabInput x, String name, double v) => switch (name) {
  'o2_mole_fraction' => x.copyWith(o2: v),
  'pressure_kpa' => x.copyWith(pressureKpa: v),
  'flow_velocity_mm_s' => x.copyWith(flowMmS: v),
  'gravity_g' => x.copyWith(gravityG: v),
  'fuel_thickness_mm' => x.copyWith(thicknessMm: v),
  'fuel_density_kg_m3' => x.copyWith(densityKgM3: v),
  _ => x,
};

double _get(LabInput x, String name) => switch (name) {
  'o2_mole_fraction' => x.o2,
  'pressure_kpa' => x.pressureKpa,
  'flow_velocity_mm_s' => x.flowMmS,
  'gravity_g' => x.gravityG,
  'fuel_thickness_mm' => x.thicknessMm,
  'fuel_density_kg_m3' => x.densityKgM3,
  _ => 0,
};

/// Inputs that change at least one model feature.
const _inputFeatures = {
  'o2_mole_fraction': ['o2_mole_fraction', 'o2_partial_kpa'],
  'pressure_kpa': ['pressure_kpa', 'o2_partial_kpa'],
  'flow_velocity_mm_s': ['log10_flow'],
  'gravity_g': ['log10_gravity'],
  'fuel_thickness_mm': ['fuel_thickness_mm', 'areal_density_kg_m2'],
  'fuel_density_kg_m3': ['fuel_density_kg_m3', 'areal_density_kg_m2'],
};

/// Nudges each slider input by 10% of its slider range (in track position) and
/// returns the change in the main output, largest first (PLAN.md Phase 7 step 6).
/// Main output = sustain probability, or spread q50 when sustain is unavailable.
List<SensitivityItem> sensitivity(Predictor p, LabInput x, {int top = 4}) {
  double? f(LabInput v) =>
      p.sustainAvailable ? p.sustainProbability(v) : p.spread(v)?.$2;
  final base = f(x);
  if (base == null) return const [];
  final task = p.sustainAvailable ? p.spec.sustain : p.spec.spread;
  final used = task.featureNames.toSet();
  final items = <SensitivityItem>[];
  for (final e in _inputFeatures.entries) {
    final s = p.spec.inputs[e.key];
    if (s == null || !e.value.any(used.contains)) continue;
    final scale = scaleFor(s);
    final v = _get(x, e.key).clamp(s.min, s.max);
    final pos = scale.toPosition(v, s.min, s.max);
    final upPos = (pos + 0.1).clamp(0.0, 1.0);
    // At the top of the range, measure the last 10% instead.
    final (lo, hi) = upPos > pos
        ? (v, scale.fromPosition(upPos, s.min, s.max))
        : (scale.fromPosition(pos - 0.1, s.min, s.max), v);
    if (hi <= lo) continue;
    final dLo = f(_with(x, e.key, lo)), dHi = f(_with(x, e.key, hi));
    if (dLo == null || dHi == null) continue;
    items.add(SensitivityItem(input: e.key, step: hi - lo, delta: dHi - dLo));
  }
  items.sort((a, b) => b.delta.abs().compareTo(a.delta.abs()));
  return items.take(top).toList();
}
