import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';
import 'unit_value.dart';

/// Spread rate q50 with the q10–q90 band on a log axis (DESIGN.md §9.15).
class SpreadBand extends ConsumerWidget {
  const SpreadBand({
    super.key,
    required this.q10,
    required this.q50,
    required this.q90,
    required this.axisMin,
    required this.axisMax,
    this.earth = false,
  });

  final double q10, q50, q90, axisMin, axisMax;

  /// Compare-mode Earth column uses ember instead of microg.
  final bool earth;

  double _pos(double v) {
    final a = math.log(axisMin), b = math.log(axisMax);
    return ((math.log(math.max(v, 1e-9)) - a) / (b - a)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final accent = earth ? c.ember : c.microg;
    return Semantics(
      label: l.labSpreadSemantics(fmt.sig(q50), fmt.sig(q10), fmt.sig(q90)),
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.labSpreadTitle, style: context.text.bodyMedium),
          const SizedBox(height: FsSpace.s1),
          Align(
            alignment: Alignment.centerLeft,
            child: UnitValue(
              value: fmt.sig(q50),
              unit: l.unitMmS,
              style: context.nums.lg,
            ),
          ),
          const SizedBox(height: FsSpace.s3),
          LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final a = _pos(q10) * w, b = _pos(q90) * w, m = _pos(q50) * w;
              return SizedBox(
                height: 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: c.surface2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: a,
                      width: math.max(2, b - a),
                      top: 4,
                      height: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Positioned(
                      left: m - 6,
                      top: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: FsSpace.s1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fmt.sig(axisMin), style: context.text.labelSmall),
              Text(
                '${fmt.sig(axisMax)} ${l.unitMmS}',
                style: context.text.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: FsSpace.s1),
          Text(
            l.labRange80(fmt.sig(q10), fmt.sig(q90)),
            style: context.text.labelSmall,
          ),
        ],
      ),
    );
  }
}
