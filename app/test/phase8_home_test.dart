import 'package:flamesense/domain/gravity.dart';
import 'package:flamesense/features/home/home_providers.dart';
import 'package:flamesense/widgets/flame_twin/flame_painter.dart';
import 'package:flamesense/widgets/flame_twin/flame_twin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

void main() {
  setUp(() => homeIgnitedThisSession = false);

  for (final width in [360.0, 768.0, 1440.0]) {
    testWidgets('home renders at $width px without overflow', (tester) async {
      await pumpApp(tester, width: width, height: 2400);
      expect(tester.takeException(), isNull);
      expect(find.text('Fire has no "up" in space.'), findsOneWidget);
      expect(find.byType(FlameTwin), findsNWidgets(2));
      expect(
        find.text('Buoyant airflow'),
        findsNWidgets(2),
      ); // fixture physics is signed off
      expect(find.textContaining('Built on'), findsOneWidget);
    });
  }

  testWidgets('gravity snaps move the right-hand flame', (tester) async {
    await pumpApp(tester, height: 1600);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FlameTwin).first),
    );
    expect(container.read(homeGravityProvider), kIssG);
    await tester.tap(find.text('Moon').last);
    await tester.pump();
    expect(container.read(homeGravityProvider), kMoonG);
    final flames = tester
        .widgetList<FlameTwin>(find.byType(FlameTwin))
        .toList();
    expect(flames.map((f) => f.gravityG), [kEarthG, kMoonG]);
  });

  testWidgets('reduced motion: flame controller is not animating', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester, height: 1600);
    for (final s in tester.stateList<FlameTwinState>(find.byType(FlameTwin))) {
      expect(s.controller.isAnimating, isFalse);
    }
  });

  testWidgets(
    'Earth flame flickers when motion is allowed; ISS flame is steady',
    (tester) async {
      await pumpApp(tester, height: 1600);
      final states = tester
          .stateList<FlameTwinState>(find.byType(FlameTwin))
          .toList();
      expect(states[0].controller.isAnimating, isTrue);
      expect(states[1].controller.isAnimating, isFalse);
    },
  );

  testWidgets('ignition plays only once per session', (tester) async {
    await pumpApp(tester, height: 1600);
    expect(homeIgnitedThisSession, isTrue);
  });

  testWidgets('Open the Fire Lab carries the current gravity', (tester) async {
    await pumpApp(tester, height: 1600);
    await tester.tap(find.text('Mars').last);
    await tester.pump();
    await tester.tap(find.text('Open the Fire Lab'));
    await settle(tester, frames: 6);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    expect(router.state.uri.toString(), '/lab?g=0.3783');
  });

  test('flame shape: teardrop on Earth, sphere in orbit', () {
    const size = Size(260, 340);
    final earth = FlamePainter.outline(
      size,
      FlamePainter.buoyancy(1),
      0,
      false,
    );
    final iss = FlamePainter.outline(
      size,
      FlamePainter.buoyancy(1e-6),
      0,
      false,
    );
    double height(List<Offset> p) =>
        p.map((e) => e.dy).reduce((a, b) => a > b ? a : b) -
        p.map((e) => e.dy).reduce((a, b) => a < b ? a : b);
    double width(List<Offset> p) =>
        p.map((e) => e.dx).reduce((a, b) => a > b ? a : b) -
        p.map((e) => e.dx).reduce((a, b) => a < b ? a : b);
    expect(height(iss) / width(iss), closeTo(1, 1e-9));
    expect(height(earth) / width(earth), greaterThan(1.4));
    expect(FlamePainter.buoyancy(1e-6), closeTo(0, 1e-12));
    expect(FlamePainter.buoyancy(1), 1);
  });
}
