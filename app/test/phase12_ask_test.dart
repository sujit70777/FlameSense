import 'dart:convert';

import 'package:flamesense/features/ask/ask_client.dart';
import 'package:flamesense/features/ask/ask_providers.dart';
import 'package:flamesense/widgets/citation_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'helpers/test_app.dart';

AskClient client(int status, Object body) => AskClient(
  client: MockClient((_) async => http.Response(jsonEncode(body), status)),
  endpoint: Uri.parse('http://x.test/api/ask'),
);

void main() {
  group('client error mapping', () {
    test('maps every status', () async {
      Future<AskErrorKind?> kind(int s, Object b) async {
        try {
          await client(s, b).ask('why round?', 'en');
          return null;
        } on AskError catch (e) {
          return e.kind;
        }
      }

      expect(
        await kind(400, {'error': 'invalid_question'}),
        AskErrorKind.invalid,
      );
      expect(
        await kind(429, {'error': 'rate_limited', 'retry_after_s': 120}),
        AskErrorKind.rateLimited,
      );
      expect(await kind(502, {'error': 'upstream'}), AskErrorKind.upstream);
      expect(await kind(500, {'error': 'server'}), AskErrorKind.server);
      final offline = AskClient(
        client: MockClient((_) => throw http.ClientException('down')),
        endpoint: Uri.parse('http://x.test'),
      );
      expect(
        () => offline.ask('why round?', 'en'),
        throwsA(
          isA<AskError>().having((e) => e.kind, 'kind', AskErrorKind.offline),
        ),
      );
      final ok = await client(200, {
        'answer': 'A [S1].',
        'citations': [],
        'grounded': false,
        'model': 'm',
        'cached': false,
      }).ask('q?', 'en');
      expect(ok.grounded, isFalse);
    });
  });

  testWidgets(
    'suggested question with a cached answer renders instantly with citations',
    (tester) async {
      await pumpApp(tester, location: '/ask', height: 2400);
      await tester.tap(find.text('Why are flames round in microgravity?'));
      await tester.pump();
      expect(find.text('Saved answer'), findsOneWidget);
      expect(find.text('Answered from NASA sources'), findsOneWidget);
      expect(find.text('FIXTURE source'), findsOneWidget);
      expect(find.byType(CitationChip), findsWidgets);
      await tester.tap(find.byType(CitationChip).first);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('can contain mistakes'), findsOneWidget);
    },
  );

  testWidgets('too-short question shows the invalid message under the input', (
    tester,
  ) async {
    await pumpApp(tester, location: '/ask', height: 2400);
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.tap(find.widgetWithText(InkWell, 'Ask').last);
    await tester.pump();
    expect(
      find.text('Write a question between 3 and 500 characters.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'upstream error shows the danger notice with retry; history keeps earlier answers',
    (tester) async {
      await pumpApp(tester, location: '/ask', height: 2400);
      final c = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      await tester.tap(find.text('Why are flames round in microgravity?'));
      await tester.pump();
      c.read(askControllerProvider.notifier).state = AskState(
        current: const AskTurn(
          question: 'q?',
          error: AskError(AskErrorKind.upstream),
        ),
        history: [c.read(askControllerProvider).current!],
      );
      await tester.pump();
      expect(
        find.textContaining("The answer service didn't respond"),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Earlier questions'), findsOneWidget);
    },
  );
}
