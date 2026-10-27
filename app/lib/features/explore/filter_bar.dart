import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breakpoints.dart';
import '../../core/platform/browser.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_sheet.dart';
import '../../widgets/toast.dart';
import 'explore_filters.dart';
import 'explore_providers.dart';
import 'filter_controls.dart';

/// Downloads the filtered runs as CSV (UTF-8 with BOM so Excel reads ₂, ³ and Bangla).
void downloadFilteredCsv(BuildContext context, WidgetRef ref) {
  final data = ref.read(loadedDataProvider);
  final csv = runsToCsv(data.runs.columns, ref.read(sortedRunsProvider));
  downloadBytes(
    csvFileName(DateTime.now()),
    utf8.encode('﻿$csv'),
    'text/csv;charset=utf-8',
  );
  showFsToast(
    context,
    AppLocalizations.of(context).csvDownloaded,
    icon: Icons.download_done_rounded,
  );
}

/// Filters, result count, Clear and Download (DESIGN.md §11.2).
class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final shown = ref.watch(filteredRunsProvider).length;
    final total = ref.watch(loadedDataProvider).runs.records.length;
    final filters = ref.watch(exploreFiltersProvider);
    final compact = FsWidth.of(context).isCompact;
    final summary = Wrap(
      spacing: FsSpace.s3,
      runSpacing: FsSpace.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l.exploreShowing(fmt.integer(shown), fmt.integer(total)),
            style: context.text.bodyMedium,
          ),
        ),
        FsButton(
          label: l.exploreClear,
          variant: FsButtonVariant.ghost,
          size: FsButtonSize.sm,
          onPressed: filters.isDefault
              ? null
              : ref.read(exploreFiltersProvider.notifier).clear,
        ),
        FsButton(
          label: l.exploreDownload,
          icon: Icons.download_rounded,
          variant: FsButtonVariant.secondary,
          size: FsButtonSize.sm,
          onPressed: shown == 0
              ? null
              : () => downloadFilteredCsv(context, ref),
        ),
      ],
    );
    if (compact) {
      final n = filters.activeCount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FsButton(
            label: n == 0
                ? l.filtersButton
                : '${l.filtersButton} (${fmt.integer(n)})',
            icon: Icons.filter_list_rounded,
            variant: FsButtonVariant.secondary,
            onPressed: () => showFsSheet<void>(
              context,
              (_) => const Padding(
                padding: EdgeInsets.all(FsSpace.s4),
                child: FilterControls(),
              ),
            ),
          ),
          const SizedBox(height: FsSpace.s3),
          summary,
        ],
      );
    }
    return Wrap(
      spacing: FsSpace.s6,
      runSpacing: FsSpace.s3,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [const FilterControls(), summary],
    );
  }
}
