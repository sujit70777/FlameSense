import 'json_utils.dart';

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
  });

  /// Parses app_meta.json.
  factory AppMeta.fromJson(Map<String, dynamic> j) => AppMeta(
    buildTimeUtc: asString(j['build_time_utc']) ?? '',
    gitSha: asString(j['git_sha']) ?? 'unknown',
    nRuns: asInt(j['n_runs']) ?? 0,
    nExperiments: asInt(j['n_experiments']) ?? 0,
    nFuels: asInt(j['n_fuels']) ?? 0,
    experiments: asList(j['experiments']).map((e) => e.toString()).toList(),
    dataVersion: asString(j['data_version']) ?? '',
  );

  final String buildTimeUtc, gitSha, dataVersion;
  final int nRuns, nExperiments, nFuels;
  final List<String> experiments;
}
