import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/features.dart';

import '../../l10n/app_localizations.dart';
import 'nav_items.dart';

/// Bottom navigation on < 1024: Home, Missions, Lab, Map, More (DESIGN.md §8.3);
/// sections whose feature is not ready are left out.
class BottomNav extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final slots = ref.watch(featuresProvider).visible(NavSection.bottom);
    final index = slots.indexOf(current);
    return NavigationBar(
      selectedIndex: index < 0 ? slots.length : index,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) =>
          i == slots.length ? onMore() : onSelect(slots[i]),
      destinations: [
        for (final s in slots)
          NavigationDestination(icon: Icon(s.icon), label: s.label(l)),
        NavigationDestination(
          icon: const Icon(Icons.menu_rounded),
          label: l.navMore,
        ),
      ],
    );
  }
}
