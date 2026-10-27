import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/focus_ring.dart';
import '../../widgets/section_header.dart';

/// "Where to go next": a list of whole-row links, not cards (DESIGN.md §11.1).
class NextList extends StatelessWidget {
  const NextList({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = [
      (
        Icons.rocket_launch_rounded,
        l.homeNextMissions,
        l.homeNextMissionsDesc,
        '/missions',
      ),
      (
        Icons.table_chart_rounded,
        l.homeNextExplore,
        l.homeNextExploreDesc,
        '/explore',
      ),
      (Icons.layers_rounded, l.homeNextMap, l.homeNextMapDesc, '/map'),
      (Icons.forum_rounded, l.homeNextAsk, l.homeNextAskDesc, '/ask'),
      (Icons.public_rounded, l.homeNextEarth, l.homeNextEarthDesc, '/earth'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l.homeNextTitle),
        const Divider(),
        for (final (icon, title, desc, path) in rows) ...[
          _Row(
            icon: icon,
            title: title,
            desc: desc,
            onTap: () => context.go(path),
          ),
          const Divider(),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.desc,
    required this.onTap,
  });

  final IconData icon;
  final String title, desc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return Semantics(
      link: true,
      label: '$title. $desc',
      excludeSemantics: true,
      child: FsFocusRing(
        radius: FsRadius.xs,
        child: InkWell(
          onTap: onTap,
          mouseCursor: SystemMouseCursors.click,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FsSpace.s2,
                vertical: FsSpace.s3,
              ),
              child: Row(
                children: [
                  Icon(icon, size: FsSize.iconNav, color: c.microg),
                  const SizedBox(width: FsSpace.s4),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: FsSpace.s4,
                      runSpacing: FsSpace.s1,
                      children: [
                        Text(title, style: context.text.titleMedium),
                        Text(desc, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: FsSize.iconNav,
                    color: c.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
