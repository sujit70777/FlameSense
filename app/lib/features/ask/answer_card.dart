import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/inline_notice.dart';
import '../../widgets/skeleton_block.dart';
import '../../widgets/toast.dart';
import 'answer_text.dart';
import 'ask_client.dart';
import 'ask_providers.dart';
import 'source_card.dart';

/// Answer card: status line, answer with citation chips, sources, copy; waiting and error states.
class AnswerCard extends ConsumerStatefulWidget {
  const AnswerCard({
    super.key,
    required this.turn,
    required this.onRetry,
    required this.onRelated,
  });

  final AskTurn turn;
  final VoidCallback onRetry, onRelated;

  @override
  ConsumerState<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends ConsumerState<AnswerCard> {
  final _keys = <int, GlobalKey>{};
  final _pulses = <int, int>{};

  void _cite(int n) {
    final ctx = _keys[n]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : FsMotion.base,
      );
    }
    setState(() => _pulses[n] = (_pulses[n] ?? 0) + 1);
  }

  String _errorText(AppLocalizations l, AskError e) => switch (e.kind) {
    AskErrorKind.rateLimited => l.askErrRate(
      '${((e.retryAfterS ?? 60) / 60).ceil()}',
    ),
    AskErrorKind.upstream => l.askErrUpstream,
    AskErrorKind.offline => l.askErrOffline,
    AskErrorKind.invalid => l.askErrInvalid,
    AskErrorKind.server => l.askErrServer,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final t = widget.turn;
    if (t.loading) {
      return FsPanel(
        child: Semantics(
          liveRegion: true,
          label: l.askSearching,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final w in [1.0, 0.92, 0.96, 0.6])
                Padding(
                  padding: const EdgeInsets.only(bottom: FsSpace.s2),
                  child: FractionallySizedBox(
                    widthFactor: w,
                    child: const SkeletonBlock(),
                  ),
                ),
              Text(l.askSearching, style: context.text.labelSmall),
            ],
          ),
        ),
      );
    }
    if (t.error != null) {
      if (t.error!.kind == AskErrorKind.invalid) return const SizedBox.shrink();
      return InlineNotice(
        variant: NoticeVariant.danger,
        message: _errorText(l, t.error!),
        actionLabel: l.tryAgain,
        onAction: widget.onRetry,
      );
    }
    final r = t.response!;
    return FsPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: FsSpace.s3,
            runSpacing: FsSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    r.grounded
                        ? Icons.check_circle_outline_rounded
                        : Icons.info_outline_rounded,
                    size: FsSize.iconInline,
                    color: r.grounded ? c.success : c.microg,
                  ),
                  const SizedBox(width: FsSpace.s2),
                  Text(
                    r.grounded ? l.askGrounded : l.askNotGrounded,
                    style: context.text.labelLarge,
                  ),
                ],
              ),
              if (r.cached)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: FsSpace.s2,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(side: BorderSide(color: c.outline)),
                  ),
                  child: Text(l.askSaved, style: context.text.labelSmall),
                ),
            ],
          ),
          const SizedBox(height: FsSpace.s3),
          Text(t.question, style: context.text.titleMedium),
          const SizedBox(height: FsSpace.s3),
          AnswerText(response: r, onCite: _cite),
          Wrap(
            spacing: FsSpace.s2,
            children: [
              FsButton(
                label: l.askCopy,
                icon: Icons.copy_rounded,
                variant: FsButtonVariant.ghost,
                size: FsButtonSize.sm,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: r.answer));
                  if (context.mounted) showFsToast(context, l.answerCopied);
                },
              ),
              if (!r.grounded)
                FsButton(
                  label: l.askRelated,
                  variant: FsButtonVariant.secondary,
                  size: FsButtonSize.sm,
                  onPressed: widget.onRelated,
                ),
            ],
          ),
          if (r.citations.isNotEmpty) ...[
            const SizedBox(height: FsSpace.s4),
            const Divider(),
            const SizedBox(height: FsSpace.s3),
            Semantics(
              header: true,
              child: Text(l.askSources, style: context.text.titleMedium),
            ),
            const SizedBox(height: FsSpace.s2),
            for (final cit in r.citations)
              SourceCard(
                key: _keys.putIfAbsent(cit.n, GlobalKey.new),
                citation: cit,
                pulse: _pulses[cit.n] ?? 0,
              ),
          ],
        ],
      ),
    );
  }
}
