import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/run_record.dart';
import 'explore_filters.dart';

/// Current Explore filters.
class ExploreFiltersNotifier extends Notifier<ExploreFilters> {
  @override
  ExploreFilters build() => ExploreFilters.none;

  /// Replaces the filters.
  void set(ExploreFilters f) => state = f;

  /// Clears every filter.
  void clear() => state = ExploreFilters.none;
}

final exploreFiltersProvider =
    NotifierProvider<ExploreFiltersNotifier, ExploreFilters>(
      ExploreFiltersNotifier.new,
    );

/// Current table sort column and direction.
class ExploreSortNotifier extends Notifier<(RunColumn, bool)> {
  @override
  (RunColumn, bool) build() => (RunColumn.run, true);

  /// Sorts by [c]; tapping the same column again flips the direction.
  void sortBy(RunColumn c) => state = (c, state.$1 == c ? !state.$2 : true);
}

final exploreSortProvider =
    NotifierProvider<ExploreSortNotifier, (RunColumn, bool)>(
      ExploreSortNotifier.new,
    );

/// Runs passing the filters (unsorted; charts use this).
final filteredRunsProvider = Provider<List<RunRecord>>(
  (ref) => ref
      .watch(exploreFiltersProvider)
      .apply(ref.watch(loadedDataProvider).runs.records),
);

/// Filtered runs in table order.
final sortedRunsProvider = Provider<List<RunRecord>>((ref) {
  final (col, asc) = ref.watch(exploreSortProvider);
  return sortRuns(ref.watch(filteredRunsProvider), col, ascending: asc);
});
