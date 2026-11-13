// PLAN.md §1.0 "Unfinished = hidden" and "Hosting": the feature registry hides pages
// whose data is not ready, and Ask never hangs or shows the SPA HTML as an answer.
import 'dart:async';

import 'package:flamesense/core/features.dart';
import 'package:flamesense/features/ask/ask_client.dart';
import 'package:flamesense/features/ask/ask_providers.dart';
import 'package:flamesense/features/shell/nav_items.dart';
import 'package:flamesense/features/tour/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers/test_app.dart';

ProviderContainer _c(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Scaffold).first));

/// Real data with no saved Ask answers and no lessons: both pages must hide.
const _releaseLessons = {
  'lessons.json': 'empty_lessons.json',
  'ask_cache.json': 'empty_ask_cache.json',
};

String _path(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(Scaffold).first)).state.uri.path;

/// Ask client whose endpoint serves the SPA's index.html (static host, no function).
final _htmlAsk = askClientProvider.overrideWithValue(
  AskClient(
    client: MockClient(
      (_) async => http.Response(
        '<!DOCTYPE html><html></html>',
        200,
        headers: {'content-type': 'text/html'},
      ),
    ),
    endpoint: Uri.parse('http://x.test/api/ask'),
  ),
);

void main() {
  test('allowsLocation maps paths to features', () {
    const none = FeatureRegistry({});
    for (final p in ['/', '/lab?g=1', '/map', '/explore?tab=runs', '/about']) {
      expect(none.allowsLocation(p), isTrue, reason: p);
    }
    for (final p in [
      '/missions',
      '/missions/artemis_lunar',
      '/ask',
      '/earth',
    ]) {
      expect(none.allowsLocation(p), isFalse, reason: p);
    }
    const all = FeatureRegistry({...Feature.values});
    expect(NavSection.values.every(all.showsSection), isTrue);
    expect(none.visible(NavSection.primary), [
      NavSection.home,
      NavSection.explore,
      NavSection.lab,
      NavSection.map,
    ]);
  });

  testWidgets('shipped data: Ask shows once saved answers exist', (
    tester,
  ) async {
    await pumpApp(tester, fixtures: false, height: 3000);
    expect(_c(tester).read(featuresProvider).has(Feature.ask), isTrue);
  });

  testWidgets('no saved answers and no lessons: Ask and Earth are hidden', (
    tester,
  ) async {
    await pumpApp(tester, fixtures: false, swap: _releaseLessons, height: 3000);
    final f = _c(tester).read(featuresProvider);
    expect(f.has(Feature.ask), isFalse);
    expect(f.has(Feature.earth), isFalse);
    expect(f.has(Feature.missions), isTrue);
    expect(f.has(Feature.coverage), isTrue);
    // Rail and Home "where to go next" skip them.
    expect(find.bySemanticsLabel(RegExp(r'^Ask$')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'^Earth lessons$')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(r'^Fire Lab$')), findsWidgets);
    expect(find.textContaining('Ask the NASA papers'), findsNothing);
  });

  testWidgets('deep link to a hidden page goes Home (no empty page)', (
    tester,
  ) async {
    for (final p in ['/ask', '/earth']) {
      await pumpApp(
        tester,
        location: p,
        fixtures: false,
        swap: _releaseLessons,
      );
      await settle(tester, frames: 6);
      expect(_path(tester), '/', reason: p);
    }
  });

  testWidgets('tour skips steps on hidden pages', (tester) async {
    await pumpApp(tester, fixtures: false, swap: _releaseLessons, height: 1400);
    final c = _c(tester);
    c.read(tourProvider.notifier).start();
    await settle(tester, frames: 10);
    expect(find.text('Step 1 of 6'), findsOneWidget);
    final seen = <String>{};
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester, frames: 10);
      seen.add(_path(tester));
    }
    expect(seen.intersection({'/ask', '/earth'}), isEmpty);
    expect(find.text('Finish'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await settle(tester, frames: 4);
    expect(c.read(tourProvider), isNull);
  });

  testWidgets('compact: bottom nav and More sheet skip hidden sections', (
    tester,
  ) async {
    await pumpApp(
      tester,
      fixtures: false,
      swap: _releaseLessons,
      width: 360,
      height: 800,
    );
    await tester.tap(find.text('More'));
    await settle(tester, frames: 6);
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Ask'), findsNothing);
    expect(find.text('Earth lessons'), findsNothing);
  });

  testWidgets('an invalid optional file hides its feature, app still loads', (
    tester,
  ) async {
    await pumpApp(tester, swap: {'missions.json': 'invalid_json.json'});
    expect(find.text("FlameSense couldn't load its data"), findsNothing);
    final c = _c(tester);
    expect(c.read(featuresProvider).has(Feature.missions), isFalse);
    expect(c.read(featuresProvider).has(Feature.ask), isTrue);
    expect(find.bySemanticsLabel(RegExp(r'^Missions$')), findsNothing);
  });

  testWidgets('Ask: SPA HTML from /api/ask shows the unavailable notice; '
      'cached answers still work', (tester) async {
    await pumpApp(
      tester,
      location: '/ask',
      height: 2400,
      overrides: [_htmlAsk],
    );
    await tester.enterText(find.byType(TextField), 'Why do flames flicker?');
    await tester.tap(find.widgetWithText(InkWell, 'Ask').last);
    await settle(tester, frames: 6);
    expect(
      find.textContaining("Free-form questions aren't available"),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
    await tester.tap(
      find.text(
        'How is a candle flame in microgravity different from one on Earth?',
      ),
    );
    await tester.pump();
    expect(find.text('Saved answer'), findsOneWidget);
  });

  testWidgets('Ask never hangs: a stalled endpoint ends in a notice', (
    tester,
  ) async {
    final stalled = askClientProvider.overrideWithValue(
      AskClient(
        client: MockClient((_) => Completer<http.Response>().future),
        endpoint: Uri.parse('http://x.test/api/ask'),
      ),
    );
    await pumpApp(tester, location: '/ask', height: 2400, overrides: [stalled]);
    await tester.enterText(find.byType(TextField), 'Why do flames flicker?');
    await tester.tap(find.widgetWithText(InkWell, 'Ask').last);
    await tester.pump();
    expect(_c(tester).read(askControllerProvider).current!.loading, isTrue);
    await tester.pump(kAskTimeout + const Duration(seconds: 1));
    await tester.pump();
    final cur = _c(tester).read(askControllerProvider).current!;
    expect(cur.loading, isFalse);
    expect(cur.error, isNotNull);
  });
}
