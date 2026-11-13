import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/ask_models.dart';
import 'ask_client.dart';

/// One question and its outcome (single-turn; kept in memory only).
@immutable
class AskTurn {
  const AskTurn({
    required this.question,
    this.response,
    this.error,
    this.loading = false,
  });
  final String question;
  final AskResponse? response;
  final AskError? error;
  final bool loading;
}

/// Current turn plus the last 5 earlier ones (this session only, never persisted).
@immutable
class AskState {
  const AskState({this.current, this.history = const []});
  final AskTurn? current;
  final List<AskTurn> history;
}

final askClientProvider = Provider<AskClient>((ref) => AskClient());

/// Runs questions; suggested questions with a cached answer return instantly.
class AskController extends Notifier<AskState> {
  @override
  AskState build() => const AskState();

  /// Cached answer for [question] in [lang], if it is one of the saved suggestions.
  AskResponse? cached(String question, String lang) {
    for (final e in ref.read(loadedDataProvider).askCache) {
      if (e.id.endsWith('_$lang') && (e.qEn == question || e.qBn == question)) {
        return e.answer;
      }
    }
    return null;
  }

  /// Asks [question]; errors land in the current turn.
  Future<void> ask(String question, String lang) async {
    final q = question.trim();
    final earlier = [
      if (state.current?.response != null) state.current!,
      ...state.history,
    ].take(5).toList();
    final hit = cached(q, lang);
    if (hit != null) {
      state = AskState(
        current: AskTurn(question: q, response: hit),
        history: earlier,
      );
      return;
    }
    if (q.length < 3 || q.length > 500) {
      state = AskState(
        current: AskTurn(
          question: q,
          error: const AskError(AskErrorKind.invalid),
        ),
        history: earlier,
      );
      return;
    }
    state = AskState(
      current: AskTurn(question: q, loading: true),
      history: earlier,
    );
    try {
      final r = await ref.read(askClientProvider).ask(q, lang);
      state = AskState(
        current: AskTurn(question: q, response: r),
        history: earlier,
      );
    } on AskError catch (e) {
      state = AskState(
        current: AskTurn(question: q, error: e),
        history: earlier,
      );
    }
  }

  /// Shows an earlier answer again.
  void reopen(AskTurn t) {
    final rest = [
      if (state.current?.response != null) state.current!,
      ...state.history.where((h) => h != t),
    ];
    state = AskState(current: t, history: rest.take(5).toList());
  }
}

final askControllerProvider = NotifierProvider<AskController, AskState>(
  AskController.new,
);
