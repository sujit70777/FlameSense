import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/gravity.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/metric_readout.dart';

/// Gravity label + buoyant airflow under one hero flame (DESIGN.md §11.1).
/// The predicted spread readout is intentionally absent (PLAN.md §1.0).
class HeroReadout extends ConsumerWidget {
  const HeroReadout({super.key, required this.gravityG, this.alignEnd = false});

  final double gravityG;
  final bool alignEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final predictor = ref.watch(predictorProvider);
    // DESIGN §11.1: shown only when physics_params is signed off by the lead,
    // in every build mode (PhysicsModel alone relaxes sign-off in debug).
    final physics = predictor.physics;
    final buoyant = physics.params.signedOffByLead
        ? physics.buoyantVelocityMmS(gravityG)
        : null;
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
      ],
    );
  }
}
