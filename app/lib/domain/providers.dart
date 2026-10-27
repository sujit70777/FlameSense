import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import 'lab_input.dart';
import 'materials.dart';
import 'predictor.dart';
import 'sensitivity.dart';

/// The in-browser predictor built from the loaded assets.
final predictorProvider = Provider<Predictor>(
  (ref) => Predictor.fromData(ref.watch(loadedDataProvider)),
);

/// Material presets from the runs (unique fuel names).
final materialsProvider = Provider<List<Material>>(
  (ref) => materialsFrom(ref.watch(loadedDataProvider).runs.records),
);

/// Default Lab conditions from feature_spec.json (PLAN.md Phase 7 step 7).
final defaultLabInputProvider = Provider<LabInput>((ref) {
  final spec = ref.watch(loadedDataProvider).featureSpec;
  double d(String name, double fallback) =>
      spec.inputs[name]?.defaultValue ?? fallback;
  final groups = spec.sustain.available
      ? spec.sustain.groups
      : spec.spread.groups;
  final fuelClass = groups['fuel_class']?.defaultOption ?? 'thin_solid';
  final materials = ref
      .watch(materialsProvider)
      .where((m) => m.fuelClass == fuelClass)
      .toList();
  final m = materials.isEmpty
      ? null
      : materials.reduce((a, b) => a.nRuns >= b.nRuns ? a : b);
  return LabInput(
    fuelClass: m?.fuelClass ?? fuelClass,
    thicknessMm: m?.thicknessMm ?? d('fuel_thickness_mm', 0.1),
    densityKgM3: m?.densityKgM3 ?? d('fuel_density_kg_m3', 500),
    o2: d('o2_mole_fraction', 0.21),
    pressureKpa: d('pressure_kpa', 101.3),
    flowMmS: d('flow_velocity_mm_s', 100),
    flowDirection: groups['flow_direction']?.defaultOption ?? 'opposed',
    gravityG: d('gravity_g', 1e-6),
    material: m?.name,
  );
});

/// Current Fire Lab conditions; the Lab page syncs them with the URL query.
class LabInputNotifier extends Notifier<LabInput> {
  @override
  LabInput build() => ref.watch(defaultLabInputProvider);

  /// Replaces the conditions.
  void set(LabInput x) => state = x;

  /// Back to feature_spec defaults.
  void reset() => state = ref.read(defaultLabInputProvider);

  /// Applies URL query parameters (unknown or invalid ones are ignored).
  void applyQuery(Map<String, String> q) {
    if (q.isEmpty) return;
    final next = LabInput.fromQuery(q, state);
    if (next != state) state = next;
  }

  /// Selects a material preset (fills class, thickness and density) or Custom (null).
  void selectMaterial(Material? m) {
    state = m == null
        ? state.copyWith(material: () => null)
        : state.copyWith(
            material: () => m.name,
            fuelClass: m.fuelClass,
            thicknessMm: m.thicknessMm,
            densityKgM3: m.densityKgM3,
          );
  }
}

final labInputProvider = NotifierProvider<LabInputNotifier, LabInput>(
  LabInputNotifier.new,
);

/// Prediction for the current Lab conditions (synchronous).
final predictionProvider = Provider<PredictionResult>(
  (ref) => ref.watch(predictorProvider).predict(ref.watch(labInputProvider)),
);

/// "What moves the risk" rows for the current conditions.
final sensitivityProvider = Provider<List<SensitivityItem>>(
  (ref) =>
      sensitivity(ref.watch(predictorProvider), ref.watch(labInputProvider)),
);
