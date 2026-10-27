import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_icon_button.dart';

/// Localised name of a theme mode.
String themeModeName(AppLocalizations l, ThemeMode m) => switch (m) {
  ThemeMode.system => l.themeSystem,
  ThemeMode.light => l.themeLight,
  ThemeMode.dark => l.themeDark,
};

/// Icon button cycling System → Light → Dark; right-click/long-press opens all three (DESIGN.md §9.23).
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final mode = ref.watch(settingsProvider).themeMode;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(settingsProvider.notifier);
    return FsIconButton(
      icon: dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
      tooltip: l.themeSwitchTo(themeModeName(l, nextThemeMode(mode))),
      onPressed: notifier.cycleTheme,
      onSecondaryTap: () async {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final origin = box.localToGlobal(Offset.zero);
        final picked = await showMenu<ThemeMode>(
          context: context,
          position: RelativeRect.fromLTRB(
            origin.dx,
            origin.dy + box.size.height,
            origin.dx,
            0,
          ),
          items: [
            for (final m in ThemeMode.values)
              CheckedPopupMenuItem(
                value: m,
                checked: m == mode,
                child: Text(themeModeName(l, m)),
              ),
          ],
        );
        if (picked != null) notifier.setTheme(picked);
      },
    );
  }
}
