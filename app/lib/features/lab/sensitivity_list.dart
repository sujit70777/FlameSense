import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/providers.dart';
import '../../domain/sensitivity.dart';
import '../../l10n/app_localizations.dart';

/// "What moves the risk": top 4 sensitivity rows with bars (DESIGN.md §9.17).
class SensitivityList extends ConsumerWidget {
  const SensitivityList({super.key});

  /// "2.5 points" for oxygen, else value + unit.
  static String stepText(AppLocalizations l, FsFormat f, SensitivityItem s) =>
      switch (s.input) {
        'o2_mole_fraction' => l.labSensPoints(f.sig(s.step * 100, digits: 2)),
        'pressure_kpa' => '${f.sig(s.step, digits: 2)} ${l.unitKpa}',
        'flow_velocity_mm_s' => '${f.sig(s.step, digits: 2)} ${l.unitMmS}',
        'gravity_g' => '${f.gravity(s.step)} ${l.unitG}',
        'fuel_thickness_mm' => '${f.sig(s.step, digits: 2)} ${l.unitMm}',
        _ => '${f.sig(s.step, digits: 2)} ${l.unitKgM3}',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final c = context.fs;
    final items = ref.watch(sensitivityProvider);
    final onSustain = ref.watch(predictorProvider).sustainAvailable;
    final maxAbs = items.isEmpty
        ? 1.0
        : items.map((e) => e.delta.abs()).reduce((a, b) => a > b ? a : b);
    final bn = l.localeName == 'bn';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l.labSensTitle, style: context.text.titleMedium),
        ),
        const SizedBox(height: FsSpace.s3),
        if (items.isEmpty) Text(l.labSensEmpty, style: context.text.bodyMedium),
        for (final s in items) ...[
          Row(
            children: [
              Icon(
                s.raises
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: FsSize.iconInline,
                color: s.raises ? c.ember : c.microg,
              ),
              const SizedBox(width: FsSpace.s2),
              Text(l.inputLabel(s.input), style: context.text.labelLarge),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: FsSize.iconInline + FsSpace.s2,
            ),
            child: Text(
              l.labSensRow(
                bn
                    ? l.inputLabel(s.input)
                    : l.inputLabel(s.input).toLowerCase(),
                stepText(l, f, s),
                onSustain
                    ? l.labSensPoints(f.signed(s.delta * 100))
                    : l.labSensMmS(f.signed(s.delta)),
              ),
              style: context.text.bodyMedium,
            ),
          ),
          const SizedBox(height: FsSpace.s1),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: maxAbs == 0
                  ? 0
                  : (s.delta.abs() / maxAbs).clamp(0.02, 1.0),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: s.raises ? c.ember : c.microg,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: FsSpace.s3),
        ],
        if (items.isNotEmpty)
          Text(l.labSensCaption, style: context.text.labelSmall),
      ],
    );
  }
}
