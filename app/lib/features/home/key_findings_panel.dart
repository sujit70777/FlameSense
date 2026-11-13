import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/features.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/app_meta.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/focus_ring.dart';
import '../../widgets/metric_readout.dart';
import '../../widgets/section_header.dart';
import 'gap_copy.dart';

/// "Key findings & gaps" panel directly under the Home hero (DESIGN.md §11.1b).
///
/// All numbers are read from ``app_meta.json`` (computed at export); nothing
/// is typed by hand.
class KeyFindingsPanel extends ConsumerWidget {
  const KeyFindingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final meta = ref.watch(loadedDataProvider).meta;
    final f = ref.watch(formatProvider);
    if (meta.nRuns == 0) {
      return const SizedBox.shrink();
    }
    // DESIGN §11.1b: one readout per finding, then its one-sentence explanation.
    final findings = [
      _Finding(
        number: l.homeKeyFindingsOxygen(
          f.integer(meta.homeMaxO2MicrogravitySolidsPct),
        ),
        explanation: l.homeKeyFindingsOxygenDesc,
        link: '/map',
      ),
      _Finding(
        number: l.homeKeyFindingsMapCells(
          f.integer(meta.homeMapLowCells),
          f.integer(meta.homeMapTotalCells),
        ),
        explanation: l.homeKeyFindingsMapCellsDesc,
        link: '/map',
      ),
      _Finding(
        number: l.homeKeyFindingsMaterials(
          f.integer(meta.homeMaterialsOutsideMoonBase),
          f.integer(meta.homeMaterialsTotal),
        ),
        explanation: l.homeKeyFindingsMaterialsDesc,
        link: meta.homeMoonBaseMissionId.isEmpty
            ? '/missions'
            : '/missions/${meta.homeMoonBaseMissionId}',
      ),
    ];
    final gaps = meta.homeTopGaps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l.homeKeyFindingsTitle),
        const SizedBox(height: FsSpace.s5),
        if (!FsWidth.of(context).hasRail) ...[
          for (final f in findings) ...[
            _FindingCard(f: f),
            const SizedBox(height: FsSpace.s4),
          ],
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < findings.length; i++) ...[
                if (i > 0) const SizedBox(width: FsSpace.s4),
                Expanded(child: _FindingCard(f: findings[i])),
              ],
            ],
          ),
        const SizedBox(height: FsSpace.s6),
        _BiggestGaps(gaps: gaps, l: l),
        const SizedBox(height: FsSpace.s4),
        Text(
          l.homeKeyFindingsCaption,
          style: context.text.labelSmall!.copyWith(
            color: context.fs.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _Finding {
  const _Finding({
    required this.number,
    required this.explanation,
    required this.link,
  });
  final String number, explanation, link;
}

class _FindingCard extends ConsumerWidget {
  const _FindingCard({required this.f});

  final _Finding f;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return FsFocusRing(
      radius: FsRadius.md,
      child: Container(
        decoration: BoxDecoration(
          color: context.fs.surface2,
          border: Border.all(color: context.fs.outline),
          borderRadius: BorderRadius.circular(FsRadius.md),
        ),
        padding: const EdgeInsets.all(FsSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            MetricReadout(
              label: '',
              value: f.number,
              unit: '',
              semanticLabel: '${f.number}. ${f.explanation}',
              size: FsWidth.of(context).isLargeUp
                  ? ReadoutSize.hero
                  : ReadoutSize.lg,
            ),
            const SizedBox(height: FsSpace.s3),
            Text(
              f.explanation,
              style: context.text.bodyMedium!.copyWith(
                color: context.fs.textSecondary,
              ),
            ),
            const SizedBox(height: FsSpace.s3),
            if (ref.watch(featuresProvider).allowsLocation(f.link))
              Align(
                alignment: Alignment.centerRight,
                child: FsButton(
                  label: l.homeKeyFindingsEvidence,
                  variant: FsButtonVariant.ghost,
                  size: FsButtonSize.sm,
                  onPressed: () => context.go(f.link),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "Biggest gaps" list: rank, title, sentence, relevance x scarcity score bar, link.
class _BiggestGaps extends ConsumerWidget {
  const _BiggestGaps({required this.gaps, required this.l});

  final List<HomeTopGap> gaps;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.fs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.homeKeyFindingsBiggestGaps,
          style: context.text.titleMedium!.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: FsSpace.s3),
        for (final g in gaps.where((g) => kGapIds.contains(g.id))) ...[
          _GapRow(gap: g, l: l),
          const Divider(),
        ],
      ],
    );
  }
}

class _GapRow extends ConsumerWidget {
  const _GapRow({required this.gap, required this.l});

  final HomeTopGap gap;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.fs;
    final (title, sentence) = gapCopy(l, ref.watch(formatProvider), gap);
    final linked = ref.watch(featuresProvider).allowsLocation(gap.link);
    return Semantics(
      link: linked,
      label: '${gap.rank}. $title. $sentence',
      excludeSemantics: true,
      child: FsFocusRing(
        radius: FsRadius.xs,
        child: InkWell(
          onTap: linked ? () => context.go(gap.link) : null,
          mouseCursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: FsSpace.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  child: Text(
                    '${gap.rank}',
                    style: context.text.labelMedium!.copyWith(
                      color: c.microg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: FsSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: context.text.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.fs.textPrimary,
                        ),
                      ),
                      const SizedBox(height: FsSpace.s1),
                      Text(
                        sentence,
                        style: context.text.bodySmall!.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: FsSpace.s2),
                      LinearProgressIndicator(
                        value: gap.score.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: c.surface2,
                        color: c.microg,
                      ),
                      const SizedBox(height: FsSpace.s1),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          l.homeKeyFindingsScore(gap.score.toStringAsFixed(2)),
                          style: context.text.labelSmall!.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
