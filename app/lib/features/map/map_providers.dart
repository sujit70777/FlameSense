import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/run_record.dart';
import '../../domain/gravity.dart';
import '../../domain/providers.dart';
import 'map_grid.dart';

/// Map controls and overlays (DESIGN.md §11.4).
@immutable
class MapSettings {
  const MapSettings({
    required this.fuelClass,
    required this.pressureKpa,
    required this.gravityG,
    required this.flowDirection,
    this.showRuns = true,
    this.showContour = true,
    this.pinned,
  });

  final String fuelClass, flowDirection;
  final double pressureKpa, gravityG;
  final bool showRuns, showContour;

  /// Pinned (column, row), or null.
  final (int, int)? pinned;

  MapSettings copyWith({
    String? fuelClass,
    double? pressureKpa,
    double? gravityG,
    String? flowDirection,
    bool? showRuns,
    bool? showContour,
    (int, int)? Function()? pinned,
  }) => MapSettings(
    fuelClass: fuelClass ?? this.fuelClass,
    pressureKpa: pressureKpa ?? this.pressureKpa,
    gravityG: gravityG ?? this.gravityG,
    flowDirection: flowDirection ?? this.flowDirection,
    showRuns: showRuns ?? this.showRuns,
    showContour: showContour ?? this.showContour,
    pinned: pinned == null ? this.pinned : pinned(),
  );
}

/// Map settings; defaults follow the Lab defaults, and `/map?fuel=&p=&g=&dir=` overrides them.
class MapSettingsNotifier extends Notifier<MapSettings> {
  @override
  MapSettings build() {
    final x = ref.watch(defaultLabInputProvider);
    return MapSettings(
      fuelClass: x.fuelClass,
      pressureKpa: x.pressureKpa,
      gravityG: x.gravityG,
      flowDirection: x.flowDirection,
    );
  }

  /// Replaces the settings (changing conditions clears the pinned cell).
  void set(MapSettings s) => state = s;

  /// Applies `/map` query parameters.
  void applyQuery(Map<String, String> q) {
    double? d(String k) => double.tryParse(q[k] ?? '');
    state = state.copyWith(
      fuelClass: q['fuel'],
      pressureKpa: d('p'),
      gravityG: d('g'),
      flowDirection: q['dir'],
      pinned: () => null,
    );
  }
}

final mapSettingsProvider = NotifierProvider<MapSettingsNotifier, MapSettings>(
  MapSettingsNotifier.new,
);

/// Median thickness/density of the selected material type (falls back to Lab defaults).
final mapKeyProvider = Provider<MapKey>((ref) {
  final s = ref.watch(mapSettingsProvider);
  final mats = ref
      .watch(materialsProvider)
      .where((m) => m.fuelClass == s.fuelClass)
      .toList();
  final d = ref.watch(defaultLabInputProvider);
  final m = mats.isEmpty
      ? null
      : mats.reduce((a, b) => a.nRuns >= b.nRuns ? a : b);
  return MapKey(
    fuelClass: s.fuelClass,
    thicknessMm: m?.thicknessMm ?? d.thicknessMm,
    densityKgM3: m?.densityKgM3 ?? d.densityKgM3,
    pressureKpa: s.pressureKpa,
    gravityG: s.gravityG,
    flowDirection: s.flowDirection,
  );
});

/// The probability grid (memoized by MapKey); null when sustain is unavailable.
final mapGridProvider = Provider<MapGrid?>(
  (ref) => computeMapGrid(
    ref.watch(predictorProvider),
    ref.watch(loadedDataProvider).featureSpec,
    ref.watch(mapKeyProvider),
  ),
);

/// Runs drawn on the map: same material type and gravity class, with a known outcome and airflow.
final mapRunsProvider = Provider<List<RunRecord>>((ref) {
  final s = ref.watch(mapSettingsProvider);
  final g = gravityClassOf(s.gravityG);
  return ref
      .watch(loadedDataProvider)
      .runs
      .records
      .where(
        (r) =>
            r.fuelClass == s.fuelClass &&
            r.gravityClass == g &&
            r.sustained != null &&
            r.flowMmS != null,
      )
      .toList();
});

/// Runs in the selected gravity class (for the Moon/Mars gap notice).
final mapGravityClassCountProvider = Provider<int>((ref) {
  final g = gravityClassOf(ref.watch(mapSettingsProvider).gravityG);
  return ref
      .watch(loadedDataProvider)
      .runs
      .records
      .where((r) => r.gravityClass == g)
      .length;
});
