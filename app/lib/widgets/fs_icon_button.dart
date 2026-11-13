import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import 'focus_ring.dart';

/// 40 × 40 visual, 44 × 44 hit icon button; a tooltip is required (DESIGN.md §9.2).
class FsIconButton extends StatefulWidget {
  const FsIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.onSecondaryTap,
  });

  final IconData icon;

  /// The action, e.g. "Switch to dark theme"; also the semantic label.
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  /// Right-click / long-press action (theme menu, DESIGN.md §9.23).
  final VoidCallback? onSecondaryTap;

  @override
  State<FsIconButton> createState() => _FsIconButtonState();
}

class _FsIconButtonState extends State<FsIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final color = widget.color ?? (_hover ? c.textPrimary : c.textSecondary);
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: SizedBox.square(
          dimension: FsSize.touch,
          child: Center(
            child: FsFocusRing(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.circular(FsRadius.sm),
                  onTap: widget.onPressed,
                  onLongPress: widget.onSecondaryTap,
                  onSecondaryTap: widget.onSecondaryTap,
                  onHover: (h) => setState(() => _hover = h),
                  mouseCursor: widget.onPressed == null
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(
                      widget.icon,
                      size: FsSize.iconAction,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
