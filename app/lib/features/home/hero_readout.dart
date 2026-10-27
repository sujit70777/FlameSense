import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/gravity.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/metric_readout.dart';

/// Gravity label + buoyant airflow (+ predicted spread) under one hero flame.
class HeroReadout extends ConsumerWidget {
  const HeroReadout({super.key, required this.gravityG, this.alignEnd = false});

  final double gravityG;
  final bool alignEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final predictor = ref.watch(predictorProvider);
    final buoyant = predictor.physics.buoyantVelocityMmS(gravityG);
    final spread = predictor.spread(
      ref.watch(defaultLabInputProvider).copyWith(gravityG: gravityG),
    );
    final align = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          gravityChipLabel(gravityG, l, fmt),
          style: context.text.titleMedium,
          textAlign: alignEnd ? TextAlign.end : null,
        ),
        if (buoyant != null) ...[
          const SizedBox(height: FsSpace.s2),
          MetricReadout(
            label: l.homeBuoyantFlow,
            value: fmt.sig(buoyant),
            unit: l.unitMmS,
          ),
        ],
        if (spread != null) ...[
          const SizedBox(height: FsSpace.s2),
          MetricReadout(
            label: l.homePredictedSpread,
            value: fmt.sig(spread.$2),
            unit: l.unitMmS,
          ),
        ],
      ],
    );
  }
}
