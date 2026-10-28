import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/inline_notice.dart';
import 'mission_providers.dart';
import 'mission_row.dart';

/// Missions list (DESIGN.md §11.11, F11).
class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final missions = ref.watch(visibleMissionsProvider);
    return FsPage(
      title: l.missionsTitle,
      description: l.missionsDesc,
      children: [
        if (missions.isEmpty)
          FsPanel(
            child: EmptyState(
              icon: Icons.rocket_launch_rounded,
              title: l.missionsEmptyTitle,
              body: l.missionsEmptyBody,
            ),
          )
        else ...[
          InlineNotice(message: l.missionsNotice),
          const SizedBox(height: FsSpace.s4),
          FsPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < missions.length; i++) ...[
                  if (i > 0) const Divider(),
                  MissionRow(mission: missions[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
