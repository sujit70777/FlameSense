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
  client: MockClient(
    (_) async => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
  ),
  endpoint: Uri.parse('http://x.test/api/ask'),
);

/// Client whose endpoint answers with the SPA's HTML (static host, no function).
AskClient htmlClient(int status) => AskClient(
  client: MockClient(
    (_) async => http.Response(
      '<!DOCTYPE html><html><body>FlameSense</body></html>',
      status,
      headers: {'content-type': 'text/html; charset=utf-8'},
    ),
  ),
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
      expect(
        await kind(429, {'error': 'upstream_busy', 'retry_after_s': 38}),
        AskErrorKind.busy,
      );
      expect(await kind(502, {'error': 'upstream'}), AskErrorKind.upstream);
      expect(await kind(500, {'error': 'server'}), AskErrorKind.server);
      for (final s in [404, 405, 503]) {
        expect(await kind(s, {'error': 'x'}), AskErrorKind.unavailable);
      }
      for (final s in [200, 404]) {
        expect(
          () => htmlClient(s).ask('why round?', 'en'),
          throwsA(
            isA<AskError>().having(
              (e) => e.kind,
              'kind',
              AskErrorKind.unavailable,
            ),
          ),
          reason: 'HTML $s',
        );
      }
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
      await tester.tap(
        find.text(
          'How is a candle flame in microgravity different from one on Earth?',
        ),
      );
      await tester.pump();
      expect(find.text('Saved answer'), findsOneWidget);
      expect(find.text('Answered from NASA sources'), findsOneWidget);
      expect(find.text('FIXTURE source'), findsOneWidget);
      expect(find.byType(CitationChip), findsWidgets);
      // Chips sit inline in the sentence; they must not stretch to the line width.
      expect(
        tester.getSize(find.byType(CitationChip).first).width,
        lessThan(80),
      );
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
      await tester.tap(
        find.text(
          'How is a candle flame in microgravity different from one on Earth?',
        ),
      );
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
