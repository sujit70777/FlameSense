import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// A number with its unit, baseline aligned, unit in `bodySmall` tertiary (DESIGN.md §4.2).
class UnitValue extends StatelessWidget {
  const UnitValue({
    super.key,
    required this.value,
    required this.unit,
    this.style,
    this.color,
  });

  final String value, unit;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final s = (style ?? context.nums.sm).copyWith(color: color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(value, style: s),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: FsSpace.s1),
          Text(
            unit,
            style: context.text.bodyMedium!.copyWith(
              color: context.fs.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
