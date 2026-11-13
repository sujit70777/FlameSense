import 'json_utils.dart';

/// One ranked research gap for the Home "Key findings & gaps" panel
/// (DESIGN.md §11.1b). The copy lives in l10n, keyed by [id]; [params] holds
/// the numbers computed at export.
class HomeTopGap {
  const HomeTopGap({
    required this.id,
    required this.rank,
    required this.score,
    required this.link,
    required this.params,
  });

  /// Parses one `home.topGaps` entry.
  factory HomeTopGap.fromJson(Map<String, dynamic> j) => HomeTopGap(
    id: asString(j['id']) ?? '',
    rank: asInt(j['rank']) ?? 0,
    score: asDouble(j['score']) ?? 0,
    link: asString(j['link']) ?? '',
    params: asMap(j['params']),
  );

  final String id, link;
  final int rank;
  final double score;
  final Map<String, dynamic> params;

  /// Integer parameter [k], or 0.
  int n(String k) => asInt(params[k]) ?? 0;

  /// Numeric parameter [k], or null.
  double? x(String k) => asDouble(params[k]);
}

/// One cited source in the Data provenance table (`app_meta.json` `sources`).
class SourceProvenance {
  const SourceProvenance({
    required this.sourceType,
    required this.authorship,
    required this.citation,
    required this.url,
    required this.experiments,
    required this.nRuns,
    required this.nDroppedDuplicates,
  });

  /// Parses one `sources` entry.
  factory SourceProvenance.fromJson(Map<String, dynamic> j) => SourceProvenance(
    sourceType: asString(j['source_type']) ?? '',
    authorship: asString(j['authorship']) ?? '',
    citation: asString(j['citation']) ?? '',
    url: asString(j['url']),
    experiments: asList(j['experiments']).map((e) => e.toString()).toList(),
    nRuns: asInt(j['n_runs']) ?? 0,
    nDroppedDuplicates: asInt(j['n_dropped_duplicates']) ?? 0,
  );

  final String sourceType, authorship, citation;
  final String? url;
  final List<String> experiments;
  final int nRuns, nDroppedDuplicates;
}

/// `app_meta.json` (PLAN.md §3.2).
class AppMeta {
  const AppMeta({
    required this.buildTimeUtc,
    required this.gitSha,
    required this.nRuns,
    required this.nExperiments,
    required this.nFuels,
    required this.experiments,
    required this.dataVersion,
    required this.sourceType,
    required this.gravityClass,
    required this.experimentCounts,
    required this.modelUse,
    required this.homeMaxO2MicrogravitySolidsPct,
    required this.homeMapLowCells,
    required this.homeMapTotalCells,
    required this.homeMaterialsOutsideMoonBase,
    required this.homeMaterialsTotal,
    required this.homeTopGaps,
    required this.homeMoonBaseMissionId,
    required this.sources,
    required this.rowsIngested,
    required this.rowsDropped,
  });

  /// Parses app_meta.json.
  factory AppMeta.fromJson(Map<String, dynamic> j) {
    final home = asMap(j['home']);
    return AppMeta(
      buildTimeUtc: asString(j['build_time_utc']) ?? '',
      gitSha: asString(j['git_sha']) ?? 'unknown',
      nRuns: asInt(j['n_runs']) ?? 0,
      nExperiments: asInt(j['n_experiments']) ?? 0,
      nFuels: asInt(j['n_fuels']) ?? 0,
      experiments: asList(j['experiments']).map((e) => e.toString()).toList(),
      dataVersion: asString(j['data_version']) ?? '',
      sourceType: _intMap(asMap(j['source_type'])),
      gravityClass: _intMap(asMap(j['gravity_class'])),
      experimentCounts: _intMap(asMap(j['experiment'])),
      modelUse: _intMap(asMap(j['model_use'])),
      homeMaxO2MicrogravitySolidsPct:
          asInt(home['maxO2MicrogravitySolidsPct']) ??
          asInt(j['home_max_o2_microgravity_solids_pct']) ??
          0,
      homeMapLowCells:
          asInt(home['mapLowCells']) ?? asInt(j['home_map_low_cells']) ?? 0,
      homeMapTotalCells:
          asInt(home['mapTotalCells']) ?? asInt(j['home_map_total_cells']) ?? 0,
      homeMaterialsOutsideMoonBase:
          asInt(home['materialsOutsideMoonBase']) ??
          asInt(j['home_materials_outside_moon_base']) ??
          0,
      homeMaterialsTotal:
          asInt(home['materialsTotal']) ??
          asInt(j['home_materials_total']) ??
          0,
      homeTopGaps:
          (asList(home['topGaps']).isNotEmpty
                  ? asList(home['topGaps'])
                  : asList(j['home_top_gaps']))
              .map((e) => HomeTopGap.fromJson(asMap(e)))
              .toList(),
      homeMoonBaseMissionId:
          asString(asMap(home['moonBase'])['missionId']) ?? '',
      sources: asList(j['sources'])
          .map((e) => SourceProvenance.fromJson(asMap(e)))
          .toList(),
      rowsIngested: asInt(j['rows_ingested']) ?? asInt(j['n_runs']) ?? 0,
      rowsDropped: asInt(j['rows_dropped']) ?? 0,
    );
  }

  static Map<String, int> _intMap(Map<String, dynamic> m) => m.map(
    (k, v) =>
        MapEntry(k, (v is num ? v : int.tryParse(v.toString()) ?? 0).toInt()),
  );

  final String buildTimeUtc, gitSha, dataVersion;
  final int nRuns, nExperiments, nFuels;
  final List<String> experiments;
  final Map<String, int> sourceType, gravityClass, experimentCounts, modelUse;

  /// Home key findings (DESIGN.md §11.1b).
  final int homeMaxO2MicrogravitySolidsPct;
  final int homeMapLowCells;
  final int homeMapTotalCells;
  final int homeMaterialsOutsideMoonBase;
  final int homeMaterialsTotal;
  final List<HomeTopGap> homeTopGaps;

  /// Mission whose atmosphere the Moon-base finding uses (links to Missions).
  final String homeMoonBaseMissionId;

  /// Data provenance: one entry per cited source, largest first.
  final List<SourceProvenance> sources;

  /// Rows read at ingest, and rows dropped as exact duplicates (logged).
  final int rowsIngested, rowsDropped;

  /// Runs from NASA (PSI and NASA reports).
  int get nasaRuns =>
      (sourceType['nasa_psi'] ?? 0) + (sourceType['nasa_report'] ?? 0);

  /// Runs used by the sustain model.
  int get sustainRuns => modelUse['sustain'] ?? 0;

  /// Runs used by the spread model.
  int get spreadRuns => modelUse['spread'] ?? 0;

  /// Runs used only by the sustain model.
  int get sustainOnlyRuns => modelUse['sustain_only'] ?? 0;

  /// Runs used only by the spread model.
  int get spreadOnlyRuns => modelUse['spread_only'] ?? 0;

  /// Runs used by both models.
  int get bothModelsRuns => modelUse['both'] ?? 0;

  /// Runs not used by any model.
  int get neitherModelRuns => modelUse['neither'] ?? 0;
}
