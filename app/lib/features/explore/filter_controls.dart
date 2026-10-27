import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_chip.dart';
import 'explore_providers.dart';
import 'filter_dialogs.dart';

/// The wrapping row of filter chips (DESIGN.md §11.2), shared by desktop and the compact sheet.
class FilterControls extends ConsumerWidget {
  const FilterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final f = ref.watch(exploreFiltersProvider);
    final set = ref.read(exploreFiltersProvider.notifier).set;
    final runs = ref.watch(loadedDataProvider).runs.records;
    final experiments = {for (final r in runs) r.experiment}.toList()..sort();
    final platforms = {for (final r in runs) r.platform}.toList()..sort();
    final fuels = {for (final r in runs) r.fuelClass}.toList()..sort();
    double lo(Iterable<double> v, double fb) =>
        v.isEmpty ? fb : v.reduce((a, b) => a < b ? a : b);
    double hi(Iterable<double> v, double fb) =>
        v.isEmpty ? fb : v.reduce((a, b) => a > b ? a : b);
    final o2s = runs.map((r) => r.o2 * 100),
        ps = runs.map((r) => r.pressureKpa);
    String named(String base, String? value) =>
        value == null ? base : '$base: $value';
    return Wrap(
      spacing: FsSpace.s2,
      runSpacing: FsSpace.s2,
      children: [
        FsChip(
          label: f.experiments.isEmpty
              ? l.filterExperiment
              : '${l.filterExperiment}: ${fmt.integer(f.experiments.length)}',
          selected: f.experiments.isNotEmpty,
          dropdown: true,
          onTap: () async {
            final r = await pickMany(
              context,
              l.filterExperiment,
              experiments,
              f.experiments,
            );
            if (r != null) set(f.copyWith(experiments: r));
          },
        ),
        FsChip(
          label: named(
            l.filterPlatform,
            f.platform == null ? null : l.platformLabel(f.platform!),
          ),
          selected: f.platform != null,
          dropdown: true,
          onTap: () async {
            final r = await pickOne(context, l.filterPlatform, [
              for (final p in platforms) (p, l.platformLabel(p)),
            ], f.platform);
            if (r != null) set(f.copyWith(platform: () => r.$1));
          },
        ),
        FsChip(
          label: named(
            l.filterFuelClass,
            f.fuelClass == null ? null : l.fuelClassLabel(f.fuelClass!),
          ),
          selected: f.fuelClass != null,
          dropdown: true,
          onTap: () async {
            final r = await pickOne(context, l.filterFuelClass, [
              for (final c in fuels) (c, l.fuelClassLabel(c)),
            ], f.fuelClass);
            if (r != null) set(f.copyWith(fuelClass: () => r.$1));
          },
        ),
        FsChip(
          label: named(
            l.filterGravity,
            f.gravity == null ? null : l.gravityClassLabel(f.gravity!),
          ),
          selected: f.gravity != null,
          dropdown: true,
          onTap: () async {
            final r = await pickOne(context, l.filterGravity, [
              for (final g in GravityClass.values) (g, l.gravityClassLabel(g)),
            ], f.gravity);
            if (r != null) set(f.copyWith(gravity: () => r.$1));
          },
        ),
        FsChip(
          label: f.o2Min == null
              ? l.filterO2
              : l.filterRangeValue(
                  fmt.sig(f.o2Min! * 100),
                  fmt.sig(f.o2Max! * 100),
                  l.unitPercent,
                ),
          selected: f.o2Min != null,
          dropdown: true,
          onTap: () async {
            final mn = lo(o2s, 10), mx = hi(o2s, 50);
            final r = await pickRange(
              context,
              title: l.filterO2,
              min: mn,
              max: mx < mn + 1 ? mn + 1 : mx,
              current: (
                (f.o2Min ?? mn / 100) * 100,
                (f.o2Max ?? mx / 100) * 100,
              ),
              unit: l.unitPercent,
              format: fmt,
            );
            if (r != null) set(f.copyWith(o2: (r.$1 / 100, r.$2 / 100)));
          },
        ),
        FsChip(
          label: f.pressureMin == null
              ? l.filterPressure
              : l.filterRangeValue(
                  fmt.sig(f.pressureMin!),
                  fmt.sig(f.pressureMax!),
                  l.unitKpa,
                ),
          selected: f.pressureMin != null,
          dropdown: true,
          onTap: () async {
            final mn = lo(ps, 10), mx = hi(ps, 200);
            final r = await pickRange(
              context,
              title: l.filterPressure,
              min: mn,
              max: mx < mn + 1 ? mn + 1 : mx,
              current: (f.pressureMin ?? mn, f.pressureMax ?? mx),
              unit: l.unitKpa,
              format: fmt,
            );
            if (r != null) set(f.copyWith(pressure: r));
          },
        ),
        FsChip(
          label: l.qualityIncEstimated,
          selected: f.includeEstimated,
          onTap: () => set(f.copyWith(includeEstimated: !f.includeEstimated)),
        ),
        FsChip(
          label: l.qualityIncDigitized,
          selected: f.includeDigitized,
          onTap: () => set(f.copyWith(includeDigitized: !f.includeDigitized)),
        ),
        FsChip(
          label: l.qualityIncVideo,
          selected: f.includeVideo,
          onTap: () => set(f.copyWith(includeVideo: !f.includeVideo)),
        ),
        FsChip(
          label: l.qualityIncFlagged,
          selected: f.includeFlagged,
          onTap: () => set(f.copyWith(includeFlagged: !f.includeFlagged)),
        ),
      ],
    );
  }
}
