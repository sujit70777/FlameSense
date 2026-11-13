import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/missions_file.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_panel.dart';
import 'mission_row.dart';

/// Citations for a mission's atmosphere (PLAN.md §1.0 "Mission wording"): the
/// mission's own source, and for Moon-base-type atmospheres the challenge
/// statement plus NASA's recommendation, never stated as a NASA plan.
class MissionSources extends ConsumerWidget {
  const MissionSources({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final m = mission;
    final statement = usesStatementAtmosphere(m);
    final recommendation = statement && m.source.contains(kNtrsRecommendation);
    final lines = [
      if (m.isSourced) l.missionSourceAtmosphere(m.source),
      if (statement) l.missionStatementCite,
      if (recommendation) missionRecommendation(l, f, m),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return FsPanel(
      title: l.missionSourcesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final t in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: FsSpace.s2),
              child: Text(t, style: context.text.bodyMedium),
            ),
          if (recommendation)
            FsButton(
              label: l.missionOpenNtrs,
              variant: FsButtonVariant.ghost,
              size: FsButtonSize.sm,
              icon: Icons.open_in_new_rounded,
              onPressed: () => openSource(
                'https://ntrs.nasa.gov/citations/$kNtrsRecommendation',
              ),
            ),
        ],
      ),
    );
  }
}
