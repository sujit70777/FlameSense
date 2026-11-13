import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'unit_value.dart';

enum ReadoutSize { md, lg, hero }

/// Instrument readout: label, number + unit, optional caption (DESIGN.md §9.6).
class MetricReadout extends StatelessWidget {
  const MetricReadout({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.caption,
    this.size = ReadoutSize.md,
    this.valueColor,
    this.semanticLabel,
  });

  final String label, value, unit;
  final String? caption, semanticLabel;
  final ReadoutSize size;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = switch (size) {
      ReadoutSize.md => context.nums.md,
      ReadoutSize.lg => context.nums.lg,
      ReadoutSize.hero => context.nums.hero,
    };
    return Semantics(
      label:
          semanticLabel ??
          '$label: $value $unit${caption == null ? '' : '. $caption'}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label.isNotEmpty) ...[
            Text(label, style: context.text.bodyMedium),
            const SizedBox(height: FsSpace.s1),
          ],
          // Scales down only when the value is wider than its column (long
          // localized values such as "1,465 of 3,072"); otherwise unchanged.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: UnitValue(
              value: value,
              unit: unit,
              style: style,
              color: valueColor,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: FsSpace.s1),
            Text(
              caption!,
              style: context.text.labelSmall!.copyWith(
                color: context.fs.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
