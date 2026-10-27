import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'nav_items.dart';

/// Bottom navigation on < 1024: Home, Missions, Lab, Map, More (DESIGN.md §8.3).
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.current,
    required this.onSelect,
    required this.onMore,
  });

  final NavSection current;
  final ValueChanged<NavSection> onSelect;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final index = NavSection.bottom.indexOf(current);
    return NavigationBar(
      selectedIndex: index < 0 ? NavSection.bottom.length : index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) => i == NavSection.bottom.length
          ? onMore()
          : onSelect(NavSection.bottom[i]),
      destinations: [
        for (final s in NavSection.bottom)
          NavigationDestination(icon: Icon(s.icon), label: s.label(l)),
        NavigationDestination(
          icon: const Icon(Icons.menu_rounded),
          label: l.navMore,
        ),
      ],
    );
  }
}
