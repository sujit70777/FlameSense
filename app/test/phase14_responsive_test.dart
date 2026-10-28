import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const routes = [
  '/',
  '/missions',
  '/missions/fixture_orbit',
  '/explore',
  '/explore/run/fixture%3A3',
  '/lab',
  '/map',
  '/ask',
  '/earth',
  '/methods',
  '/about',
  '/nope',
];

void main() {
  for (final width in [360.0, 390.0, 768.0, 1024.0, 1280.0, 1440.0, 1920.0]) {
    for (final theme in ['light', 'dark']) {
      testWidgets('every route at $width px ($theme) without overflow', (
        tester,
      ) async {
        for (final r in routes) {
          await pumpApp(
            tester,
            location: r,
            width: width,
            height: 1200,
            prefs: {'fs.theme': theme},
          );
          expect(tester.takeException(), isNull, reason: '$r at $width');
        }
      });
    }
  }

  for (final width in [360.0, 1440.0]) {
    testWidgets('Bangla: every route at $width px without overflow', (
      tester,
    ) async {
      for (final r in routes) {
        await pumpApp(
          tester,
          location: r,
          width: width,
          height: 1200,
          prefs: {'fs.locale': 'bn'},
        );
        expect(tester.takeException(), isNull, reason: '$r at $width (bn)');
      }
    });
  }

  testWidgets(
    'real (empty) data: every route at 360 and 1440 without overflow',
    (tester) async {
      for (final width in [360.0, 1440.0]) {
        for (final r in routes) {
          await pumpApp(
            tester,
            location: r,
            width: width,
            height: 1200,
            fixtures: false,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '$r at $width (real data)',
          );
        }
      }
    },
  );
}
