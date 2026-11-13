import 'dart:convert';
import 'dart:io';

import 'package:flamesense/data/models/lesson.dart';
import 'package:flamesense/features/earth/lessons_filter.dart';
import 'package:flamesense/features/tour/tour_caption.dart';
import 'package:flamesense/features/tour/tour_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_app.dart';

Lesson lesson(
  String id,
  String status, {
  bool source = true,
  String? reviewer = 'LEAD',
}) => Lesson.fromJson({
  'id': id,
  'status': status,
  'title_en': 'FIXTURE $id',
  'reviewed_by': reviewer,
  'sources': source
      ? [
          {'label': 'FIXTURE', 'url': 'https://example.test'},
        ]
      : [],
});

String path(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(Scaffold).first)).state.uri.path;

void main() {
  test('drafts and unsourced lessons are hidden in release', () {
    final all = [
      lesson('L1', 'approved'),
      lesson('L2', 'draft'),
      lesson('L3', 'approved', source: false),
      lesson('L4', 'approved', reviewer: null),
    ];
    expect(visibleLessons(all, release: true).map((l) => l.id), ['L1']);
    expect(visibleLessons(all, release: false), hasLength(4));
  });

  test('shipped lessons are drafts: hidden in release until LEAD approves', () {
    final raw = jsonDecode(
      File('assets/data/lessons.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final all = (raw['lessons'] as List)
        .map((j) => Lesson.fromJson(j as Map<String, dynamic>))
        .toList();
    for (final l in all) {
      expect(l.sources.every((s) => s.url.startsWith('https://')), isTrue);
    }
    expect(
      visibleLessons(all, release: true).map((l) => l.id),
      all.where((l) => l.isApproved).map((l) => l.id),
    );
  });

  testWidgets('Earth with no approved lessons is hidden, not an empty page', (
    tester,
  ) async {
    await pumpApp(
      tester,
      location: '/earth',
      fixtures: false,
      swap: {'lessons.json': 'empty_lessons.json'},
    );
    await settle(tester, frames: 6);
    expect(find.text('Lessons are being reviewed'), findsNothing);
    expect(path(tester), '/');
  });

  testWidgets('Earth with an approved lesson lists it', (tester) async {
    await pumpApp(tester, location: '/earth', swap: allFeatures);
    expect(find.text('FIXTURE lesson title'), findsOneWidget);
    expect(
      find.textContaining('not safety rules for a specific building'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Methods renders every section, equations, and pending sign-off',
    (tester) async {
      await pumpApp(tester, location: '/methods?s=physics', height: 3000);
      for (final t in [
        'Where the data comes from',
        'How predictions work',
        'How well it works',
        'Data support and extrapolation',
        'Limitations',
        'What FlameSense will never do',
      ]) {
        expect(find.text(t), findsWidgets, reason: t);
      }
      expect(find.byType(Math), findsWidgets);
      expect(
        find.textContaining('Checked against the cited sources'),
        findsOneWidget,
      ); // fixture physics is signed off
      expect(
        find.textContaining('oxygen constraint is switched off'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Methods on real data: no usability results, so that section is hidden',
    (tester) async {
      await pumpApp(
        tester,
        location: '/methods',
        fixtures: false,
        height: 3000,
      );
      expect(find.text('Tested with people'), findsNothing);
      expect(
        find.textContaining('Results appear here after the usability test'),
        findsNothing,
      );
      expect(find.text('Pending verification'), findsWidgets);
    },
  );

  testWidgets(
    'real data: Lab explains orbit-only gravity; Home leads with the gap',
    (tester) async {
      await pumpApp(tester, location: '/lab', fixtures: false, height: 3000);
      expect(
        find.textContaining(
          'Every NASA run the models learned from was in orbit',
        ),
        findsOneWidget,
      );
      await pumpApp(tester, location: '/', fixtures: false, height: 3000);
      expect(find.text('See what NASA should test next'), findsOneWidget);
      await tester.tap(find.text('See what NASA should test next'));
      await settle(tester, frames: 6);
      expect(
        GoRouter.of(tester.element(find.byType(Scaffold).first)).state.uri.path,
        startsWith('/missions'),
      );
    },
  );

  testWidgets(
    'About shows not-affiliated, privacy, and opens the licenses page',
    (tester) async {
      await pumpApp(tester, location: '/about', height: 3000);
      expect(
        find.text(
          'Not affiliated with or endorsed by NASA. Uses NASA open data.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('collects no personal data'), findsOneWidget);
      await tester.tap(find.text('View all licenses'));
      await settle(tester, frames: 10);
      expect(find.byType(LicensePage), findsOneWidget);
    },
  );

  testWidgets('tour walks all 8 steps across routes; Esc exits', (
    tester,
  ) async {
    await pumpApp(tester, height: 1400, swap: allFeatures);
    final c = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    c.read(tourProvider.notifier).start();
    await settle(tester, frames: 10);
    expect(find.text('Step 1 of 8'), findsOneWidget);
    expect(find.text('Fire changes shape without gravity'), findsOneWidget);
    final routes = [
      '/lab',
      '/lab',
      '/map',
      '/missions',
      '/explore',
      '/ask',
      '/earth',
    ];
    for (var i = 0; i < routes.length; i++) {
      await tester.tap(find.text('Next'));
      await settle(tester, frames: 10);
      expect(path(tester), routes[i], reason: 'step ${i + 2}');
      expect(find.text('Step ${i + 2} of 8'), findsOneWidget);
    }
    expect(find.text('Finish'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await settle(tester, frames: 6);
    expect(find.text('Step 7 of 8'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester, frames: 4);
    expect(c.read(tourProvider), isNull);
    expect(find.textContaining('of 8'), findsNothing);
  });

  testWidgets('?tour=1 starts the tour', (tester) async {
    await pumpApp(
      tester,
      location: '/?tour=1',
      height: 1400,
      swap: allFeatures,
    );
    await settle(tester, frames: 6);
    expect(find.text('Step 1 of 8'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await settle(tester, frames: 10);
    expect(find.text('Step 2 of 8'), findsOneWidget);
  });

  test('caption goes right of the target, else below, else above', () {
    const area = Size(1440, 900);
    expect(
      TourCaption.place(const Rect.fromLTWH(100, 100, 300, 300), area).dx,
      greaterThan(400),
    );
    final below = TourCaption.place(
      const Rect.fromLTWH(1000, 100, 400, 200),
      area,
    );
    expect(below.dy, greaterThan(300));
    final above = TourCaption.place(
      const Rect.fromLTWH(1000, 600, 400, 280),
      area,
    );
    expect(above.dy, lessThan(600));
  });
}
