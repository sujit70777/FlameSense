import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/run_record.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/gravity_chip.dart';
import '../../widgets/unit_value.dart';
import 'explore_filters.dart';
import 'run_fields.dart';
import 'table_cells.dart';

/// Run detail body shared by the dialog and the full page (DESIGN.md §11.2).
class RunDetailContent extends ConsumerWidget {
  const RunDetailContent({super.key, required this.run});

  final RunRecord run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final rank = outcomeRank(run);
    final fields = runFields(l, fmt, run);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: FsSpace.s3,
          runSpacing: FsSpace.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GravityChip(
              gravityClass: run.gravityClass,
              label: gravityChipLabel(run.gravityG, l, fmt),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rank >= 1)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: rank == 2 ? c.ember : c.microg,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(width: FsSpace.s2),
                Text(outcomeText(l, run), style: context.text.labelLarge),
              ],
            ),
            Text(
              '${l.fieldQuality}: ${l.qualityLabel(run.qualityFlag)}',
              style: context.text.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: FsSpace.s5),
        LayoutBuilder(
          builder: (context, box) {
            final colW = box.maxWidth >= 480
                ? (box.maxWidth - FsSpace.s6) / 2
                : box.maxWidth;
            return Wrap(
              spacing: FsSpace.s6,
              runSpacing: FsSpace.s3,
              children: [
                for (final (label, value, unit) in fields)
                  SizedBox(
                    width: colW,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: context.text.bodyMedium),
                        unit.isEmpty
                            ? Text(value, style: context.text.bodyLarge)
                            : UnitValue(value: value, unit: unit),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: FsSpace.s5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FsSpace.s4),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(FsRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.runSource, style: context.text.labelLarge),
              const SizedBox(height: FsSpace.s1),
              Text(run.sourceCitation, style: context.text.bodyLarge),
              if (run.sourceUrl != null) ...[
                const SizedBox(height: FsSpace.s2),
                FsButton(
                  label: l.runOpenSource,
                  icon: Icons.open_in_new_rounded,
                  variant: FsButtonVariant.ghost,
                  size: FsButtonSize.sm,
                  semanticLabel: '${l.runOpenSource}. ${l.openInNewTab}',
                  onPressed: () => launchUrl(
                    Uri.parse(run.sourceUrl!),
                    webOnlyWindowName: '_blank',
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
