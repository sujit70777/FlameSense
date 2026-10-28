import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';

/// "How predictions work" (DESIGN.md §11.7 #predictions).
class MethodsPredictions extends ConsumerWidget {
  const MethodsPredictions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final spec = ref.watch(loadedDataProvider).featureSpec;
    final features = {
      for (final t in [spec.sustain, spec.spread])
        for (final f in t.features) f.name,
    };
    // Only claim the oxygen constraint when the exported model actually carries it (Q-2).
    final constrained = spec.sustain.features.any(
      (f) => f.name == 'o2_mole_fraction' && f.monotone == 1,
    );
    final body = context.text.bodyLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.methodsPredBody, style: body),
        const SizedBox(height: FsSpace.s3),
        Text(l.methodsTwoModels, style: body),
        const SizedBox(height: FsSpace.s3),
        Text(
          constrained ? l.methodsOxygenConstraint : l.methodsOxygenPending,
          style: body,
        ),
        const SizedBox(height: FsSpace.s4),
        Text(l.methodsFeatures, style: context.text.titleMedium),
        const SizedBox(height: FsSpace.s2),
        if (features.isEmpty)
          Text(
            l.methodsTaskUnavailable(spec.sustain.reason ?? ''),
            style: context.text.bodyMedium,
          )
        else
          for (final f in features)
            Text('•  ${l.featureLabel(f)}', style: context.text.bodyMedium),
      ],
    );
  }
}
