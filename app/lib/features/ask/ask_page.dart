import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';
import 'answer_card.dart';
import 'ask_client.dart';
import 'ask_input.dart';
import 'ask_providers.dart';
import 'suggested_questions.dart';

/// Ask the NASA papers (DESIGN.md §11.5, F5). History lives in memory for this session only.
class AskPage extends ConsumerWidget {
  const AskPage({super.key, this.firstQuestionKey});

  final Key? firstQuestionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = ref.watch(settingsProvider).locale;
    final state = ref.watch(askControllerProvider);
    final ctl = ref.read(askControllerProvider.notifier);
    final cur = state.current;
    void ask(String q) => ctl.ask(q, lang);
    String related() {
      final qs = suggestedQuestions(l);
      final asked = {cur?.question, ...state.history.map((h) => h.question)};
      return qs.firstWhere((q) => !asked.contains(q), orElse: () => qs.first);
    }

    return FsPage(
      title: l.askTitle,
      description: l.askDesc,
      maxWidth: 760,
      children: [
        Semantics(
          header: true,
          child: Text(l.askSuggested, style: context.text.titleMedium),
        ),
        const SizedBox(height: FsSpace.s3),
        SuggestedQuestions(onPick: ask, firstKey: firstQuestionKey),
        const SizedBox(height: FsSpace.s6),
        AskInput(
          onSubmit: ask,
          busy: cur?.loading ?? false,
          invalid: cur?.error?.kind == AskErrorKind.invalid,
        ),
        const SizedBox(height: FsSpace.s6),
        if (cur != null)
          AnswerCard(
            key: ValueKey(cur),
            turn: cur,
            onRetry: () => ask(cur.question),
            onRelated: () => ask(related()),
          ),
        if (state.history.isNotEmpty) ...[
          const SizedBox(height: FsSpace.s6),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l.askEarlier, style: context.text.titleMedium),
            children: [
              for (final h in state.history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(h.question, style: context.text.labelLarge),
                  onTap: () => ctl.reopen(h),
                ),
            ],
          ),
        ],
        const SizedBox(height: FsSpace.s6),
        Text(l.askFootnote, style: context.text.labelSmall),
      ],
    );
  }
}
