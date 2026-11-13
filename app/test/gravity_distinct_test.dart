import 'package:flamesense/domain/gravity.dart';
import 'package:flamesense/domain/predictor.dart';
import 'package:flamesense/domain/providers.dart';
import 'package:flamesense/features/home/hero_readout.dart';
import 'package:flamesense/features/home/home_providers.dart';
import 'package:flamesense/features/lab/lab_providers.dart';
import 'package:flamesense/features/lab/prediction_summary.dart';
import 'package:flamesense/widgets/metric_readout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fixture_data.dart';
import 'helpers/test_app.dart';

/// Rendered strings under [root] that contain a digit (the shown values).
List<String> _numbers(WidgetTester tester, Finder root) => [
  for (final t in tester.widgetList<Text>(
    find.descendant(of: root, matching: find.byType(Text)),
  ))
    if ((t.data ?? t.textSpan?.toPlainText() ?? '').contains(RegExp(r'\d')))
      t.data ?? t.textSpan!.toPlainText(),
];

/// PLAN.md §1.0: no page may show the same predicted value for 1 g and orbit (1e-6 g).
void main() {
  setUp(() => homeIgnitedThisSession = false);

  test(
    'real assets: 1 g never repeats the orbit value (null when untested)',
    () async {
      // The shipped sustain model was trained on microgravity runs only, so a
      // 1 g number would just echo the orbit one; valid_range must blank it.
      final data = await loadData(fixtures: false);
      final p = Predictor.fromData(data);
      final c = ProviderContainer(overrides: [loadedDataOverride(data)]);
      addTearDown(c.dispose);
      final x = c.read(defaultLabInputProvider);
      final orbit = p.predict(x.copyWith(gravityG: kIssG));
      final earth = p.predict(x.copyWith(gravityG: kEarthG));
      for (final (a, b) in [
        (orbit.sustainProb, earth.sustainProb),
        (orbit.spreadQ50, earth.spreadQ50),
      ]) {
        if (a != null && b != null) expect((a - b).abs(), greaterThan(1e-9));
      }
    },
  );

  testWidgets(
    'Lab compare: orbit and Earth columns never show the same prediction',
    (tester) async {
      await pumpApp(tester, location: '/lab', width: 1440, height: 2400);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(PredictionSummary).first),
      );
      final input = container.read(labInputProvider.notifier);
      input.set(container.read(labInputProvider).copyWith(gravityG: kIssG));
      container.read(compareModeProvider.notifier).toggle();
      await settle(tester);

      final orbit = container.read(predictionProvider);
      final earth = container.read(earthPredictionProvider);
      // Fixture models exist, so a missing value is a failure, not a skip.
      expect(orbit.sustainProb, isNotNull);
      expect(earth.sustainProb, isNotNull);
      expect(orbit.spreadQ50, isNotNull);
      expect(earth.spreadQ50, isNotNull);
      expect(
        (orbit.sustainProb! - earth.sustainProb!).abs(),
        greaterThan(1e-9),
      );
      expect((orbit.spreadQ50! - earth.spreadQ50!).abs(), greaterThan(1e-9));

      final summaries = find.byType(PredictionSummary);
      expect(summaries, findsNWidgets(2));
      final shownOrbit = _numbers(tester, summaries.at(0));
      final shownEarth = _numbers(tester, summaries.at(1));
      expect(shownOrbit, isNotEmpty);
      expect(
        shownOrbit,
        isNot(equals(shownEarth)),
        reason: 'the 1e-6 g and 1 g columns render identical values',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Home hero: the 1 g and orbit readouts never show the same value',
    (tester) async {
      await pumpApp(tester, height: 1600);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(HeroReadout).first),
      );
      expect(container.read(homeGravityProvider), kIssG);
      final readouts = tester
          .widgetList<HeroReadout>(find.byType(HeroReadout))
          .toList();
      expect(readouts.map((r) => r.gravityG), [kEarthG, kIssG]);
      String value(int i) => tester
          .widget<MetricReadout>(
            find.descendant(
              of: find.byType(HeroReadout).at(i),
              matching: find.byType(MetricReadout),
            ),
          )
          .value;
      // Fixture physics is signed off, so both rows exist.
      expect(value(0), isNot(equals(value(1))));
    },
  );
}
