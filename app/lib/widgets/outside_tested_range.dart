import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/format.dart';
import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../data/models/feature_spec.dart';
import '../l10n/app_localizations.dart';

/// "oxygen 16.9–22.1%, pressure 100–101 kPa, …" from the exported valid range.
String outsideTestedBody(AppLocalizations l, FsFormat f, ValidRange? r) {
  if (r == null) return l.outsideTestedTitle;
  String range((double, double) v, String Function(double) fmt) =>
      v.$1 == v.$2 ? fmt(v.$1) : l.rangeValues(fmt(v.$1), fmt(v.$2));
  return l.outsideTestedBody(
    range(r.o2, (v) => f.sig(v * 100)),
    range(r.pressureKpa, f.sig),
    range(r.flowMmS, f.sig),
    range(r.gravityG, f.gravity),
  );
}

/// Title + range shown instead of any solid-model number (PLAN.md §1.0, AUDIT §15e).
class OutsideTestedRange extends ConsumerWidget {
  const OutsideTestedRange({super.key, this.compact = false});

  /// Smaller title for inspectors and narrow columns.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final range = ref.watch(loadedDataProvider).featureSpec.validRange;
    final body = outsideTestedBody(l, f, range);
    return Semantics(
      label: '${l.outsideTestedTitle}. $body',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.outsideTestedTitle,
            style:
                (compact ? context.text.labelLarge : context.text.titleMedium)!
                    .copyWith(color: context.fs.warn),
          ),
          const SizedBox(height: FsSpace.s1),
          Text(body, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}
