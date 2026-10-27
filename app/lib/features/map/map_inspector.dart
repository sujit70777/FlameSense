import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/data_support_badge.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/unit_value.dart';
import '../lab/lab_providers.dart';
import 'map_grid.dart';

/// Cell inspector: oxygen, airflow, probability, support and "Open in Fire Lab" (DESIGN.md §11.4).
class MapInspector extends ConsumerWidget {
  const MapInspector({
    super.key,
    required this.grid,
    required this.cell,
    required this.pinned,
  });

  final MapGrid? grid;
  final (int, int)? cell;
  final bool pinned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final g = grid, c = cell;
    if (g == null || c == null) {
      return Text(
        FsWidth.of(context).hasRail
            ? l.mapInspectorHint
            : l.mapInspectorTapHint,
        style: context.text.bodyMedium,
      );
    }
    final x = g.inputAt(c.$1, c.$2);
    final support = ref.watch(predictorProvider).support(x).level;
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pinned) Text(l.mapPinned, style: context.text.labelSmall),
          Row(
            children: [
              Text('${l.featO2} ', style: context.text.bodyMedium),
              UnitValue(value: fmt.sig(x.o2 * 100), unit: l.unitPercent),
            ],
          ),
          Row(
            children: [
              Text('${l.featFlow} ', style: context.text.bodyMedium),
              UnitValue(value: fmt.sig(x.flowMmS), unit: l.unitMmS),
            ],
          ),
          const SizedBox(height: FsSpace.s2),
          Text(
            l.mapCellProb(fmt.percentPoints(g.at(c.$1, c.$2))),
            style: context.nums.md,
          ),
          const SizedBox(height: FsSpace.s2),
          DataSupportBadge(level: support),
          const SizedBox(height: FsSpace.s3),
          FsButton(
            label: l.mapOpenLab,
            variant: FsButtonVariant.secondary,
            size: FsButtonSize.sm,
            onPressed: () => context.go(labPath(x)),
          ),
        ],
      ),
    );
  }
}
