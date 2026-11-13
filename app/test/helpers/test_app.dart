import 'dart:io';

import 'package:flamesense/app.dart';
import 'package:flamesense/core/providers.dart';
import 'package:flamesense/core/router.dart';
import 'package:flamesense/core/theme/theme.dart';
import 'package:flamesense/data/asset_repository.dart';
import 'package:flamesense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Swap map that serves one approved lesson so every optional feature (missions, Ask,
/// Earth, coverage) is enabled in the fixture app (core/features.dart).
const allFeatures = {'lessons.json': 'lessons_approved.json'};

/// Swap map that serves the empty pre-refresh dataset (`fixture_empty_*`), for
/// tests of the no-data states now that the real assets hold runs.
final emptyDataset = {
  for (final n in [
    'app_meta',
    'coverage',
    'feature_spec',
    'metrics',
    'model_spread_q10',
    'model_spread_q50',
    'model_spread_q90',
    'parity_fixtures',
    'runs',
    'support_index',
  ])
    '$n.json': 'empty_$n.json',
};

/// Asset bundle that serves `test/fixtures/fixture_<name>` in place of
/// `assets/data/<name>` when it exists (tests only; never shipped).
class FixtureBundle extends CachingAssetBundle {
  FixtureBundle({
    this.useFixtures = true,
    this.missing = const {},
    this.swap = const {},
  });

  final bool useFixtures;

  /// Data files served from another fixture, e.g. `runs.json` → `empty_runs.json`.
  final Map<String, String> swap;

  /// Data files to report as missing (error-screen tests).
  final Set<String> missing;

  @override
  Future<ByteData> load(String key) async {
    final name = key.split('/').last;
    if (key.startsWith('assets/data/') && missing.contains(name)) {
      throw FlutterError('Unable to load asset: $key');
    }
    final swapped = swap[name];
    if (key.startsWith('assets/data/') && swapped != null) {
      return ByteData.sublistView(
        File('test/fixtures/fixture_$swapped').readAsBytesSync(),
      );
    }
    final fixture = File('test/fixtures/fixture_$name');
    if (useFixtures && key.startsWith('assets/data/') && fixture.existsSync()) {
      final bytes = fixture.readAsBytesSync();
      return ByteData.sublistView(bytes);
    }
    return rootBundle.load(key);
  }
}

/// Data assets the test bundle can serve: real files plus fixture overrides.
Set<String> listedDataAssets({
  bool fixtures = true,
  Set<String> missing = const {},
}) {
  final names = <String>{
    for (final f in Directory('assets/data').listSync())
      f.uri.pathSegments.last,
    if (fixtures)
      for (final f in Directory('test/fixtures').listSync())
        if (f.uri.pathSegments.last.startsWith('fixture_'))
          f.uri.pathSegments.last.substring(8),
  };
  return {for (final n in names.difference(missing)) 'assets/data/$n'};
}

bool _fontsLoaded = false;

/// Loads the shipped fonts so text metrics match production.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  for (final (family, path) in [
    ('Archivo', 'assets/fonts/Archivo[wdth,wght].ttf'),
    ('FsSymbols', 'assets/fonts/FsSymbols.ttf'),
  ]) {
    final loader = FontLoader(family)..addFont(rootBundle.load(path));
    await loader.load();
  }
  _fontsLoaded = true;
}

/// Sets the test window to [width] × [height] logical pixels.
void setWindow(WidgetTester tester, double width, [double height = 900]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.reset);
}

/// Pumps the full app at [location] with fixture data and mock preferences.
Future<SharedPreferences> pumpApp(
  WidgetTester tester, {
  String location = '/',
  Map<String, Object> prefs = const {},
  bool fixtures = true,
  Set<String> missing = const {},
  Map<String, String> swap = const {},
  double width = 1440,
  double height = 900,
  List overrides = const [],
}) async {
  await loadAppFonts();
  setWindow(tester, width, height);
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final bundle = FixtureBundle(
    useFixtures: fixtures,
    missing: missing,
    swap: swap,
  );
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        assetRepositoryProvider.overrideWithValue(
          AssetRepository(
            bundle: bundle,
            listedAssets: listedDataAssets(
              fixtures: fixtures,
              missing: missing,
            ),
          ),
        ),
        routerProvider.overrideWithValue(
          buildRouter(initialLocation: location),
        ),
        ...overrides.cast(),
      ],
      child: const FlameSenseApp(),
    ),
  );
  await settle(tester);
  return sp;
}

/// Pumps frames until async asset loading and transitions finish (no
/// pumpAndSettle: some widgets animate forever by design).
Future<void> settle(WidgetTester tester, {int frames = 30}) async {
  for (var i = 0; i < frames; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Wraps [child] in a ProviderScope + themed, localised MaterialApp for widget tests.
/// Call `await testPrefs()` first.
Widget themed(
  Widget child, {
  Brightness brightness = Brightness.light,
  String locale = 'en',
  bool compact = false,
  List overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs!),
      ...overrides.cast(),
    ],
    child: MaterialApp(
      theme: buildFsTheme(brightness, compact: compact, bn: locale == 'bn'),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(body: child),
    ),
  );
}

SharedPreferences? _prefs;

/// Initialises mock SharedPreferences for [themed] widget tests.
Future<SharedPreferences> testPrefs([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return _prefs = await SharedPreferences.getInstance();
}
