import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../domain/support_index.dart';
import '../l10n/app_localizations.dart';

/// Pill showing how much NASA data supports a prediction (DESIGN.md §9.9).
class DataSupportBadge extends StatelessWidget {
  const DataSupportBadge({
    super.key,
    required this.level,
    this.compact = false,
  });

  final SupportLevel level;

  /// Compact form: dot + "high/med/low" (mission table).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final l = AppLocalizations.of(context);
    final (color, tint, icon, text, short, tip) = switch (level) {
      SupportLevel.high => (
        c.success,
        c.successTint,
        Icons.verified_rounded,
        l.supportHigh,
        l.supportShortHigh,
        l.supportHighTip,
      ),
      SupportLevel.medium => (
        c.warn,
        c.warnTint,
        Icons.info_rounded,
        l.supportMedium,
        l.supportShortMedium,
        l.supportMediumTip,
      ),
      SupportLevel.low => (
        c.danger,
        c.dangerTint,
        Icons.report_rounded,
        l.supportLow,
        l.supportShortLow,
        l.supportLowTip,
      ),
    };
    if (compact) {
      return Tooltip(
        message: tip,
        child: Semantics(
          label: text,
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: FsSpace.s2),
              Text(
                short,
                style: context.text.bodyMedium!.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      );
    }
    return Tooltip(
      message: tip,
      child: Semantics(
        label: '$text. $tip',
        excludeSemantics: true,
        child: Container(
          height: FsSize.badgeHeight,
          padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
          decoration: ShapeDecoration(
            color: tint,
            shape: StadiumBorder(side: BorderSide(color: color)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: FsSpace.s2),
              Text(text, style: context.text.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
