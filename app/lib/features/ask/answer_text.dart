import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/ask_models.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/citation_chip.dart';

/// Answer paragraphs and "- " bullets with [Sn] markers rendered as CitationChips.
class AnswerText extends StatelessWidget {
  const AnswerText({super.key, required this.response, required this.onCite});

  final AskResponse response;
  final ValueChanged<int> onCite;

  List<InlineSpan> _spans(BuildContext context, String line) {
    final l = AppLocalizations.of(context);
    final byN = {for (final c in response.citations) c.n: c};
    final out = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'\[S(\d+)\]').allMatches(line)) {
      if (m.start > last) {
        out.add(TextSpan(text: line.substring(last, m.start)));
      }
      final n = int.parse(m[1]!);
      final c = byN[n];
      if (c != null) {
        out.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CitationChip(
                n: n,
                tooltip: l.askCitationTip(c.title, '${c.page ?? ''}'),
                onTap: () => onCite(n),
              ),
            ),
          ),
        );
      }
      last = m.end;
    }
    if (last < line.length) out.add(TextSpan(text: line.substring(last)));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodyLarge;
    final blocks = response.answer.split(RegExp(r'\n\s*\n'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: FsSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line
                    in block.split('\n').where((s) => s.trim().isNotEmpty))
                  line.trimLeft().startsWith('- ')
                      ? Padding(
                          padding: const EdgeInsets.only(
                            left: FsSpace.s2,
                            bottom: FsSpace.s1,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•  ', style: style),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: style,
                                    children: _spans(
                                      context,
                                      line.trimLeft().substring(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Text.rich(
                          TextSpan(
                            style: style,
                            children: _spans(context, line),
                          ),
                        ),
              ],
            ),
          ),
      ],
    );
  }
}
