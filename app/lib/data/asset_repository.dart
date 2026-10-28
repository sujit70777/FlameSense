import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/app_meta.dart';
import 'models/ask_models.dart';
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

  /// Optional files (lessons, missions, ask cache) are empty when absent.
  ///
  /// Presence is checked in the asset manifest, because on the web a missing
  /// file is answered with index.html (SPA fallback) rather than a 404.
  Future<Map<String, dynamic>?> _optional(String file) async {
    if (!(await _listed()).contains('$prefix$file')) return null;
    return _json(file);
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
    final meta = await _json('app_meta.json');
    final runs = await _json('runs.json');
    final spec = await _json('feature_spec.json');
    final support = await _json('support_index.json');
    final metrics = await _json('metrics.json');
    final physics = await _json('physics_params.json');
    final models = {for (final f in kModelFiles) f: await _json(f)};
    final lessons = await _optional('lessons.json');
    final missions = await _optional('missions.json');
    final askCache = await _optional('ask_cache.json');
    final usability = await _optional('usability.json');
    return AppData(
      meta: _parse('app_meta.json', meta, AppMeta.fromJson),
      runs: _parse('runs.json', runs, RunsTable.fromJson),
      featureSpec: _parse('feature_spec.json', spec, FeatureSpec.fromJson),
      modelJson: models,
      supportSustain: _parse(
        'support_index.json',
        support,
        (j) => SupportIndexData.fromJson(asMap(j['sustain'])),
      ),
      supportSpread: _parse(
        'support_index.json',
        support,
        (j) => SupportIndexData.fromJson(asMap(j['spread'])),
      ),
      metrics: _parse('metrics.json', metrics, Metrics.fromJson),
      physics: _parse('physics_params.json', physics, PhysicsParams.fromJson),
      lessons: lessons == null
          ? const []
          : _parse(
              'lessons.json',
              lessons,
              (j) =>
                  asList(j['lessons'])
                      .map((l) => Lesson.fromJson(asMap(l)))
                      .toList(),
            ),
      missions: missions == null
          ? MissionsFile.empty
          : _parse('missions.json', missions, MissionsFile.fromJson),
      askCache: askCache == null
          ? const []
          : _parse('ask_cache.json', askCache, parseAskCache),
      usability: usability == null
          ? Usability.empty
          : _parse('usability.json', usability, Usability.fromJson),
    );
  }
}
