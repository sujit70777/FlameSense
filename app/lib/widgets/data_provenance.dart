import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/platform/browser.dart';
import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../data/models/app_meta.dart';
import '../features/explore/explore_filters.dart';
import '../features/methods/simple_table.dart';
import '../l10n/app_localizations.dart';
import 'fs_button.dart';
import 'toast.dart';

/// Source-type keys in display order (PLAN.md §3.0).
const kSourceTypes = [
  'nasa_psi',
  'nasa_report',
  'partner_agency',
  'third_party',
];

/// Localized label for a `source_type` value.
String sourceTypeLabel(AppLocalizations l, String t) => switch (t) {
  'nasa_psi' => l.provTypeNasaPsi,
  'nasa_report' => l.provTypeNasaReport,
  'partner_agency' => l.provTypePartner,
  'third_party' => l.provTypeThirdParty,
  _ => t,
};

/// Localized label for a source's authorship (PLAN.md §1.0 "Third-party").
String authorshipLabel(AppLocalizations l, String a) => switch (a) {
  'nasa' => l.provAuthNasa,
  'partner' => l.provAuthPartner,
  'nasa_coauthored' => l.provAuthCoauthored,
  'independent' => l.provAuthIndependent,
  'unlabelled' => l.provAuthUnlabelled,
  _ => a,
};

/// "Data provenance" table: one row per cited source with its `source_type`,
/// authorship and run count, plus a CSV download of the master run list.
/// Every count comes from `app_meta.json`. Used on Methods and Data/Explore.
class DataProvenance extends ConsumerWidget {
  const DataProvenance({super.key});

  static String _masterFileName(DateTime now) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'flamesense_master_list_${now.year}${two(now.month)}${two(now.day)}.csv';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final d = ref.watch(loadedDataProvider);
    final meta = d.meta;
    if (meta.nRuns == 0 || meta.sources.isEmpty) {
      return Text(l.provNoData, style: context.text.bodyMedium);
    }
    final types = [
      for (final t in kSourceTypes)
        l.provTypeCount(
          sourceTypeLabel(l, t),
          f.integer(meta.sourceType[t] ?? 0),
        ),
    ].join(', ');
    final coauthored = meta.sources.any(
      (s) => s.authorship == 'nasa_coauthored',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.provIntro(
            f.integer(meta.nRuns),
            f.integer(meta.sources.length),
            f.integer(meta.rowsIngested),
            f.integer(meta.rowsDropped),
          ),
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: FsSpace.s2),
        Text(l.provByType(types), style: context.text.bodyMedium),
        const SizedBox(height: FsSpace.s4),
        SimpleTable(
          headers: [
            l.provCitation,
            l.provSourceType,
            l.provAuthorship,
            l.colRuns,
            l.provMerged,
          ],
          flex: const [4, 2, 2, 1, 1],
          rows: [
            for (final s in meta.sources)
              [
                _SourceCell(s: s),
                SimpleTable.t(context, sourceTypeLabel(l, s.sourceType)),
                SimpleTable.t(context, authorshipLabel(l, s.authorship)),
                SimpleTable.t(context, f.integer(s.nRuns), num: true),
                SimpleTable.t(
                  context,
                  f.integer(s.nDroppedDuplicates),
                  num: true,
                ),
              ],
          ],
        ),
        const SizedBox(height: FsSpace.s5),
        Align(
          alignment: Alignment.centerLeft,
          child: FsButton(
            label: l.provDownloadMaster,
            icon: Icons.download_rounded,
            variant: FsButtonVariant.secondary,
            size: FsButtonSize.sm,
            onPressed: () {
              final csv = runsToCsv(d.runs.columns, d.runs.records);
              downloadBytes(
                _masterFileName(DateTime.now()),
                utf8.encode('﻿$csv'),
                'text/csv;charset=utf-8',
              );
              showFsToast(
                context,
                l.csvDownloaded,
                icon: Icons.download_done_rounded,
              );
            },
          ),
        ),
        if (coauthored) ...[
          const SizedBox(height: FsSpace.s3),
          Container(
            padding: const EdgeInsets.all(FsSpace.s3),
            decoration: BoxDecoration(
              color: context.fs.microgTint,
              borderRadius: BorderRadius.circular(FsRadius.md),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  size: FsSize.iconButton,
                  color: context.fs.textSecondary,
                ),
                const SizedBox(width: FsSpace.s2),
                Expanded(
                  child: Text(
                    l.provNasaCoauthored,
                    style: context.text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Citation, its experiments, and an "Open source" link when a URL exists.
class _SourceCell extends StatelessWidget {
  const _SourceCell({required this.s});

  final SourceProvenance s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleTable.t(context, s.citation),
        Text(
          s.experiments.join(', '),
          style: context.text.labelSmall!.copyWith(
            color: context.fs.textTertiary,
          ),
        ),
        if (s.url != null)
          FsButton(
            label: l.runOpenSource,
            variant: FsButtonVariant.ghost,
            size: FsButtonSize.sm,
            semanticLabel: '${l.runOpenSource}. ${l.openInNewTab}',
            onPressed: () =>
                launchUrl(Uri.parse(s.url!), webOnlyWindowName: '_blank'),
          ),
      ],
    );
  }
}
