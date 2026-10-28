import 'dart:io';
import 'dart:typed_data';

import 'package:flamesense/data/models/missions_file.dart';
import 'package:flamesense/domain/brief.dart';
import 'package:flamesense/domain/missions.dart';
import 'package:flamesense/domain/predictor.dart';
import 'package:flamesense/domain/providers.dart';
import 'package:flamesense/domain/support_index.dart';
import 'package:flamesense/domain/wishlist.dart';
import 'package:flamesense/features/missions/mission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';
import 'helpers/test_app.dart';

void main() {
  late Predictor p;
  late dynamic data;
  late Mission orbit;
  setUpAll(() async {
    data = await loadData();
    p = Predictor.fromData(data);
    orbit = (data.missions as MissionsFile).missions.firstWhere(
      (m) => m.id == 'fixture_orbit',
    );
  });

  test('verdict thresholds', () {
    expect(verdictFor(0.6, SupportLevel.high), Verdict.likelyBurns);
    expect(verdictFor(0.59, SupportLevel.medium), Verdict.uncertain);
    expect(verdictFor(0.4, SupportLevel.high), Verdict.likelyOut);
    expect(verdictFor(0.9, SupportLevel.low), Verdict.unknown);
    expect(verdictFor(null, SupportLevel.high), Verdict.unknown);
  });

  test('worst case is the maximum over the sweep and directions', () {
    final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
    addTearDown(c.dispose);
    final sweep = airflowSweep(0, 400, 24);
    final rows = assessMission(
      p,
      orbit,
      c.read(materialsProvider),
      sweep: sweep,
      directions: const ['opposed', 'concurrent'],
      defaults: c.read(defaultLabInputProvider),
    );
    expect(rows, isNotEmpty);
    for (final r in rows) {
      var best = 0.0;
      for (final d in ['opposed', 'concurrent']) {
        for (final f in sweep) {
          final v = p.sustainProbability(
            r.input.copyWith(flowMmS: f, flowDirection: d),
          )!;
          if (v > best) best = v;
        }
      }
      expect(r.worstProb, closeTo(best, 1e-12));
    }
  });

  test('wishlist picks 5 diverse candidates, deterministically', () {
    final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
    addTearDown(c.dispose);
    final defaults = c.read(defaultLabInputProvider);
    final planned = visiblePlanned(
      data.missions as MissionsFile,
      orbit.id,
      release: true,
    );
    final a = buildWishlist(
      p,
      orbit,
      c.read(materialsProvider),
      defaults,
      planned,
    )!;
    final b = buildWishlist(
      p,
      orbit,
      c.read(materialsProvider),
      defaults,
      planned,
    )!;
    expect(a.picks, hasLength(5));
    expect(
      [for (final x in a.picks) x.score],
      [for (final x in b.picks) x.score],
    );
    for (var i = 0; i < a.picks.length; i++) {
      for (var j = i + 1; j < a.picks.length; j++) {
        var s = 0.0;
        for (var k = 0; k < a.picks[i].z.length; k++) {
          s +=
              (a.picks[i].z[k] - a.picks[j].z[k]) *
              (a.picks[i].z[k] - a.picks[j].z[k]);
        }
        expect(s, greaterThanOrEqualTo(0.75 * 0.75 - 1e-12));
      }
    }
    for (final x in a.candidates) {
      expect(x.score, closeTo(0.45 * x.u + 0.45 * x.n + 0.10 * x.w, 1e-12));
    }
    // Planned point percentile equals the share of candidates scoring at least as high.
    final ps = a.planned.single;
    final expected =
        a.candidates.where((x) => x.score >= ps.score).length /
        a.candidates.length *
        100;
    expect(ps.topPercent, expected);
  });

  test('unsourced missions and planned tests are hidden in release', () {
    final f = data.missions as MissionsFile;
    expect(visibleMissions(f, release: true).map((m) => m.id), [
      'fixture_orbit',
    ]);
    expect(visibleMissions(f, release: false), hasLength(2));
    expect(visiblePlanned(f, 'fixture_orbit', release: true), hasLength(1));
  });

  test('the Fire Brief PDF builds and names the mission', () async {
    final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
    addTearDown(c.dispose);
    final bytes = await buildBrief(
      BriefContent(
        mission: orbit,
        materials: c.read(missionAssessmentProvider(orbit.id)),
        wishlist: c.read(wishlistProvider(orbit.id)),
        planned: const [],
        runsInClass: 0,
        citations: const ['FIXTURE citation'],
        reasons: List.filled(5, const ['FIXTURE reason']),
        conditions: List.filled(5, 'FIXTURE conditions'),
        url: 'https://example.test',
        date: DateTime.utc(2026, 11, 12),
      ),
      regular: ByteData.sublistView(
        File('assets/fonts/Archivo-Regular.ttf').readAsBytesSync(),
      ),
      bold: ByteData.sublistView(
        File('assets/fonts/Archivo-Bold.ttf').readAsBytesSync(),
      ),
      compress: false,
    );
    final text = String.fromCharCodes(bytes);
    expect(text.startsWith('%PDF'), isTrue);
    expect(text, contains('Mission Fire Brief: International Space Station'));
  });

  testWidgets(
    'real data: missions page shows the being-verified state in release',
    (tester) async {
      await pumpApp(tester, location: '/missions', fixtures: false);
      // Debug test builds show unsourced missions with a warning instead.
      expect(
        find.text(
          'Debug build: this mission has no source and is hidden in release.',
        ),
        findsWidgets,
      );
    },
  );

  testWidgets(
    'fixture mission detail renders table, wishlist and brief button',
    (tester) async {
      await pumpApp(tester, location: '/missions/fixture_orbit', height: 2600);
      await settle(tester, frames: 10);
      expect(find.text('Where NASA should test next'), findsOneWidget);
      expect(find.text('Download Mission Fire Brief (PDF)'), findsOneWidget);
      expect(find.textContaining('rank in the top'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unknown mission id shows not found', (tester) async {
    await pumpApp(tester, location: '/missions/nope');
    expect(find.text('This page drifted off'), findsOneWidget);
  });
}
