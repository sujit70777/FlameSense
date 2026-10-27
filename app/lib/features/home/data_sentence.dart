import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';

/// "Built on N test runs from M NASA experiments across K materials." with the
/// numbers in numSm weight 600, from app_meta.json (DESIGN.md §11.1).
class DataSentence extends ConsumerWidget {
  const DataSentence({super.key});

  static const _mark = '\u0001';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final meta = ref.watch(loadedDataProvider).meta;
    final fmt = ref.watch(formatProvider);
    final body = context.text.bodyLarge!;
    if (meta.nRuns == 0) {
      return Text(l.homeDataPending, style: body); // TODO(Q-5)
    }
    String n(int v) => '$_mark${fmt.integer(v)}$_mark';
    final parts = l
        .homeDataSentence(n(meta.nRuns), n(meta.nExperiments), n(meta.nFuels))
        .split(_mark);
    final num = context.nums.sm.copyWith(
      fontSize: body.fontSize,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        style: body,
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(text: parts[i], style: i.isOdd ? num : null),
        ],
      ),
    );
  }
}
