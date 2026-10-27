import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_chip.dart';
import '../../widgets/fs_dialog.dart';
import '../../widgets/fs_slider.dart';
import '../../widgets/gravity_slider.dart';
import '../explore/filter_dialogs.dart';
import 'map_providers.dart';

/// Material type, pressure, gravity, airflow direction and overlay chips (DESIGN.md §11.4).
class MapControls extends ConsumerWidget {
  const MapControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final s = ref.watch(mapSettingsProvider);
    final set = ref.read(mapSettingsProvider.notifier).set;
    final spec = ref.watch(loadedDataProvider).featureSpec;
    final groups = spec.sustain.available
        ? spec.sustain.groups
        : spec.spread.groups;
    final classes =
        groups['fuel_class']?.options ?? const ['thin_solid', 'thick_solid'];
    Future<void> dialogSlider(
      String title,
      Widget Function(StateSetter) child,
    ) => showFsDialog<void>(
      context,
      StatefulBuilder(
        builder: (context, setState) => FsDialog(
          title: title,
          actions: [
            FsButton(
              label: l.close,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          child: child(setState),
        ),
      ),
    );
    return Wrap(
      spacing: FsSpace.s2,
      runSpacing: FsSpace.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FsChip(
          label: l.fuelClassLabel(s.fuelClass),
          dropdown: true,
          onTap: () async {
            final r = await pickOne(context, l.featFuelClass, [
              for (final c in classes) (c, l.fuelClassLabel(c)),
            ], s.fuelClass);
            if (r?.$1 != null) {
              set(s.copyWith(fuelClass: r!.$1, pinned: () => null));
            }
          },
        ),
        FsChip(
          label: l.mapPressureValue(fmt.sig(s.pressureKpa)),
          dropdown: true,
          onTap: () => dialogSlider(l.featPressure, (setState) {
            final p = spec.input('pressure_kpa');
            final cur = ref.read(mapSettingsProvider);
            return FsSlider(
              label: l.featPressure,
              value: cur.pressureKpa.clamp(p.min, p.max),
              min: p.min,
              max: p.max,
              step: p.step,
              unit: l.unitKpa,
              onChanged: (v) => setState(
                () => set(
                  ref
                      .read(mapSettingsProvider)
                      .copyWith(pressureKpa: v, pinned: () => null),
                ),
              ),
            );
          }),
        ),
        FsChip(
          label: l.mapGravityValue(gravityLabel(s.gravityG, l, fmt)),
          dropdown: true,
          onTap: () async {
            const custom = -1.0;
            final r = await pickOne<double>(context, l.featGravity, [
              (kIssG, l.gIss),
              (kMoonG, l.gMoon),
              (kMarsG, l.gMars),
              (kEarthG, l.gEarth),
              (custom, l.gCustom),
            ], s.gravityG);
            if (r == null || r.$1 == null) return;
            if (r.$1 != custom) {
              return set(s.copyWith(gravityG: r.$1, pinned: () => null));
            }
            if (!context.mounted) return;
            await dialogSlider(
              l.featGravity,
              (setState) => GravitySlider(
                value: ref.read(mapSettingsProvider).gravityG,
                onChanged: (g) => setState(
                  () => set(
                    ref
                        .read(mapSettingsProvider)
                        .copyWith(gravityG: g, pinned: () => null),
                  ),
                ),
              ),
            );
          },
        ),
        FsChip(
          label: l.flowDirLabel(s.flowDirection),
          dropdown: true,
          onTap: () async {
            final r = await pickOne(context, l.featFlowDir, [
              for (final d in ['opposed', 'concurrent', 'quiescent'])
                (d, l.flowDirLabel(d)),
            ], s.flowDirection);
            if (r?.$1 != null) {
              set(s.copyWith(flowDirection: r!.$1, pinned: () => null));
            }
          },
        ),
        const SizedBox(width: FsSpace.s4),
        FsChip(
          label: l.mapOverlayRuns,
          selected: s.showRuns,
          onTap: () => set(s.copyWith(showRuns: !s.showRuns)),
        ),
        FsChip(
          label: l.mapOverlayContour,
          selected: s.showContour,
          onTap: () => set(s.copyWith(showContour: !s.showContour)),
        ),
      ],
    );
  }
}
