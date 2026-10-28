import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/missions_file.dart';
import '../../domain/missions.dart';
import '../../domain/providers.dart';
import '../../domain/wishlist.dart';

/// Missions shown in this build (unsourced ones hidden in release).
final visibleMissionsProvider = Provider<List<Mission>>(
  (ref) => visibleMissions(ref.watch(loadedDataProvider).missions),
);

/// A visible mission by id, or null.
final missionByIdProvider = Provider.family<Mission?, String>((ref, id) {
  for (final m in ref.watch(visibleMissionsProvider)) {
    if (m.id == id) return m;
  }
  return null;
});

/// Airflow sweep for the worst case (file min → file max or the airflow slider max).
final airflowSweepProvider = Provider<List<double>>((ref) {
  final data = ref.watch(loadedDataProvider);
  final f = data.missions;
  final sliderMax = data.featureSpec.inputs['flow_velocity_mm_s']?.max ?? 1000;
  return airflowSweep(f.sweepMin, f.sweepMax ?? sliderMax, f.sweepN);
});

/// Material assessments for a mission, sorted by verdict then probability.
final missionAssessmentProvider =
    Provider.family<List<MaterialAssessment>, String>((ref, id) {
      final m = ref.watch(missionByIdProvider(id));
      if (m == null) return const [];
      final p = ref.watch(predictorProvider);
      final groups = p.spec.sustain.groups;
      final defaults = ref.watch(defaultLabInputProvider);
      return assessMission(
        p,
        m,
        ref.watch(materialsProvider),
        sweep: ref.watch(airflowSweepProvider),
        directions:
            groups['flow_direction']?.options ?? [defaults.flowDirection],
        defaults: defaults,
      );
    });

/// The experiment wishlist for a mission, or null when the burning model is unavailable.
final wishlistProvider = Provider.family<Wishlist?, String>((ref, id) {
  final m = ref.watch(missionByIdProvider(id));
  if (m == null) return null;
  return buildWishlist(
    ref.watch(predictorProvider),
    m,
    ref.watch(materialsProvider),
    ref.watch(defaultLabInputProvider),
    visiblePlanned(ref.watch(loadedDataProvider).missions, id),
  );
});
