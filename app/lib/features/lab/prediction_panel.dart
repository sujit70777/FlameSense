import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/predictor.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/data_support_badge.dart';
import '../../widgets/fs_panel.dart';
import 'lab_notices.dart';
import 'lab_providers.dart';
import 'physics_card.dart';
import 'prediction_summary.dart';
import 'sensitivity_list.dart';

/// Prediction panel: badge, gauge, spread, physics, sensitivity, notices; Compare mode (DESIGN.md §11.3).
class PredictionPanel extends ConsumerWidget {
  const PredictionPanel({super.key, this.gaugeKey});

  /// Attached to the gauge so the compact sticky bar knows when it scrolls away.
  final Key? gaugeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final r = ref.watch(predictionProvider);
    final compare = ref.watch(compareModeProvider);
    final available = r.sustainProb != null || r.spreadQ50 != null;
    Widget body;
    if (!compare) {
      body = KeyedSubtree(
        key: gaugeKey,
        child: PredictionSummary(result: r),
      );
    } else {
      final e = ref.watch(earthPredictionProvider);
      final yours = _column(
        context,
        l.labCompareYourG,
        PredictionSummary(result: r),
        null,
      );
      final earth = _column(
        context,
        l.labCompareEarth,
        PredictionSummary(result: e, earth: true),
        context.fs.emberTint,
      );
      body = Column(
        key: gaugeKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Delta(you: r, earth: e),
          const SizedBox(height: FsSpace.s4),
          LayoutBuilder(
            // Side by side when the panel is wide enough, otherwise stacked.
            builder: (context, box) => box.maxWidth >= 560
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: yours),
                        const SizedBox(width: FsSpace.s4),
                        Expanded(child: earth),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      yours,
                      const SizedBox(height: FsSpace.s4),
                      earth,
                    ],
                  ),
          ),
        ],
      );
    }
    return FsPanel(
      title: l.labPrediction,
      actions: [if (available) DataSupportBadge(level: r.support.level)],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          body,
          const SizedBox(height: FsSpace.s4),
          const Divider(),
          const SizedBox(height: FsSpace.s4),
          PhysicsCard(result: r),
          const SizedBox(height: FsSpace.s4),
          const Divider(),
          const SizedBox(height: FsSpace.s4),
          const SensitivityList(),
          const SizedBox(height: FsSpace.s4),
          LabNotices(result: r),
        ],
      ),
    );
  }

  Widget _column(
    BuildContext context,
    String title,
    Widget child,
    Color? tint,
  ) => Container(
    padding: const EdgeInsets.all(FsSpace.s4),
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(FsRadius.md),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.text.titleMedium),
        const SizedBox(height: FsSpace.s3),
        child,
      ],
    ),
  );
}

/// "{x} points more likely to keep burning on Earth", "×{ratio} faster on Earth".
class _Delta extends ConsumerWidget {
  const _Delta({required this.you, required this.earth});

  final PredictionResult you, earth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final lines = <String>[];
    if (you.sustainProb != null && earth.sustainProb != null) {
      final d = ((earth.sustainProb! - you.sustainProb!) * 100).round();
      lines.add(
        d == 0
            ? l.labDeltaSame
            : (d > 0
                  ? l.labDeltaMore(f.integer(d))
                  : l.labDeltaLess(f.integer(-d))),
      );
    }
    if (you.spreadQ50 != null &&
        earth.spreadQ50 != null &&
        you.spreadQ50! > 0 &&
        earth.spreadQ50! > 0) {
      final ratio = earth.spreadQ50! / you.spreadQ50!;
      lines.add(
        ratio >= 1
            ? l.labDeltaFaster(f.sig(ratio, digits: 2))
            : l.labDeltaSlower(f.sig(1 / ratio, digits: 2)),
      );
    }
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final t in lines) Text(t, style: context.text.labelLarge),
        ],
      ),
    );
  }
}
