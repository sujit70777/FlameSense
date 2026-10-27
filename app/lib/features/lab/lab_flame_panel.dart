import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/gravity.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chamber_window.dart';
import '../../widgets/flame_twin/flame_twin.dart';
import '../../widgets/fs_chip.dart';
import '../../widgets/metric_readout.dart';
import 'lab_providers.dart';

/// Chamber window with one flame, gravity label, effective airflow and the Compare chip.
class LabFlamePanel extends ConsumerWidget {
  const LabFlamePanel({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final x = ref.watch(labInputProvider);
    final r = ref.watch(predictionProvider);
    final buoyant = r.physics.buoyantVelocityMmS;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChamberWindow(
          padding: const EdgeInsets.all(FsSpace.s5),
          child: Theme(
            // The chamber is dark in both themes.
            data: buildDarkTheme(compact: compact, bn: l.localeName == 'bn'),
            child: Builder(
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: height,
                    child: Center(
                      child: SizedBox(
                        width: 320,
                        child: FlameTwin(gravityG: x.gravityG),
                      ),
                    ),
                  ),
                  Text(
                    gravityChipLabel(x.gravityG, l, fmt),
                    style: context.text.titleMedium,
                  ),
                  const SizedBox(height: FsSpace.s2),
                  MetricReadout(
                    label: l.labEffectiveFlow,
                    value: fmt.sig(r.effectiveFlowMmS),
                    unit: l.unitMmS,
                    caption: buoyant == null
                        ? l.labEffectiveFlowForcedOnly
                        : l.labEffectiveFlowCaption(
                            fmt.sig(x.flowMmS),
                            fmt.sig(buoyant),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: FsSpace.s3),
        Align(
          alignment: Alignment.centerLeft,
          child: FsChip(
            label: l.labCompare,
            selected: ref.watch(compareModeProvider),
            onTap: ref.read(compareModeProvider.notifier).toggle,
          ),
        ),
      ],
    );
  }
}
