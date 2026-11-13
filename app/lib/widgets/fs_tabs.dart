import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// Text tabs with a 2 px `microg` underline the width of the label (DESIGN.md §9.19).
class FsTabBar extends StatelessWidget implements PreferredSizeWidget {
  const FsTabBar({super.key, required this.labels, this.controller});

  final List<String> labels;
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(FsSize.tabHeight);

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return TabBar(
      controller: controller,
      isScrollable: FsWidth.of(context).isCompact,
      tabAlignment: FsWidth.of(context).isCompact
          ? TabAlignment.start
          : TabAlignment.fill,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: c.microg, width: 2),
      ),
      dividerColor: c.outline,
      labelColor: c.textPrimary,
      unselectedLabelColor: c.textSecondary,
      labelStyle: context.text.labelLarge,
      unselectedLabelStyle: context.text.labelLarge,
      overlayColor: WidgetStatePropertyAll(
        c.textPrimary.withValues(alpha: 0.04),
      ),
      tabs: [for (final l in labels) Tab(height: FsSize.tabHeight, text: l)],
    );
  }
}
