import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import 'simple_table.dart';

/// Support, limitations, usability and honesty sections (DESIGN.md §11.7 #support–#honesty).
class MethodsMore extends ConsumerWidget {
  const MethodsMore({super.key, required this.section});

  /// One of: support, limitations, usability, honesty.
  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final d = ref.watch(loadedDataProvider);
    final body = context.text.bodyLarge;
    List<Widget> bullets(List<String> items) => [
      for (final i in items)
        Padding(
          padding: const EdgeInsets.only(bottom: FsSpace.s2),
          child: Text('•  $i', style: body),
        ),
    ];
    final children = switch (section) {
      'support' => [Text(l.methodsSupportBody, style: body)],
      'limitations' => bullets([
        l.limit1(f.integer(d.meta.nRuns)),
        l.limit2,
        l.limit3,
        l.limit4,
        l.limit5,
      ]),
      'usability' =>
        d.usability.tasks.isEmpty
            ? [Text(l.methodsUsabilityPending, style: body)]
            : [
                Text(
                  l.methodsUsabilityIntro(f.integer(d.usability.testers)),
                  style: body,
                ),
                const SizedBox(height: FsSpace.s3),
                SimpleTable(
                  headers: [l.colTask, l.colCompleted, l.colMedianTime],
                  flex: const [3, 1, 1],
                  rows: [
                    for (final t in d.usability.tasks)
                      [
                        SimpleTable.t(
                          context,
                          l.localeName == 'bn' ? t.bn : t.en,
                        ),
                        SimpleTable.t(
                          context,
                          l.usabilityCompleted(
                            f.integer(t.completed),
                            f.integer(t.total),
                          ),
                          num: true,
                        ),
                        SimpleTable.t(
                          context,
                          l.usabilityTime(f.integer(t.medianSeconds)),
                          num: true,
                        ),
                      ],
                  ],
                ),
                if (d.usability.change.isNotEmpty) ...[
                  const SizedBox(height: FsSpace.s3),
                  Text(d.usability.change, style: body),
                ],
              ],
      _ => bullets([l.honesty1, l.honesty2, l.honesty3]),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
