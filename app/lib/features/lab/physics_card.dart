import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/physics_model.dart';
import '../../domain/predictor.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/inline_notice.dart';
import '../../widgets/metric_readout.dart';

/// "Physics check" section, status-aware (DESIGN.md §9.16).
class PhysicsCard extends ConsumerWidget {
  const PhysicsCard({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final phys = result.physics;
    final Widget body = switch (phys.status) {
      PhysicsStatus.unavailable => InlineNotice(message: l.physicsUnavailable),
      PhysicsStatus.notApplicable => InlineNotice(
        message: l.physicsNotApplicable,
      ),
      PhysicsStatus.nearExtinction || PhysicsStatus.ok => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (phys.spreadMmS != null)
            MetricReadout(
              label: l.labPhysicsPredicts,
              value: fmt.sig(phys.spreadMmS!),
              unit: l.unitMmS,
            ),
          if (phys.spreadMmS != null &&
              result.spreadQ50 != null &&
              phys.spreadMmS! > 0) ...[
            const SizedBox(height: FsSpace.s2),
            Text(
              _compare(l, fmt.integer, result.spreadQ50!, phys.spreadMmS!),
              style: context.text.bodyMedium,
            ),
          ],
          if (phys.status == PhysicsStatus.nearExtinction) ...[
            const SizedBox(height: FsSpace.s3),
            InlineNotice(
              message: l.physicsNearExt,
              variant: NoticeVariant.warn,
            ),
          ],
          FsButton(
            label: l.labPhysicsSeeEquation,
            variant: FsButtonVariant.ghost,
            size: FsButtonSize.sm,
            onPressed: () => context.go('/methods?s=physics'),
          ),
        ],
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l.labPhysicsTitle, style: context.text.titleMedium),
        ),
        const SizedBox(height: FsSpace.s3),
        body,
      ],
    );
  }

  static String _compare(
    AppLocalizations l,
    String Function(num) n,
    double ml,
    double phys,
  ) {
    final pct = (ml - phys) / phys * 100;
    return pct < 0
        ? l.labPhysicsLower(n(pct.abs()))
        : l.labPhysicsHigher(n(pct));
  }
}
