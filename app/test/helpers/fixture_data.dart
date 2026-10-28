import 'dart:io';

import 'package:flamesense/core/providers.dart';
import 'package:flamesense/data/asset_repository.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// Loads AppData from test/fixtures (synthetic, tests only) or the real assets.
Future<AppData> loadData({bool fixtures = true}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  return AssetRepository(
    bundle: FixtureBundle(useFixtures: fixtures),
    listedAssets: listedDataAssets(fixtures: fixtures),
  ).load();
}

/// Override that makes `loadedDataProvider` return [data] in a bare ProviderContainer.
Override loadedDataOverride(dynamic data) =>
    loadedDataProvider.overrideWithValue(data as AppData);

/// Raw fixture physics params JSON (FIXTURE values, not real).
Future<String> loadFixturePhysics() async =>
    File('test/fixtures/fixture_physics_params.json').readAsString();
