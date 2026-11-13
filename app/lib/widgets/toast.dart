import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// Shows an inverted toast, bottom-center (bottom-right ≥ 1024), 4 s (DESIGN.md §9.21).
void showFsToast(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_rounded,
}) {
  final c = context.fs;
  final width = MediaQuery.sizeOf(context).width;
  final wide = FsWidth.forWidth(width).hasRail;
  final bg = c.isDark ? c.surface3 : c.textPrimary;
  final fg = c.isDark ? c.textPrimary : c.surface1;
  final toastWidth = width - 2 * FsSpace.s4 < FsSize.toastMaxWidth
      ? width - 2 * FsSpace.s4
      : FsSize.toastMaxWidth;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: FsMotion.toast,
        backgroundColor: bg,
        elevation: 0,
        margin: wide
            ? EdgeInsets.only(
                left: width - toastWidth - FsSpace.s6,
                right: FsSpace.s6,
                bottom: FsSpace.s6,
              )
            : EdgeInsets.symmetric(
                horizontal: (width - toastWidth) / 2,
                vertical: FsSpace.s4,
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FsRadius.md),
        ),
        content: Semantics(
          liveRegion: true,
          child: Row(
            children: [
              Icon(icon, size: FsSize.iconButton, color: fg),
              const SizedBox(width: FsSpace.s2),
              Expanded(
                child: Text(
                  message,
                  style: context.text.bodyMedium!.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
