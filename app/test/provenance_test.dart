import 'dart:convert';
import 'dart:io';

import 'package:flamesense/core/format.dart';
import 'package:flamesense/data/models/app_meta.dart';
import 'package:flamesense/features/home/gap_copy.dart';
import 'package:flamesense/l10n/app_localizations_en.dart';
import 'package:flamesense/widgets/data_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

AppMeta _read(String path) => AppMeta.fromJson(
  jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
);

/// Every breakdown in app_meta must sum to n_runs (PLAN.md §1.0 "Counts").
void _expectConsistent(AppMeta m) {
  expect(m.sourceType.values.fold(0, (a, b) => a + b), m.nRuns);
  expect(m.gravityClass.values.fold(0, (a, b) => a + b), m.nRuns);
  expect(m.experimentCounts.values.fold(0, (a, b) => a + b), m.nRuns);
  expect(m.sources.fold(0, (a, s) => a + s.nRuns), m.nRuns);
  expect(
    m.sustainOnlyRuns +
        m.spreadOnlyRuns +
        m.bothModelsRuns +
        m.neitherModelRuns,
    m.nRuns,
  );
  expect(m.rowsIngested - m.rowsDropped, m.nRuns);
  expect(m.sources.fold(0, (a, s) => a + s.nDroppedDuplicates), m.rowsDropped);
}

void main() {
  test('fixture app_meta: every count breakdown sums to n_runs', () {
    final m = _read('test/fixtures/fixture_app_meta.json');
    expect(m.nRuns, greaterThan(0));
    _expectConsistent(m);
    expect(m.homeTopGaps.map((g) => g.id).toSet(), kGapIds);
  });

  test('shipped app_meta: counts are consistent and Sharma 2024 is NASA co-authored', () {
    final m = _read('assets/data/app_meta.json');
    if (m.nRuns == 0) return; // data not exported yet
    _expectConsistent(m);
    expect(m.experiments.length, m.nExperiments);
    for (final s in m.sources.where((s) => s.sourceType == 'third_party')) {
      expect(
        s.authorship,
        isIn(['nasa_coauthored', 'independent']),
        reason: s.citation,
      );
    }
    final sharma = m.sources.where((s) => s.citation.startsWith('Sharma'));
    for (final s in sharma) {
      expect(s.authorship, 'nasa_coauthored');
      expect(s.experiments.join(), contains('NASA co-authored'));
      expect(s.experiments.join(), isNot(contains('not NASA')));
    }
  });

  test('shipped Moon-base finding links to an existing mission', () {
    final m = _read('assets/data/app_meta.json');
    if (m.nRuns == 0) return;
    final missions = jsonDecode(
      File('assets/data/missions.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final ids = (missions['missions'] as List)
        .map((e) => (e as Map)['id'])
        .toSet();
    expect(ids, contains(m.homeMoonBaseMissionId));
  });

  test('gap copy is built from computed numbers, not baked-in text', () {
    final l = AppLocalizationsEn();
    final f = FsFormat('en');
    HomeTopGap gap(String id, Map<String, dynamic> p) =>
        HomeTopGap(id: id, rank: 1, score: 0.5, link: '/map', params: p);
    final hi = gapCopy(
      l,
      f,
      gap('high_o2_solids', {
        'limitPct': 23,
        'nHigh': 6,
        'nSolid': 97,
        'nHighWentOut': 0,
        'pressureMinKpa': 54.1,
        'pressureMaxKpa': 72.6,
      }),
    );
    expect(hi.$1, 'Solid fire above 23% oxygen');
    expect(hi.$2, contains('Only 6 of 97'));
    expect(hi.$2, contains('54.1–72.6 kPa'));
    final none = gapCopy(
      l,
      f,
      gap('high_o2_solids', {'limitPct': 23, 'nHigh': 0, 'nSolid': 40}),
    );
    expect(none.$2, startsWith('None of the 40'));
    final partial = gapCopy(
      l,
      f,
      gap('partial_gravity', {
        'nPartial': 26,
        'nTotal': 123,
        'nNasa': 0,
        'nThirdParty': 26,
      }),
    );
    expect(
      partial.$2,
      '26 of 123 runs are at partial gravity: 0 from NASA and 26 from third-party papers.',
    );
    expect(
      gapCopy(l, f, gap('earth_baseline', {'nEarth': 0, 'nTotal': 9})).$2,
      l.gapEarthBodyNone,
    );
    expect(gapCopy(l, f, gap('unknown', {})), ('', ''));
  });

  testWidgets('Methods shows the provenance table with counts from app_meta', (
    tester,
  ) async {
    await pumpApp(tester, location: '/methods', height: 6000);
    expect(tester.takeException(), isNull);
    final m = _read('test/fixtures/fixture_app_meta.json');
    final l = AppLocalizationsEn();
    final f = FsFormat('en');
    expect(find.byType(DataProvenance), findsOneWidget);
    expect(
      find.text(
        l.provIntro(
          f.integer(m.nRuns),
          f.integer(m.sources.length),
          f.integer(m.rowsIngested),
          f.integer(m.rowsDropped),
        ),
      ),
      findsOneWidget,
    );
    expect(find.text(l.provDownloadMaster), findsOneWidget);
    // Fixture sources are unlabelled third party: no co-authored note.
    expect(find.text(l.provNasaCoauthored), findsNothing);
  });
}
