import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/focus_ring.dart';
import 'nav_items.dart';

/// Left navigation rail, 248 px expanded or 80 px icons-only (DESIGN.md §8.2).
class NavRail extends StatelessWidget {
  const NavRail({
    super.key,
    required this.current,
    required this.onSelect,
    required this.expanded,
  });

  final NavSection current;
  final ValueChanged<NavSection> onSelect;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    Widget item(NavSection s) => _RailItem(
      section: s,
      selected: s == current,
      expanded: expanded,
      onTap: () => onSelect(s),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Container(
        width: expanded ? FsSize.railExpanded : FsSize.railCompact,
        decoration: BoxDecoration(
          color: c.surface1,
          border: Border(right: BorderSide(color: c.outline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: FsSize.railBrand,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? FsSpace.s5 : 0,
                ),
                child: Align(
                  alignment: expanded ? Alignment.centerLeft : Alignment.center,
                  child: BrandLockup(showWordmark: expanded),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: FsSpace.s3,
                  vertical: FsSpace.s2,
                ),
                children: [
                  for (final s in NavSection.primary) item(s),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: FsSpace.s3),
                    child: Divider(),
                  ),
                  for (final s in NavSection.secondary) item(s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.section,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final NavSection section;
  final bool selected, expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final label = section.label(AppLocalizations.of(context));
    final fg = selected ? c.microg : c.textSecondary;
    final radius = BorderRadius.circular(FsRadius.sm);
    final tile = Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: FsFocusRing(
        child: Material(
          color: selected ? c.microgTint : Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            hoverColor: c.surface3,
            onTap: onTap,
            mouseCursor: SystemMouseCursors.click,
            child: SizedBox(
              height: FsSize.railItem,
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      left: 0,
                      top: (FsSize.railItem - FsSize.activeBarHeight) / 2,
                      child: Container(
                        width: FsSize.activeBarWidth,
                        height: FsSize.activeBarHeight,
                        decoration: BoxDecoration(
                          color: c.microg,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
                    child: Row(
                      mainAxisAlignment: expanded
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.center,
                      children: [
                        Icon(section.icon, size: FsSize.iconNav, color: fg),
                        if (expanded) ...[
                          const SizedBox(width: FsSpace.s3),
                          Expanded(
                            child: Text(
                              label,
                              style: context.text.labelLarge!.copyWith(
                                color: selected ? c.microg : c.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: FsSpace.s1),
      child: expanded ? tile : Tooltip(message: label, child: tile),
    );
  }
}
