import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/app_meta.dart';
import 'models/ask_models.dart';
import 'models/coverage.dart';
import 'models/feature_spec.dart';
import 'models/json_utils.dart';
import 'models/lesson.dart';
import 'models/metrics.dart';
import 'models/missions_file.dart';
import 'models/physics_params.dart';
import 'models/run_record.dart';
import 'models/support_index_data.dart';
import 'models/usability.dart';

/// Model files exported by the pipeline (PLAN.md §3.2).
const kModelFiles = [
  'model_sustain.json',
  'model_spread_q10.json',
  'model_spread_q50.json',
  'model_spread_q90.json',
];

/// Thrown when a required asset is missing or cannot be parsed.
class AssetLoadException implements Exception {
  const AssetLoadException(this.file, this.cause);

  final String file;
  final Object cause;

  @override
  String toString() => 'AssetLoadException($file): $cause';
}

/// Everything the app reads at startup.
class AppData {
  const AppData({
    required this.meta,
    required this.runs,
    required this.featureSpec,
    required this.modelJson,
    required this.supportSustain,
    required this.supportSpread,
    required this.metrics,
    required this.physics,
    required this.lessons,
    required this.missions,
    required this.askCache,
    this.usability = Usability.empty,
    this.coverage = CoverageFile.empty,
    this.invalidAssets = const {},
  });

  final AppMeta meta;
  final RunsTable runs;
  final FeatureSpec featureSpec;

  /// Raw tree-model JSON by file name (parsed by domain/tree_model.dart).
  final Map<String, Map<String, dynamic>> modelJson;
  final SupportIndexData supportSustain, supportSpread;
  final Metrics metrics;
  final PhysicsParams physics;
  final List<Lesson> lessons;
  final MissionsFile missions;
  final List<AskCacheEntry> askCache;
  final Usability usability;

  /// PSI coverage atlas (empty until the pipeline `catalog` command has run).
  final CoverageFile coverage;

  /// Optional files that were shipped but failed to load or parse; their features are
  /// hidden (core/features.dart) instead of failing the whole app.
  final Set<String> invalidAssets;
}

/// Loads and parses the JSON assets under `assets/data/`.
class AssetRepository {
  /// Repository reading from [bundle] (defaults to the root bundle).
  AssetRepository({
    AssetBundle? bundle,
    this.prefix = 'assets/data/',
    Set<String>? listedAssets,
  }) : _bundle = bundle ?? rootBundle,
       _manifest = listedAssets;

  final AssetBundle _bundle;
  final String prefix;

  Future<Map<String, dynamic>> _json(String file) async {
    try {
      final text = await _bundle.loadString('$prefix$file', cache: false);
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('not a JSON object');
      }
      return decoded;
    } catch (e) {
      throw AssetLoadException(file, e);
    }
  }

  Set<String>? _manifest;

  Future<Set<String>> _listed() async {
    if (_manifest != null) return _manifest!;
    try {
      final m = await AssetManifest.loadFromAssetBundle(_bundle);
      return _manifest = m.listAssets().toSet();
    } catch (_) {
      return _manifest = <String>{};
    }
  }

  T _parse<T>(
    String file,
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) f,
  ) {
    try {
      return f(j);
    } catch (e) {
      throw AssetLoadException(file, e);
    }
  }

  /// Loads every asset; throws [AssetLoadException] naming the failing file.
  Future<AppData> load() async {
    final requiredFiles = [
      'app_meta.json',
      'runs.json',
      'feature_spec.json',
      'support_index.json',
      'metrics.json',
      'physics_params.json',
      ...kModelFiles,
    ];
    final optionalFiles = [
      'lessons.json',
      'missions.json',
      'ask_cache.json',
      'usability.json',
      'coverage.json',
    ];
    final listed = await _listed();
    final required = await Future.wait(requiredFiles.map(_json));
    final assets = Map<String, Map<String, dynamic>>.fromIterables(
      requiredFiles,
      required,
    );
    final invalid = <String>{};
    final present = optionalFiles.where((f) => listed.contains('$prefix$f'));
    await Future.wait(
      present.map((f) async {
        try {
          assets[f] = await _json(f);
        } on AssetLoadException catch (e) {
          invalid.add(f);
          debugPrint('Optional asset hidden: $e');
        }
      }),
    );
    T optional<T>(String file, T empty, T Function(Map<String, dynamic>) f) {
      final j = assets[file];
      if (j == null) return empty;
      try {
        return f(j);
      } catch (e) {
        invalid.add(file);
        debugPrint('Optional asset hidden: ${AssetLoadException(file, e)}');
        return empty;
      }
    }

    final models = {for (final f in kModelFiles) f: assets[f]!};
    return AppData(
      meta: _parse('app_meta.json', assets['app_meta.json']!, AppMeta.fromJson),
      runs: _parse('runs.json', assets['runs.json']!, RunsTable.fromJson),
      featureSpec: _parse(
        'feature_spec.json',
        assets['feature_spec.json']!,
        FeatureSpec.fromJson,
      ),
      modelJson: models,
      supportSustain: _parse(
        'support_index.json',
        assets['support_index.json']!,
        (j) => SupportIndexData.fromJson(asMap(j['sustain'])),
      ),
      supportSpread: _parse(
        'support_index.json',
        assets['support_index.json']!,
        (j) => SupportIndexData.fromJson(asMap(j['spread'])),
      ),
      metrics: _parse(
        'metrics.json',
        assets['metrics.json']!,
        Metrics.fromJson,
      ),
      physics: _parse(
        'physics_params.json',
        assets['physics_params.json']!,
        PhysicsParams.fromJson,
      ),
      lessons: optional<List<Lesson>>(
        'lessons.json',
        const [],
        (j) =>
            asList(j['lessons']).map((l) => Lesson.fromJson(asMap(l))).toList(),
      ),
      missions: optional(
        'missions.json',
        MissionsFile.empty,
        MissionsFile.fromJson,
      ),
      askCache: optional('ask_cache.json', const [], parseAskCache),
      usability: optional(
        'usability.json',
        Usability.empty,
        Usability.fromJson,
      ),
      coverage: optional(
        'coverage.json',
        CoverageFile.empty,
        CoverageFile.fromJson,
      ),
      invalidAssets: invalid,
    );
  }
}
