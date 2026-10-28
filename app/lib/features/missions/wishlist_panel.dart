import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/platform/browser.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/missions_file.dart';
import '../../domain/providers.dart';
import '../../domain/wishlist.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/toast.dart';
import '../explore/explore_filters.dart';
import '../map/heatmap_painter.dart';
import '../map/map_grid.dart';
import '../map/map_view.dart';
import 'wishlist_csv.dart';

/// "Where NASA should test next": mini map with pins, ranked picks, planned tests, CSV (DESIGN.md §11.12).
class WishlistPanel extends ConsumerWidget {
  const WishlistPanel({
    super.key,
    required this.mission,
    required this.wishlist,
  });

  final Mission mission;
  final Wishlist? wishlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final w = wishlist;
    if (w == null) {
      return FsPanel(
        title: l.wishlistTitle,
        child: EmptyState(
          icon: Icons.science_rounded,
          title: l.wishlistTitle,
          body: l.wishlistEmpty,
        ),
      );
    }
    final p = ref.watch(predictorProvider);
    final defaults = ref.watch(defaultLabInputProvider);
    final mats = ref.watch(materialsProvider);
    final fc = w.picks.isEmpty
        ? defaults.fuelClass
        : w.picks.first.input.fuelClass;
    final ofClass = mats.where((m) => m.fuelClass == fc).toList();
    final grid = computeMapGrid(
      p,
      ref.watch(loadedDataProvider).featureSpec,
      MapKey(
        fuelClass: fc,
        thicknessMm: ofClass.isEmpty
            ? defaults.thicknessMm
            : (ofClass.first.thicknessMm ?? defaults.thicknessMm),
        densityKgM3: ofClass.isEmpty
            ? defaults.densityKgM3
            : (ofClass.first.densityKgM3 ?? defaults.densityKgM3),
        pressureKpa: mission.pressureKpa,
        gravityG: mission.gravityG,
        flowDirection: defaults.flowDirection,
      ),
    );
    final flowMin = p.spec.input('flow_velocity_mm_s').min;
    final markers = [
      for (var i = 0; i < w.picks.length; i++)
        MapMarker(
          flow: w.picks[i].input.flowMmS,
          o2: w.picks[i].input.o2,
          label: '${i + 1}',
        ),
      for (final e in w.planned)
        for (final pt in e.experiment.points)
          MapMarker(flow: flowMin, o2: pt.o2, square: true),
    ];
    return FsPanel(
      title: l.wishlistTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360 + 36),
            child: MapView(
              grid: grid,
              runs: const [],
              showContour: true,
              pinned: null,
              onPin: (_) {},
              markers: markers,
              aspect: 1.5,
            ),
          ),
          if (w.planned.isNotEmpty) ...[
            const SizedBox(height: FsSpace.s2),
            for (final e in w.planned)
              Text(
                l.wishlistPlannedLegend(l.plannedLabel(e.experiment.labelKey)),
                style: context.text.labelSmall,
              ),
          ],
          const SizedBox(height: FsSpace.s4),
          const Divider(),
          for (var i = 0; i < w.picks.length; i++)
            _PickRow(rank: i + 1, c: w.picks[i]),
          for (final e in w.planned) ...[
            const SizedBox(height: FsSpace.s3),
            Text(
              l.wishlistPlanned(
                l.plannedLabel(e.experiment.labelKey),
                truncPercent(f, e.topPercent),
              ),
              style: context.text.bodyMedium!.copyWith(
                color: context.fs.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: FsSpace.s4),
          Align(
            alignment: Alignment.centerLeft,
            child: FsButton(
              label: l.wishlistCsv,
              icon: Icons.download_rounded,
              variant: FsButtonVariant.secondary,
              onPressed: () {
                final name =
                    'flamesense_wishlist_${mission.id}_${csvFileName(DateTime.now()).substring(16, 24)}.csv';
                downloadBytes(
                  name,
                  utf8.encode(wishlistCsv(mission.id, w)),
                  'text/csv;charset=utf-8',
                );
                showFsToast(
                  context,
                  l.wishlistCsvDone,
                  icon: Icons.download_done_rounded,
                );
              },
            ),
          ),
          const SizedBox(height: FsSpace.s3),
          Text(l.wishlistCaption, style: context.text.labelSmall),
        ],
      ),
    );
  }
}

class _PickRow extends ConsumerWidget {
  const _PickRow({required this.rank, required this.c});

  final int rank;
  final WishCandidate c;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    return Semantics(
      label: l.wishlistPin(f.integer(rank)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FsSpace.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                f.integer(rank),
                style: context.nums.md.copyWith(color: context.fs.textTertiary),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wishConditions(l, f, c), style: context.text.labelLarge),
                  for (final r in wishReasons(l, f, c))
                    Text(r, style: context.text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
