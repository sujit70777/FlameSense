import 'package:flamesense/data/asset_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// Loads AppData from test/fixtures (synthetic, tests only) or the real assets.
Future<AppData> loadData({bool fixtures = true}) {
  TestWidgetsFlutterBinding.ensureInitialized();
  return AssetRepository(bundle: FixtureBundle(useFixtures: fixtures)).load();
}
