import 'dart:convert';
import 'dart:io';

import 'package:flamesense/data/asset_repository.dart';
import 'package:flamesense/data/models/missions_file.dart';
import 'package:flamesense/domain/gravity.dart';
import 'package:flamesense/domain/missions.dart';
import 'package:flamesense/domain/predictor.dart';
import 'package:flamesense/domain/providers.dart';
import 'package:flamesense/domain/wishlist.dart';
import 'package:flamesense/features/lab/prediction_summary.dart';
import 'package:flamesense/features/map/map_grid.dart';
import 'package:flamesense/features/missions/mission_providers.dart';
import 'package:flamesense/l10n/app_localizations_en.dart';
import 'package:flamesense/widgets/outside_tested_range.dart';
import 'package:flamesense/widgets/spread_band.dart';
import 'package:flamesense/widgets/sustain_gauge.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';
import 'helpers/test_app.dart';

/// Moon-base / rover atmospheres from the challenge statement and NASA's
/// recommendation: O₂ 0.30 and 0.34, 56.5–70.3 kPa (8.2–10.2 psi).
const _o2s = [0.30, 0.34];
const _pressures = [56.5, 60.0, 63.4, 66.9, 70.3];
const _gravities = [kIssG, kMoonG, kMarsG, kEarthG];

Mission _mission(double o2, double p, double g) => Mission(
  id: 'test_${o2}_${p}_$g',
  nameKey: 'missionLunar',
  gravityG: g,
  pressureKpa: p,
  o2: o2,
  source: 'test',
  noteKey: null,
);

/// PLAN.md §1.0 + AUDIT.md §15e: no numeric solid-model output anywhere at
/// Moon-base conditions, checked on the real shipped assets.
void main() {
  late AppData data;
  late Predictor p;
  setUpAll(() async {
    data = await loadData(fixtures: false);
    p = Predictor.fromData(data);
  });

  test('shipped feature_spec has a valid range that excludes 0.30-0.34 O2', () {
    final r = data.featureSpec.validRange;
    expect(r, isNotNull, reason: 'no valid_range: every prediction is null');
    expect(r!.o2.$2, lessThan(0.30));
    expect(r.pressureKpa.$1, greaterThan(70.3));
  });

  test(
    'predictor: null sustain and spread, outside warning, at every point',
    () {
      final base = data.featureSpec;
      final defaults = p.spec.input('flow_velocity_mm_s');
      final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
      addTearDown(c.dispose);
      final start = c.read(defaultLabInputProvider);
      var checked = 0;
      for (final o2 in _o2s) {
        for (final kpa in _pressures) {
          for (final g in _gravities) {
            for (final flow in [defaults.min, 22.0, 100.0, 200.0, 470.0]) {
              for (final fc in base.sustain.groups['fuel_class']!.options) {
                final x = start.copyWith(
                  o2: o2,
                  pressureKpa: kpa,
                  gravityG: g,
                  flowMmS: flow,
                  fuelClass: fc,
                );
                expect(p.sustainProbability(x), isNull);
                expect(p.spread(x), isNull);
                final r = p.predict(x);
                expect(r.outsideTested, isTrue);
                expect([
                  r.sustainProb,
                  r.spreadQ10,
                  r.spreadQ50,
                  r.spreadQ90,
                ], everyElement(isNull));
                checked++;
              }
            }
          }
        }
      }
      expect(checked, greaterThan(0));
    },
  );

  test('map: every cell at 56.5-70.3 kPa is blank and hatched', () {
    clearMapMemo();
    for (final kpa in _pressures) {
      for (final g in [kIssG, kMoonG]) {
        final grid = computeMapGrid(
          p,
          data.featureSpec,
          MapKey(
            fuelClass: 'thin_solid',
            thicknessMm: 0.1,
            densityKgM3: 500,
            pressureKpa: kpa,
            gravityG: g,
            flowDirection: 'opposed',
          ),
        )!;
        expect(grid.prob.every((v) => v.isNaN), isTrue);
        expect(grid.lowSupport.every((b) => b), isTrue);
      }
    }
  });

  test(
    'missions and wishlist: outside verdicts, no probabilities, no scores',
    () {
      final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
      addTearDown(c.dispose);
      final mats = c.read(materialsProvider);
      final defaults = c.read(defaultLabInputProvider);
      expect(mats, isNotEmpty);
      for (final o2 in _o2s) {
        for (final kpa in [56.5, 70.3]) {
          for (final g in [kIssG, kMoonG]) {
            final m = _mission(o2, kpa, g);
            final rows = assessMission(
              p,
              m,
              mats,
              sweep: c.read(airflowSweepProvider),
              directions: const ['opposed', 'concurrent'],
              defaults: defaults,
            );
            expect(
              rows.map((r) => r.verdict),
              everyElement(Verdict.outsideRange),
            );
            expect(rows.map((r) => r.worstProb), everyElement(isNull));
            expect(rows.map((r) => r.worstFlowMmS), everyElement(isNull));
            final w = buildWishlist(p, m, mats, defaults, const [])!;
            expect(w.picks, isEmpty);
            expect(w.candidates, isEmpty);
          }
        }
      }
      // The shipped Moon/Mars missions too (statement-type atmospheres).
      final shipped = data.missions.missions.where(usesStatementAtmosphere);
      expect(shipped, isNotEmpty);
      for (final m in shipped) {
        final rows = c.read(missionAssessmentProvider(m.id));
        expect(rows.map((r) => r.verdict), everyElement(Verdict.outsideRange));
        for (final e in c.read(wishlistProvider(m.id))?.planned ?? const []) {
          expect(e.score, isNull);
        }
      }
    },
  );

  test('Home finding uses the same range: every material outside', () {
    final meta = jsonDecode(
      File('assets/data/app_meta.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final home = meta['home'] as Map<String, dynamic>;
    final moon = home['moonBase'] as Map<String, dynamic>;
    final r = data.featureSpec.validRange!;
    final inside = r.contains(
      o2: (moon['o2_mole_fraction'] as num).toDouble(),
      pressureKpa: (moon['pressure_kpa'] as num).toDouble(),
      flowMmS: r.flowMmS.$1,
      gravityG: (moon['gravity_g'] as num).toDouble(),
    );
    expect(inside, isFalse);
    expect(home['materialsOutsideMoonBase'], home['materialsTotal']);
    expect(moon['outsideInputs'], isNotEmpty);
  });

  for (final (o2, kpa) in [
    (0.30, 56.5),
    (0.30, 70.3),
    (0.34, 56.5),
    (0.34, 70.3),
  ]) {
    testWidgets('Lab at $o2 O2, $kpa kPa shows no number', (tester) async {
      await pumpApp(
        tester,
        location: '/lab?o2=$o2&p=$kpa',
        fixtures: false,
        width: 1440,
        height: 2400,
      );
      expect(find.byType(PredictionSummary), findsWidgets);
      expect(find.byType(SustainGauge), findsNothing);
      expect(find.byType(SpreadBand), findsNothing);
      expect(find.byType(OutsideTestedRange), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Moon-base mission page: no probabilities, cited atmosphere', (
    tester,
  ) async {
    final l = AppLocalizationsEn();
    await pumpApp(
      tester,
      location: '/missions/artemis_lunar',
      fixtures: false,
      width: 1440,
      height: 3200,
    );
    await settle(tester, frames: 10);
    final texts = [
      for (final t in tester.widgetList<Text>(find.byType(Text)))
        t.data ?? t.textSpan?.toPlainText() ?? '',
    ];
    // No "NN%" probability cell and no wishlist rank anywhere on the page.
    expect(texts.where((t) => RegExp(r'^\d+%$').hasMatch(t)), isEmpty);
    expect(texts.where((t) => t.contains('rank in the top')), isEmpty);
    expect(find.text(l.verdictOutside), findsWidgets);
    expect(find.text(l.wishlistOutside), findsOneWidget);
    expect(find.text(l.missionStatementCite), findsOneWidget);
    expect(
      texts.where((t) => t.contains('NASA recommendation (NTRS 20240003211)')),
      hasLength(1),
    );
    expect(texts.where((t) => t.contains('NASA plans')), isEmpty);
    expect(tester.takeException(), isNull);
  });

  test('no "NASA plans" wording in any English copy', () {
    final en = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final e in en.entries.where((e) => !e.key.startsWith('@'))) {
      expect(
        (e.value as String).toLowerCase(),
        isNot(contains('nasa plans')),
        reason: e.key,
      );
    }
  });
}
