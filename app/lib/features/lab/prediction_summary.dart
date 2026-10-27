import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/predictor.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/spread_band.dart';
import '../../widgets/sustain_gauge.dart';
import 'lab_providers.dart';

/// Gauge + spread band for one prediction (one compare column).
class PredictionSummary extends ConsumerWidget {
  const PredictionSummary({
    super.key,
    required this.result,
    this.earth = false,
  });

  final PredictionResult result;
  final bool earth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final (lo, hi) = ref.watch(spreadAxisProvider);
    final r = result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SustainGauge(
            probability: r.sustainProb,
            unavailableTip: l.noticeUnavailable(l.outputSustain),
          ),
        ),
        const SizedBox(height: FsSpace.s4),
        const Divider(),
        const SizedBox(height: FsSpace.s4),
        if (r.spreadQ50 != null)
          SpreadBand(
            q10: r.spreadQ10!,
            q50: r.spreadQ50!,
            q90: r.spreadQ90!,
            axisMin: lo,
            axisMax: hi,
            earth: earth,
          )
        else ...[
          Text(l.labSpreadTitle, style: context.text.bodyMedium),
          Text(l.notAvailable, style: context.nums.lg),
          Text(l.labGaugeUnavailable, style: context.text.labelSmall),
        ],
      ],
    );
  }
}
