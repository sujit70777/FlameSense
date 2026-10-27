import 'package:flamesense/domain/providers.dart';
import 'package:flamesense/features/lab/lab_providers.dart';
import 'package:flamesense/widgets/sustain_gauge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

ProviderContainer containerOf(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(Scaffold).first));

void main() {
  for (final width in [360.0, 768.0, 1280.0, 1920.0]) {
    for (final theme in ['light', 'dark']) {
      testWidgets('lab renders at $width px ($theme) without overflow', (
        tester,
      ) async {
        await pumpApp(
          tester,
          location: '/lab',
          width: width,
          height: 3200,
          prefs: {'fs.theme': theme},
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(SustainGauge), findsOneWidget);
        expect(find.text('Conditions'), findsOneWidget);
      });
    }
  }

  testWidgets('changing oxygen changes the prediction', (tester) async {
    await pumpApp(tester, location: '/lab?o2=0.18', height: 2400);
    final c = containerOf(tester);
    final before = c.read(predictionProvider).sustainProb!;
    c
        .read(labInputProvider.notifier)
        .set(c.read(labInputProvider).copyWith(o2: 0.34));
    await tester.pump();
    expect(c.read(predictionProvider).sustainProb, isNot(before));
    expect(find.textContaining('chance the flame keeps burning'), findsWidgets);
  });

  testWidgets('outside-range notice appears beyond the tested range', (
    tester,
  ) async {
    await pumpApp(tester, location: '/lab?o2=0.48', height: 2400);
    expect(
      find.textContaining('is outside the range NASA tested'),
      findsOneWidget,
    );
  });

  testWidgets('query parameters set the conditions; partial gravity notice', (
    tester,
  ) async {
    await pumpApp(tester, location: '/lab?g=0.1652&p=70', height: 2400);
    final x = containerOf(tester).read(labInputProvider);
    expect(x.gravityG, 0.1652);
    expect(x.pressureKpa, 70);
    expect(
      find.textContaining(
        'NASA has little or no fire data at Moon or Mars gravity',
      ),
      findsOneWidget,
    );
  });

  testWidgets('compare mode shows both columns and a delta line', (
    tester,
  ) async {
    await pumpApp(tester, location: '/lab', width: 1920, height: 2400);
    await tester.tap(find.text('Compare with Earth'));
    await tester.pump();
    expect(find.text('At your gravity'), findsOneWidget);
    expect(find.text('On Earth (1 g)'), findsOneWidget);
    expect(find.byType(SustainGauge), findsNWidgets(2));
    expect(find.textContaining('on Earth'), findsWidgets);
  });

  testWidgets('copy link builds the shareable URL', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await pumpApp(tester, location: '/lab?o2=0.25&g=1e-6', height: 2400);
    await tester.tap(find.text('Copy link to this setup'));
    await tester.pump();
    final x = containerOf(tester).read(labInputProvider);
    expect(copied, labShareLink(x));
    final q = Uri.parse(copied!).queryParameters;
    expect(q['o2'], '0.25');
    expect(q['g'], '1e-6');
    expect(find.text('Link copied'), findsOneWidget);
  });

  testWidgets('numeric field rejects invalid input with a message', (
    tester,
  ) async {
    await pumpApp(tester, location: '/lab', width: 1920, height: 2400);
    final field = find.byType(TextField).first;
    await tester.enterText(field, '999');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.textContaining('Enter a number between'), findsOneWidget);
  });

  testWidgets('real (empty) data: gauge unavailable, no numbers', (
    tester,
  ) async {
    await pumpApp(tester, location: '/lab', fixtures: false, height: 2400);
    expect(find.text('Not enough data to predict this'), findsWidgets);
    expect(
      find.textContaining("There isn't enough NASA data"),
      findsNWidgets(2),
    );
    expect(
      find.text(
        'The physics check is switched off until its parameters are verified.',
      ),
      findsOneWidget,
    );
  });
}
