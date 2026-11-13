import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/breakpoints.dart';
import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';
import 'fs_icon_button.dart';

/// Semicircle gauge of the chance a flame keeps burning (DESIGN.md §9.14).
class SustainGauge extends ConsumerWidget {
  const SustainGauge({
    super.key,
    required this.probability,
    this.unavailableTip,
  });

  /// 0–1, or null when the sustain task is unavailable.
  final double? probability;

  /// Explanation behind the info button in the unavailable state.
  final String? unavailableTip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final d = FsWidth.of(context).isCompact ? 200.0 : 240.0;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final p = probability;
    final label = p == null
        ? l.labGaugeUnavailable
        : l.labGaugeSemantics(fmt.percentPoints(p));
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: p ?? 0),
        duration: reduced ? Duration.zero : FsMotion.value,
        curve: FsMotion.curveValue,
        builder: (context, v, _) => SizedBox(
          width: d,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: d,
                height: d / 2 + 14,
                child: CustomPaint(
                  painter: _GaugePainter(
                    value: p == null ? null : v,
                    track: c.outline,
                    color: c.rampAt(v),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          p == null ? l.notAvailable : fmt.percentPoints(v),
                          style: context.nums.hero,
                        ),
                        if (p != null)
                          Text(
                            l.unitPercent,
                            style: context.nums.md.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: FsSpace.s1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      p == null ? l.labGaugeUnavailable : l.labGaugeCaption,
                      style: context.text.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (p == null && unavailableTip != null)
                    FsIconButton(
                      icon: Icons.info_outline_rounded,
                      tooltip: unavailableTip!,
                      onPressed: () {},
                    ),
                ],
              ),
              const SizedBox(height: FsSpace.s1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l.labGoesOut, style: context.text.labelSmall),
                  Text(l.labKeepsBurning, style: context.text.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.track,
    required this.color,
  });

  final double? value;
  final Color track, color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final r = size.width / 2 - stroke / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.width / 2),
      radius: r,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, base..color = track);
    if (value != null && value! > 0) {
      canvas.drawArc(
        rect,
        math.pi,
        math.pi * value!.clamp(0.0, 1.0),
        false,
        base..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter o) =>
      o.value != value || o.color != color || o.track != track;
}
