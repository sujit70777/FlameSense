import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../domain/gravity.dart';
import '../l10n/app_localizations.dart';
import 'fs_slider.dart';

/// Log-scale gravity slider with ISS, Moon, Mars, Earth snaps; the active track
/// lerps microg → ember with the position, matching the flame (DESIGN.md §9.7).
class GravitySlider extends ConsumerWidget {
  const GravitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final text = gravityLabel(value, l, fmt);
    return FsSlider(
      label: label ?? l.featGravity,
      value: value.clamp(kIssG, kEarthG),
      min: kIssG,
      max: kEarthG,
      scale: FsSliderScale.log,
      showField: false,
      valueText: text,
      semanticsValue: text,
      activeColorAt: (p) => Color.lerp(c.microg, c.ember, p)!,
      snaps: [
        FsSliderSnap(kIssG, l.gIss),
        FsSliderSnap(kMoonG, l.gMoon),
        FsSliderSnap(kMarsG, l.gMars),
        FsSliderSnap(kEarthG, l.gEarth),
      ],
      onChanged: onChanged,
    );
  }
}
