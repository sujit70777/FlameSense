import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/colors.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'focus_ring.dart';

enum FsButtonVariant { primary, secondary, ghost, danger }

enum FsButtonSize { md, sm }

/// Button with the four DESIGN.md §9.1 variants, two sizes and a loading state.
class FsButton extends StatelessWidget {
  const FsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FsButtonVariant.primary,
    this.size = FsButtonSize.md,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final FsButtonVariant variant;
  final FsButtonSize size;
  final IconData? icon;
  final bool loading, fullWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final (fill, fg, border) = switch (variant) {
      FsButtonVariant.primary => (c.microgStrong, c.onMicrog, null),
      FsButtonVariant.secondary => (
        Colors.transparent,
        c.textPrimary,
        c.outlineStrong,
      ),
      FsButtonVariant.ghost => (Colors.transparent, c.microg, null),
      FsButtonVariant.danger => (
        c.danger,
        c.isDark ? FsFixedColors.onDangerDark : FsFixedColors.onDangerLight,
        null,
      ),
    };
    final compact = FsWidth.of(context).isCompact;
    final small = size == FsButtonSize.sm;
    final height = small && !compact ? FsSize.buttonSm : FsSize.buttonMd;
    final enabled = onPressed != null && !loading;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FsRadius.sm),
      side: border == null ? BorderSide.none : BorderSide(color: border),
    );
    final labelStyle = context.text.labelLarge!.copyWith(color: fg);
    final content = loading
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: FsSize.iconButton, color: fg),
                const SizedBox(width: FsSpace.s2),
              ],
              Flexible(
                child: Text(
                  label,
                  style: labelStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: Opacity(
        opacity: onPressed == null ? 0.38 : 1,
        child: FsFocusRing(
          child: Material(
            color: fill,
            shape: shape,
            child: InkWell(
              customBorder: shape,
              onTap: enabled ? onPressed : null,
              mouseCursor: enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.forbidden,
              child: Container(
                height: height,
                width: fullWidth ? double.infinity : null,
                padding: EdgeInsets.symmetric(
                  horizontal: small ? 14 : FsSpace.s5,
                ),
                child: Center(
                  widthFactor: fullWidth ? null : 1,
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
