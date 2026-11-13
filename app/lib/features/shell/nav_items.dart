import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Shell sections in StatefulShellRoute branch order (PLAN.md Phase 6 step 5).
enum NavSection {
  home('/', Icons.home_rounded),
  missions('/missions', Icons.rocket_launch_rounded),
  explore('/explore', Icons.table_chart_rounded),
  lab('/lab', Icons.science_rounded),
  map('/map', Icons.layers_rounded),
  ask('/ask', Icons.forum_rounded),
  earth('/earth', Icons.public_rounded),
  methods('/methods', Icons.fact_check_rounded),
  about('/about', Icons.info_rounded);

  const NavSection(this.path, this.icon);

  final String path;
  final IconData icon;

  /// Primary sections above the rail divider (DESIGN.md §8.2).
  static const primary = [home, missions, explore, lab, map, ask];
  static const secondary = [earth, methods, about];

  /// Bottom-nav slots on < 1024 (the fifth is "More").
  static const bottom = [home, missions, lab, map];

  /// Sections reached through "More" on < 1024.
  static const more = [explore, ask, earth, methods, about];

  /// Localised nav label.
  String label(AppLocalizations l) => switch (this) {
    home => l.navHome,
    missions => l.navMissions,
    explore => l.navExplore,
    lab => l.navLab,
    map => l.navMap,
    ask => l.navAsk,
    earth => l.navEarth,
    methods => l.navMethods,
    about => l.navAbout,
  };

  /// Page title used in the top bar and the document title.
  String title(AppLocalizations l) => switch (this) {
    lab => l.labTitle,
    map => l.mapTitle,
    explore => l.exploreTitle,
    missions => l.missionsTitle,
    ask => l.askTitle,
    earth => l.earthTitle,
    _ => label(l),
  };
}
