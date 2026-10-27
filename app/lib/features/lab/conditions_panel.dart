import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/lab_input.dart';
import '../../domain/providers.dart';
import '../../domain/sensitivity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/fs_segmented.dart';
import '../../widgets/fs_slider.dart';
import '../../widgets/gravity_slider.dart';
import '../../widgets/toast.dart';
import 'lab_providers.dart';
import 'material_picker.dart';

/// Conditions panel: material, sliders, airflow direction, reset and copy link (DESIGN.md §11.3).
class ConditionsPanel extends ConsumerWidget {
  const ConditionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final spec = ref.watch(loadedDataProvider).featureSpec;
    final x = ref.watch(labInputProvider);
    final n = ref.read(labInputProvider.notifier);
    void set(LabInput v) => n.set(v);
    Widget slider(
      String name,
      double value,
      LabInput Function(double) apply, {
      int decimals = 1,
      List<FsSliderMarker> markers = const [],
    }) {
      final s = spec.input(name);
      return Padding(
        padding: const EdgeInsets.only(bottom: FsSpace.s5),
        child: FsSlider(
          label: l.inputLabel(name),
          value: value,
          min: s.min,
          max: s.max,
          step: s.step,
          scale: scaleFor(s),
          displayScale: s.displayScale,
          decimals: decimals,
          unit: s.displayUnit,
          markers: [
            for (final m in markers)
              if (m.value >= s.min && m.value <= s.max) m,
          ],
          onChanged: (v) => set(apply(v)),
        ),
      );
    }

    final groups = spec.sustain.available
        ? spec.sustain.groups
        : spec.spread.groups;
    final classes =
        groups['fuel_class']?.options ?? const ['thin_solid', 'thick_solid'];
    return FsPanel(
      title: l.labConditions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MaterialPicker(),
          const SizedBox(height: FsSpace.s5),
          if (x.material == null) ...[
            FsSegmented<String>(
              semanticLabel: l.featFuelClass,
              segments: [
                for (final c in classes) FsSegment(c, l.fuelClassLabel(c)),
              ],
              selected: classes.contains(x.fuelClass)
                  ? x.fuelClass
                  : classes.first,
              onChanged: (c) => set(x.copyWith(fuelClass: c)),
            ),
            const SizedBox(height: FsSpace.s5),
            slider(
              'fuel_thickness_mm',
              x.thicknessMm,
              (v) => x.copyWith(thicknessMm: v),
              decimals: 2,
            ),
            slider(
              'fuel_density_kg_m3',
              x.densityKgM3,
              (v) => x.copyWith(densityKgM3: v),
              decimals: 0,
            ),
          ],
          slider(
            'o2_mole_fraction',
            x.o2,
            (v) => x.copyWith(o2: v),
            markers: [FsSliderMarker(0.21, l.labMarkerEarthAir)],
          ),
          slider(
            'pressure_kpa',
            x.pressureKpa,
            (v) => x.copyWith(pressureKpa: v),
            markers: [FsSliderMarker(101.3, l.labMarkerSeaLevel)],
          ),
          slider(
            'flow_velocity_mm_s',
            x.flowMmS,
            (v) => x.copyWith(flowMmS: v),
            decimals: 0,
          ),
          GravitySlider(
            value: x.gravityG,
            onChanged: (g) => set(x.copyWith(gravityG: g)),
          ),
          const SizedBox(height: FsSpace.s5),
          FsSegmented<String>(
            semanticLabel: l.featFlowDir,
            segments: [
              FsSegment('opposed', l.dirOpposed),
              FsSegment('concurrent', l.dirConcurrent),
              FsSegment('quiescent', l.dirQuiescent),
            ],
            selected: x.flowDirection,
            onChanged: (d) => set(x.copyWith(flowDirection: d)),
          ),
          const SizedBox(height: FsSpace.s6),
          Wrap(
            spacing: FsSpace.s3,
            runSpacing: FsSpace.s3,
            children: [
              FsButton(
                label: l.labReset,
                variant: FsButtonVariant.secondary,
                onPressed: n.reset,
              ),
              FsButton(
                label: l.labCopyLink,
                variant: FsButtonVariant.ghost,
                icon: Icons.link_rounded,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: labShareLink(x)));
                  if (context.mounted) showFsToast(context, l.linkCopied);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
