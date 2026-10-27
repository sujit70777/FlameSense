import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'fs_button.dart';

enum NoticeVariant { info, warn, danger, success }

/// Tinted inline notice with icon and optional ghost action (DESIGN.md §9.13).
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.message,
    this.variant = NoticeVariant.info,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final NoticeVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final (color, tint, icon) = switch (variant) {
      NoticeVariant.info => (
        c.microg,
        c.microgTint,
        Icons.info_outline_rounded,
      ),
      NoticeVariant.warn => (c.warn, c.warnTint, Icons.warning_amber_rounded),
      NoticeVariant.danger => (c.danger, c.dangerTint, Icons.report_rounded),
      NoticeVariant.success => (
        c.success,
        c.successTint,
        Icons.check_circle_outline_rounded,
      ),
    };
    return Semantics(
      liveRegion: variant != NoticeVariant.info,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: FsSpace.s4,
          vertical: FsSpace.s3,
        ),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(FsRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: FsSize.iconInline, color: color),
            const SizedBox(width: FsSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: context.text.bodyMedium!.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: FsSpace.s2),
                    FsButton(
                      label: actionLabel!,
                      onPressed: onAction,
                      variant: FsButtonVariant.ghost,
                      size: FsButtonSize.sm,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
