import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_segmented.dart';
import 'language_toggle.dart';
import 'nav_items.dart';
import 'theme_toggle.dart';

/// Content of the compact "More" / ⋯ sheet (DESIGN.md §8.3).
class MoreSheet extends ConsumerWidget {
  const MoreSheet({
    super.key,
    required this.current,
    required this.onSelect,
    required this.onTour,
    this.showSections = true,
  });

  final NavSection current;
  final ValueChanged<NavSection> onSelect;
  final VoidCallback onTour;

  /// False for the top-bar ⋯ menu (tour, theme, language only).
  final bool showSections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final mode = ref.watch(settingsProvider).themeMode;
    Widget row(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool selected = false,
    }) => ListTile(
      minTileHeight: FsSize.touch,
      leading: Icon(
        icon,
        size: FsSize.iconNav,
        color: selected ? c.microg : c.textSecondary,
      ),
      title: Text(
        label,
        style: context.text.labelLarge!.copyWith(
          color: selected ? c.microg : null,
        ),
      ),
      selected: selected,
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(FsSpace.s2, 0, FsSpace.s2, FsSpace.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSections)
            for (final s in NavSection.more)
              row(
                s.icon,
                s.label(l),
                () => onSelect(s),
                selected: s == current,
              ),
          row(Icons.play_circle_rounded, l.takeTour, onTour),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(FsSpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FsSegmented<ThemeMode>(
                  segments: [
                    for (final m in ThemeMode.values)
                      FsSegment(m, themeModeName(l, m)),
                  ],
                  selected: mode,
                  onChanged: ref.read(settingsProvider.notifier).setTheme,
                ),
                const SizedBox(height: FsSpace.s3),
                const LanguageToggle(expand: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
