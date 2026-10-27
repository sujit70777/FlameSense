import 'package:flutter/foundation.dart';

import '../../data/models/run_record.dart';
import '../../domain/gravity.dart';

/// Explore filter state (DESIGN.md §11.2). Pure data; no Flutter widgets.
@immutable
class ExploreFilters {
  const ExploreFilters({
    this.experiments = const {},
    this.platform,
    this.fuelClass,
    this.gravity,
    this.o2Min,
    this.o2Max,
    this.pressureMin,
    this.pressureMax,
    this.includeEstimated = true,
    this.includeDigitized = true,
    this.includeVideo = true,
    this.includeFlagged = false,
  });

  /// Empty = every experiment.
  final Set<String> experiments;
  final String? platform, fuelClass;
  final GravityClass? gravity;
  final double? o2Min, o2Max, pressureMin, pressureMax;
  final bool includeEstimated, includeDigitized, includeVideo, includeFlagged;

  static const none = ExploreFilters();

  bool get isDefault => this == none;

  /// Number of filters that differ from the defaults (compact Filters button).
  int get activeCount => [
    experiments.isNotEmpty,
    platform != null,
    fuelClass != null,
    gravity != null,
    o2Min != null,
    pressureMin != null,
    includeEstimated != none.includeEstimated,
    includeDigitized != none.includeDigitized,
    includeVideo != none.includeVideo,
    includeFlagged != none.includeFlagged,
  ].where((b) => b).length;

  ExploreFilters copyWith({
    Set<String>? experiments,
    String? Function()? platform,
    String? Function()? fuelClass,
    GravityClass? Function()? gravity,
    (double?, double?)? o2,
    (double?, double?)? pressure,
    bool? includeEstimated,
    bool? includeDigitized,
    bool? includeVideo,
    bool? includeFlagged,
  }) => ExploreFilters(
    experiments: experiments ?? this.experiments,
    platform: platform == null ? this.platform : platform(),
    fuelClass: fuelClass == null ? this.fuelClass : fuelClass(),
    gravity: gravity == null ? this.gravity : gravity(),
    o2Min: o2 == null ? o2Min : o2.$1,
    o2Max: o2 == null ? o2Max : o2.$2,
    pressureMin: pressure == null ? pressureMin : pressure.$1,
    pressureMax: pressure == null ? pressureMax : pressure.$2,
    includeEstimated: includeEstimated ?? this.includeEstimated,
    includeDigitized: includeDigitized ?? this.includeDigitized,
    includeVideo: includeVideo ?? this.includeVideo,
    includeFlagged: includeFlagged ?? this.includeFlagged,
  );

  /// True when [r] passes every filter.
  bool matches(RunRecord r) {
    if (experiments.isNotEmpty && !experiments.contains(r.experiment)) {
      return false;
    }
    if (platform != null && r.platform != platform) return false;
    if (fuelClass != null && r.fuelClass != fuelClass) return false;
    if (gravity != null && r.gravityClass != gravity) return false;
    if (o2Min != null && r.o2 < o2Min!) return false;
    if (o2Max != null && r.o2 > o2Max!) return false;
    if (pressureMin != null && r.pressureKpa < pressureMin!) return false;
    if (pressureMax != null && r.pressureKpa > pressureMax!) return false;
    return switch (r.qualityFlag) {
      'estimated' => includeEstimated,
      'digitized' => includeDigitized,
      'video_derived' => includeVideo,
      'suspect' => includeFlagged,
      _ => true,
    };
  }

  /// Runs passing the filters, in input order.
  List<RunRecord> apply(List<RunRecord> runs) => runs.where(matches).toList();

  @override
  bool operator ==(Object other) =>
      other is ExploreFilters &&
      setEquals(other.experiments, experiments) &&
      other.platform == platform &&
      other.fuelClass == fuelClass &&
      other.gravity == gravity &&
      other.o2Min == o2Min &&
      other.o2Max == o2Max &&
      other.pressureMin == pressureMin &&
      other.pressureMax == pressureMax &&
      other.includeEstimated == includeEstimated &&
      other.includeDigitized == includeDigitized &&
      other.includeVideo == includeVideo &&
      other.includeFlagged == includeFlagged;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(experiments),
    platform,
    fuelClass,
    gravity,
    o2Min,
    o2Max,
    pressureMin,
    pressureMax,
    includeEstimated,
    includeDigitized,
    includeVideo,
    includeFlagged,
  );
}

/// Sortable table columns (DESIGN.md §9.22).
enum RunColumn {
  run,
  experiment,
  fuel,
  o2,
  pressure,
  flow,
  gravity,
  outcome,
  spread,
  quality,
}

/// Outcome rank used for sorting and the outcome cell: 2 kept burning, 1 went out, 0 no ignition, -1 unknown.
int outcomeRank(RunRecord r) {
  if (r.ignited == false) return 0;
  if (r.sustained == true) return 2;
  if (r.sustained == false) return 1;
  return -1;
}

Comparable<Object>? _key(RunRecord r, RunColumn c) => switch (c) {
  RunColumn.run => r.runId,
  RunColumn.experiment => r.experiment,
  RunColumn.fuel => r.fuelName.toLowerCase(),
  RunColumn.o2 => r.o2,
  RunColumn.pressure => r.pressureKpa,
  RunColumn.flow => r.flowMmS,
  RunColumn.gravity => r.gravityG,
  RunColumn.outcome => outcomeRank(r),
  RunColumn.spread => r.spreadMmS,
  RunColumn.quality => r.qualityFlag,
};

/// Sorted copy; missing values always sort last.
List<RunRecord> sortRuns(
  List<RunRecord> runs,
  RunColumn column, {
  bool ascending = true,
}) {
  final out = [...runs];
  out.sort((a, b) {
    final ka = _key(a, column), kb = _key(b, column);
    if (ka == null && kb == null) return a.runId.compareTo(b.runId);
    if (ka == null) return 1;
    if (kb == null) return -1;
    final c = ka.compareTo(kb);
    return ascending ? c : -c;
  });
  return out;
}

String _csvCell(Object? v) {
  if (v == null) return '';
  final s = v.toString();
  if (s.contains(RegExp('[",\n\r]'))) return '"${s.replaceAll('"', '""')}"';
  return s;
}

/// CSV of [runs] with every column (including `source_citation`), header first.
String runsToCsv(List<String> columns, List<RunRecord> runs) {
  final b = StringBuffer()..writeln(columns.map(_csvCell).join(','));
  for (final r in runs) {
    b.writeln(columns.map((c) => _csvCell(r[c])).join(','));
  }
  return b.toString();
}

/// `flamesense_runs_<yyyyMMdd>.csv`.
String csvFileName(DateTime now) {
  String two(int v) => v.toString().padLeft(2, '0');
  return 'flamesense_runs_${now.year}${two(now.month)}${two(now.day)}.csv';
}
