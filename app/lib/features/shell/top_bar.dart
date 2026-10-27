import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_icon_button.dart';
import 'language_toggle.dart';
import 'theme_toggle.dart';

/// Sticky top bar: page title and global actions (DESIGN.md §8.2, §8.3).
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.title,
    required this.wide,
    required this.onTour,
    required this.onMenu,
  });

  final String title;

  /// ≥ 1024: tour button, theme toggle and language switch; else a ⋯ menu.
  final bool wide;
  final VoidCallback onTour, onMenu;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final l = AppLocalizations.of(context);
    return Container(
      height: wide ? FsSize.topBar : FsSize.topBarCompact,
      padding: EdgeInsets.symmetric(horizontal: wide ? FsSpace.s6 : FsSpace.s3),
      decoration: BoxDecoration(
        color: c.surface1.withValues(alpha: 0.92),
        border: Border(bottom: BorderSide(color: c.outline)),
      ),
      child: Row(
        children: [
          if (!wide) ...[
            const BrandMark(size: FsSize.brandMarkRail),
            const SizedBox(width: FsSpace.s3),
          ],
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: context.text.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (wide) ...[
            FsButton(
              label: l.takeTour,
              icon: Icons.play_circle_rounded,
              variant: FsButtonVariant.secondary,
              size: FsButtonSize.sm,
              onPressed: onTour,
            ),
            const SizedBox(width: FsSpace.s2),
            const ThemeToggle(),
            const SizedBox(width: FsSpace.s2),
            const LanguageToggle(),
          ] else
            FsIconButton(
              icon: Icons.more_horiz_rounded,
              tooltip: l.menuOptions,
              onPressed: onMenu,
            ),
        ],
      ),
    );
  }
}
