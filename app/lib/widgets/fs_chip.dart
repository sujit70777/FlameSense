import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'focus_ring.dart';
import 'hit_target.dart';

/// Filter/toggle chip, optionally a dropdown trigger (DESIGN.md §9.3).
class FsChip extends StatelessWidget {
  const FsChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.dropdown = false,
    this.leading,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected, dropdown;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final fg = selected ? c.microg : c.textSecondary;
    final shape = StadiumBorder(
      side: BorderSide(color: selected ? c.microg : c.outline),
    );
    return HitTarget(
      onTap: onTap,
      child: Semantics(
        button: true,
        toggled: dropdown ? null : selected,
        label: label,
        excludeSemantics: true,
        child: FsFocusRing(
          radius: FsRadius.pill,
          child: Material(
            color: selected ? c.microgTint : Colors.transparent,
            shape: shape,
            child: InkWell(
              customBorder: shape,
              onTap: onTap,
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                constraints: const BoxConstraints(minHeight: FsSize.chipHeight),
                padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected && !dropdown) ...[
                      Icon(Icons.check_rounded, size: 16, color: fg),
                      const SizedBox(width: FsSpace.s1),
                    ],
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: FsSpace.s2),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: context.text.labelLarge!.copyWith(color: fg),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dropdown) ...[
                      const SizedBox(width: FsSpace.s1),
                      Icon(
                        Icons.expand_more_rounded,
                        size: FsSize.iconButton,
                        color: fg,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
