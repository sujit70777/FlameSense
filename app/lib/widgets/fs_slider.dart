import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/breakpoints.dart';
import '../core/format.dart';
import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';
import 'fs_chip.dart';
import 'fs_slider_number_field.dart';
import 'fs_slider_track.dart';
import 'slider_scale.dart';
import 'unit_value.dart';

export 'slider_scale.dart';

/// A labelled marker tick under the track, e.g. "Earth air 21%".
class FsSliderMarker {
  const FsSliderMarker(this.value, this.label);
  final double value;
  final String label;
}

/// A snap point shown as a pill under the track, e.g. "Moon".
class FsSliderSnap {
  const FsSliderSnap(this.value, this.label);
  final double value;
  final String label;
}

/// Slider with label row, value, number field, markers and snaps (DESIGN.md §9.7).
///
/// [value], [min], [max] and [step] are in model units; the field and label show
/// `value × displayScale` with [decimals] decimals.
class FsSlider extends ConsumerWidget {
  const FsSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.scale = FsSliderScale.linear,
    this.step,
    this.displayScale = 1,
    this.decimals = 1,
    this.unit = '',
    this.markers = const [],
    this.snaps = const [],
    this.activeColorAt,
    this.showField = true,
    this.valueText,
    this.semanticsValue,
    this.enabled = true,
  });

  final String label, unit;
  final double value, min, max, displayScale;
  final ValueChanged<double> onChanged;
  final FsSliderScale scale;

  /// Keyboard step in model units (linear); log scales step 1% of the track.
  final double? step;
  final int decimals;
  final List<FsSliderMarker> markers;
  final List<FsSliderSnap> snaps;
  final Color Function(double p)? activeColorAt;
  final bool showField, enabled;

  /// Custom value text in the label row (e.g. "ISS orbit").
  final String? valueText;

  /// Spoken value, e.g. "21 percent".
  final String? semanticsValue;

  double _pos(double v) => scale.toPosition(v, min, max);

  /// Value after [steps] keyboard steps (±inf jumps to max/min).
  double _stepped(double steps) {
    if (steps.isInfinite) return steps > 0 ? max : min;
    if (scale == FsSliderScale.linear) {
      final s = step ?? (max - min) / 100;
      return (value + steps * s).clamp(min, max);
    }
    return scale.fromPosition(_pos(value) + steps * 0.01, min, max);
  }

  void _step(double steps) => onChanged(_stepped(steps));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = ref.watch(formatProvider);
    final l = AppLocalizations.of(context);
    final shown = fmt.fixed(value * displayScale, decimals);
    final compact = FsWidth.of(context).isCompact;
    final track = FsSliderTrack(
      position: _pos(value),
      onPosition: (p) =>
          onChanged(_snapValue(scale.fromPosition(p, min, max), p)),
      onKeyStep: _step,
      semanticsLabel: label,
      semanticsValue:
          semanticsValue ?? l.sliderSemantics(valueText ?? shown, unit),
      semanticsIncreased: l.sliderSemantics(
        fmt.fixed(_stepped(1) * displayScale, decimals),
        unit,
      ),
      semanticsDecreased: l.sliderSemantics(
        fmt.fixed(_stepped(-1) * displayScale, decimals),
        unit,
      ),
      activeColorAt: activeColorAt,
      snapPositions: [for (final s in snaps) _pos(s.value)],
      enabled: enabled,
    );
    final field = FsSliderNumberField(
      label: l.numberFieldLabel(label),
      value: value * displayScale,
      min: min * displayScale,
      max: max * displayScale,
      decimals: decimals,
      format: fmt,
      onSubmitted: (v) => onChanged(v / displayScale),
      enabled: enabled,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: context.text.labelLarge)),
            ExcludeSemantics(
              child: UnitValue(
                value: valueText ?? shown,
                unit: valueText == null ? unit : '',
              ),
            ),
          ],
        ),
        if (!showField || compact)
          track
        else
          Row(
            children: [
              Expanded(child: track),
              const SizedBox(width: FsSpace.s3),
              field,
            ],
          ),
        if (markers.isNotEmpty) _Markers(markers: markers, positionOf: _pos),
        if (snaps.isNotEmpty) ...[
          const SizedBox(height: FsSpace.s2),
          Wrap(
            spacing: FsSpace.s2,
            runSpacing: FsSpace.s2,
            children: [
              for (final s in snaps)
                FsChip(
                  label: s.label,
                  selected: (s.value - value).abs() <= (s.value.abs() * 0.02),
                  onTap: enabled ? () => onChanged(s.value) : null,
                ),
            ],
          ),
        ],
        if (showField && compact) ...[
          const SizedBox(height: FsSpace.s2),
          field,
        ],
      ],
    );
  }

  double _snapValue(double v, double p) {
    for (final s in snaps) {
      if ((_pos(s.value) - p).abs() <= 0.02) return s.value;
    }
    return v;
  }
}

/// Marker ticks with captions under the track.
class _Markers extends StatelessWidget {
  const _Markers({required this.markers, required this.positionOf});

  final List<FsSliderMarker> markers;
  final double Function(double) positionOf;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    const r = FsSize.sliderThumb / 2;
    return SizedBox(
      height: 28,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final m in markers)
                Positioned(
                  left: (r + positionOf(m.value) * (w - 2 * r) - 60).clamp(
                    0.0,
                    w - 120,
                  ),
                  width: 120,
                  top: 0,
                  child: Column(
                    children: [
                      Container(width: 2, height: 8, color: c.outlineStrong),
                      Text(
                        m.label,
                        style: context.text.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Parses with [FsFormat.parse]; exported for tests.
double? parseSliderInput(String s) => FsFormat.parse(s);
