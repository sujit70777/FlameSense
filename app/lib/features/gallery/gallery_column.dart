import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/gravity.dart';
import '../../domain/support_index.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/chamber_window.dart';
import '../../widgets/citation_chip.dart';
import '../../widgets/data_support_badge.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_chip.dart';
import '../../widgets/fs_icon_button.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/fs_tabs.dart';
import '../../widgets/gravity_chip.dart';
import '../../widgets/inline_notice.dart';
import '../../widgets/metric_readout.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton_block.dart';
import '../../widgets/toast.dart';
import 'gallery_controls.dart';

/// One theme's column of the gallery.
class GalleryColumn extends StatelessWidget {
  const GalleryColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget gap() => const SizedBox(height: FsSpace.s4, width: FsSpace.s4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BrandLockup(),
        gap(),
        Text(l.homeHeadline, style: context.text.displayLarge),
        Text(l.tagline, style: context.text.bodyLarge),
        gap(),
        Wrap(
          spacing: FsSpace.s3,
          runSpacing: FsSpace.s3,
          children: [
            FsButton(label: l.homeCtaLab, onPressed: () {}),
            FsButton(
              label: l.takeTour,
              variant: FsButtonVariant.secondary,
              onPressed: () {},
            ),
            FsButton(
              label: l.askCopy,
              variant: FsButtonVariant.ghost,
              onPressed: () {},
            ),
            FsButton(
              label: l.close,
              variant: FsButtonVariant.danger,
              onPressed: () {},
            ),
            FsButton(
              label: l.exploreDownload,
              icon: Icons.download_rounded,
              size: FsButtonSize.sm,
              onPressed: () {},
            ),
            FsButton(label: l.askButton, loading: true, onPressed: () {}),
            FsButton(label: l.reload, onPressed: null),
            FsIconButton(
              icon: Icons.dark_mode_rounded,
              tooltip: l.themeDark,
              onPressed: () {},
            ),
          ],
        ),
        gap(),
        Wrap(
          spacing: FsSpace.s2,
          runSpacing: FsSpace.s2,
          children: [
            FsChip(label: l.filterExperiment, dropdown: true, onTap: () {}),
            FsChip(label: l.qualityIncEstimated, selected: true, onTap: () {}),
            FsChip(label: l.qualityIncFlagged, onTap: () {}),
            GravityChip(
              gravityClass: GravityClass.micro,
              label: l.gravityValue(l.gIss, '10⁻⁶'),
            ),
            GravityChip(
              gravityClass: GravityClass.partial,
              label: l.gravityValue(l.gMoon, '0.165'),
            ),
            GravityChip(
              gravityClass: GravityClass.earth,
              label: l.gravityValue(l.gEarth, '1'),
            ),
          ],
        ),
        gap(),
        const Wrap(
          spacing: FsSpace.s2,
          runSpacing: FsSpace.s2,
          children: [
            DataSupportBadge(level: SupportLevel.high),
            DataSupportBadge(level: SupportLevel.medium),
            DataSupportBadge(level: SupportLevel.low),
            DataSupportBadge(level: SupportLevel.low, compact: true),
          ],
        ),
        gap(),
        FsPanel(
          title: l.labPrediction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetricReadout(
                label: l.labChanceLabel,
                value: '72',
                unit: '%',
                size: ReadoutSize.lg,
              ),
              gap(),
              MetricReadout(
                label: l.labSpreadTitle,
                value: '3.4',
                unit: l.unitMmS,
                caption: l.labRange80('1.9', '4.6'),
              ),
              gap(),
              Row(
                children: [
                  CitationChip(
                    n: 1,
                    tooltip: l.askCitationTip('Title', '4'),
                    onTap: () {},
                  ),
                  const SizedBox(width: FsSpace.s2),
                  CitationChip(
                    n: 2,
                    tooltip: l.askCitationTip('Title', '7'),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        gap(),
        const GalleryControls(),
        gap(),
        InlineNotice(message: l.noticePartialG),
        gap(),
        InlineNotice(
          message: l.noticeOutside(l.featO2, '17', '35', '%'),
          variant: NoticeVariant.warn,
        ),
        gap(),
        InlineNotice(
          message: l.noticeLowSupport,
          variant: NoticeVariant.danger,
          actionLabel: l.tryAgain,
          onAction: () {},
        ),
        gap(),
        InlineNotice(message: l.answerCopied, variant: NoticeVariant.success),
        gap(),
        SectionHeader(title: l.homeNextTitle, description: l.exploreDesc),
        DefaultTabController(
          length: 3,
          child: FsTabBar(
            labels: [l.exploreTabSpread, l.exploreTabBurning, l.exploreTabRuns],
          ),
        ),
        gap(),
        const SkeletonBlock(height: 44, radius: FsRadius.sm),
        gap(),
        EmptyState(
          icon: Icons.filter_alt_off_rounded,
          title: l.exploreEmptyTitle,
          body: l.exploreEmptyBody,
          primaryLabel: l.exploreClear,
          onPrimary: () {},
        ),
        ErrorState(
          title: l.loadErrorTitle,
          body: l.loadErrorBody('runs.json'),
          actionLabel: l.reload,
          onAction: () {},
        ),
        gap(),
        const SizedBox(
          height: 160,
          child: ChamberWindow(
            child: Center(child: BrandMark(size: 56, onDark: true)),
          ),
        ),
        gap(),
        FsButton(
          label: l.linkCopied,
          variant: FsButtonVariant.secondary,
          onPressed: () => showFsToast(context, l.linkCopied),
        ),
      ],
    );
  }
}
