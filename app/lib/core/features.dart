import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_repository.dart';
import '../domain/missions.dart';
import '../features/earth/lessons_filter.dart';
import '../features/shell/nav_items.dart';
import 'providers.dart';

/// Features whose page or tab exists only when their data is shipped and valid.
///
/// Home, Explore (runs), Lab, Map, Methods and About read required assets: if any of
/// those fail, the data gate shows the error screen instead of the app.
enum Feature {
  /// Missions list and detail (F11–F13): `missions.json` with at least one visible mission.
  missions,

  /// Ask (F5): `ask_cache.json` with at least one saved English answer, so the page
  /// always has working questions even when `/api/ask` is down.
  ask,

  /// Safety tech & Earth (F23): `lessons.json` with at least one visible lesson.
  earth,

  /// Explore "What NASA has tested" tab (F19): a non-empty `coverage.json`.
  coverage,
}

/// Which optional features are ready (PLAN.md §1.0 "Unfinished = hidden").
@immutable
class FeatureRegistry {
  /// Registry with exactly [enabled] turned on.
  const FeatureRegistry(this.enabled);

  /// Computes the registry from what loaded and passed validation.
  factory FeatureRegistry.fromData(AppData d) => FeatureRegistry({
    if (visibleMissions(d.missions).isNotEmpty) Feature.missions,
    if (d.askCache.any((e) => e.id.endsWith('_en') && e.qEn.isNotEmpty))
      Feature.ask,
    if (visibleLessons(d.lessons).isNotEmpty) Feature.earth,
    if (!d.coverage.isEmpty) Feature.coverage,
  });

  final Set<Feature> enabled;

  /// Whether [f] is ready to show.
  bool has(Feature f) => enabled.contains(f);

  /// Whether the in-app [location] (path plus optional query) leads to a ready page.
  bool allowsLocation(String location) {
    final segs = Uri.parse(location).pathSegments.where((s) => s.isNotEmpty);
    return switch (segs.isEmpty ? '' : segs.first) {
      'missions' => has(Feature.missions),
      'ask' => has(Feature.ask),
      'earth' => has(Feature.earth),
      _ => true,
    };
  }

  /// Whether the shell section [s] is shown in navigation.
  bool showsSection(NavSection s) => allowsLocation(s.path);

  /// [sections] with hidden ones removed, order kept.
  List<NavSection> visible(List<NavSection> sections) =>
      sections.where(showsSection).toList();
}

/// The feature registry for the loaded data (valid below the AppDataGate).
final featuresProvider = Provider<FeatureRegistry>(
  (ref) => FeatureRegistry.fromData(ref.watch(loadedDataProvider)),
);
