import 'dart:convert';

import 'package:flamesense/core/platform/browser.dart';
import 'package:flamesense/data/models/run_record.dart';
import 'package:flamesense/domain/gravity.dart';
import 'package:flamesense/features/explore/explore_filters.dart';
import 'package:flamesense/features/explore/run_to_lab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/fixture_data.dart';
import 'helpers/test_app.dart';

RunRecord run(Map<String, Object?> v) => RunRecord({
  'run_id': 'fixture:x',
  'experiment': 'A',
  'platform': 'iss',
  'gravity_g': 1e-6,
  'fuel_name': 'f',
  'fuel_class': 'thin_solid',
  'o2_mole_fraction': 0.21,
  'pressure_kpa': 101.3,
  'quality_flag': 'ok',
  'source_citation': 'FIXTURE',
  ...v,
});

void main() {
  group('filters (pure)', () {
    final runs = [
      run({'run_id': 'a', 'experiment': 'A', 'o2_mole_fraction': 0.18}),
      run({
        'run_id': 'b',
        'experiment': 'B',
        'platform': 'ground',
        'gravity_g': 1.0,
        'o2_mole_fraction': 0.30,
      }),
      run({'run_id': 'c', 'experiment': 'A', 'quality_flag': 'suspect'}),
      run({
        'run_id': 'd',
        'experiment': 'C',
        'quality_flag': 'digitized',
        'fuel_class': 'thick_solid',
      }),
    ];

    test('defaults hide flagged runs only', () {
      expect(ExploreFilters.none.apply(runs).map((r) => r.runId), [
        'a',
        'b',
        'd',
      ]);
      expect(
        ExploreFilters.none.copyWith(includeFlagged: true).apply(runs),
        hasLength(4),
      );
      expect(
        ExploreFilters.none
            .copyWith(includeDigitized: false)
            .apply(runs)
            .map((r) => r.runId),
        ['a', 'b'],
      );
    });

    test('experiment, gravity, fuel and range filters combine', () {
      final f = ExploreFilters.none;
      expect(f.copyWith(experiments: {'A'}).apply(runs).map((r) => r.runId), [
        'a',
      ]);
      expect(
        f
            .copyWith(gravity: () => GravityClass.earth)
            .apply(runs)
            .map((r) => r.runId),
        ['b'],
      );
      expect(
        f
            .copyWith(fuelClass: () => 'thick_solid')
            .apply(runs)
            .map((r) => r.runId),
        ['d'],
      );
      expect(f.copyWith(o2: (0.2, 0.25)).apply(runs).map((r) => r.runId), [
        'd',
      ]);
      expect(
        f.copyWith(experiments: {'A'}, o2: (0.25, 0.4)).apply(runs),
        isEmpty,
      );
      expect(f.copyWith(experiments: {'A'}).activeCount, 1);
    });

    test('sort puts missing values last in both directions', () {
      final rs = [
        run({'run_id': 'x'}),
        run({'run_id': 'y', 'flame_spread_rate_mm_s': 2.0}),
        run({'run_id': 'z', 'flame_spread_rate_mm_s': 1.0}),
      ];
      expect(sortRuns(rs, RunColumn.spread).map((r) => r.runId), [
        'z',
        'y',
        'x',
      ]);
      expect(
        sortRuns(rs, RunColumn.spread, ascending: false).map((r) => r.runId),
        ['y', 'z', 'x'],
      );
    });

    test('CSV escapes, keeps source_citation and round-trips values', () {
      final r = run({
        'run_id': 'q',
        'source_citation': 'NASA, "BASS" run 3',
        'notes': 'a\nb',
      });
      final csv = runsToCsv(
        ['run_id', 'o2_mole_fraction', 'source_citation', 'notes'],
        [r],
      );
      final lines = const LineSplitter().convert(csv);
      expect(lines.first, 'run_id,o2_mole_fraction,source_citation,notes');
      expect(csv, contains('"NASA, ""BASS"" run 3"'));
      expect(csv, contains('0.21'));
      expect(
        csvFileName(DateTime(2026, 11, 3)),
        'flamesense_runs_20261103.csv',
      );
    });

    test('filtering 5,000 runs takes under 100 ms', () {
      final many = [
        for (var i = 0; i < 5000; i++)
          run({'run_id': '$i', 'o2_mole_fraction': 0.15 + (i % 25) / 100}),
      ];
      final sw = Stopwatch()..start();
      ExploreFilters.none
          .copyWith(o2: (0.2, 0.3), experiments: {'A'})
          .apply(many);
      expect(sw.elapsedMilliseconds, lessThan(100));
    });

    test('Load in Lab link carries the run conditions', () {
      final link = labLinkForRun(
        run({
          'run_id': 'a',
          'flow_velocity_mm_s': 50.0,
          'flow_direction': 'opposed',
        }),
      );
      final q = Uri.parse(link).queryParameters;
      expect(Uri.parse(link).path, '/lab');
      expect(q['o2'], '0.21');
      expect(q['flow'], '50');
      expect(q['g'], '1e-6');
      expect(q['dir'], 'opposed');
    });
  });

  testWidgets('empty dataset shows the no-data state, not the filter state', (
    tester,
  ) async {
    await pumpApp(tester, location: '/explore', fixtures: false);
    expect(find.text('No NASA runs loaded yet'), findsOneWidget);
    expect(find.text('No runs match these filters'), findsNothing);
  });

  testWidgets('fixture data: count, charts, table, and empty-filter state', (
    tester,
  ) async {
    await pumpApp(tester, location: '/explore', height: 2000);
    expect(find.text('Showing 160 of 160 runs'), findsOneWidget);
    expect(find.text('Spread vs oxygen'), findsOneWidget);
    expect(find.text('Run'), findsWidgets);
    await tester.tap(find.text('Oxygen range'));
    await settle(tester, frames: 6);
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Close').last);
    await settle(tester, frames: 6);
    expect(tester.takeException(), isNull);
  });

  testWidgets('run detail opens as a dialog with source and Load in Lab', (
    tester,
  ) async {
    final data = (await tester.runAsync(loadData))!;
    final id = data.runs.records.first.runId;
    await pumpApp(
      tester,
      location: '/explore/run/${Uri.encodeComponent(id)}',
      height: 1200,
    );
    expect(find.text('Run $id'), findsOneWidget);
    expect(
      find.text('FIXTURE: synthetic test row, not NASA data'),
      findsOneWidget,
    );
    await tester.tap(find.text('Load these conditions in the Fire Lab'));
    await settle(tester, frames: 8);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    expect(router.state.uri.path, '/lab');
  });

  testWidgets('unknown run id shows not found', (tester) async {
    await pumpApp(tester, location: '/explore/run/does-not-exist');
    expect(find.text('This page drifted off'), findsOneWidget);
  });

  testWidgets('Download CSV produces a file with every column', (tester) async {
    debugDownloads.clear();
    await pumpApp(tester, location: '/explore', height: 2000);
    await tester.tap(find.text('Download CSV'));
    await tester.pump();
    expect(debugDownloads, hasLength(1));
    final text = utf8.decode(debugDownloads.single.bytes);
    expect(debugDownloads.single.name, startsWith('flamesense_runs_'));
    expect(text, contains('source_citation'));
    expect(const LineSplitter().convert(text.trim()), hasLength(161));
  });
}
