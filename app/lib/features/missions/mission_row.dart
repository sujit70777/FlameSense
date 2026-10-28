import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/breakpoints.dart';
import '../../core/format.dart';
import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/missions_file.dart';
import '../../domain/gravity.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chamber_window.dart';
import '../../widgets/flame_twin/flame_painter.dart';
import '../../widgets/focus_ring.dart';
import '../../widgets/fs_button.dart';
import 'mission_providers.dart';

/// "56.5 kPa, 34% oxygen, Moon (0.165 g)".
String missionAtmosphere(AppLocalizations l, FsFormat fmt, Mission m) =>
    l.missionAtmosphere(
      fmt.sig(m.pressureKpa),
      fmt.sig(m.o2 * 100),
      gravityChipLabel(m.gravityG, l, fmt),
    );

/// Opens a mission source: a URL in a new tab; plain citations have nothing to open.
void openSource(String source) {
  final uri = Uri.tryParse(source.trim());
  if (uri != null && uri.hasScheme) launchUrl(uri, webOnlyWindowName: '_blank');
}

/// One mission row: thumbnail, name, atmosphere, source and verdict counts (DESIGN.md §11.11).
class MissionRow extends ConsumerWidget {
  const MissionRow({super.key, required this.mission});

  final Mission mission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final compact = FsWidth.of(context).isCompact;
    final (burn, out, unknown) = verdictCounts(
      ref.watch(missionAssessmentProvider(mission.id)),
    );
    final thumb = SizedBox.square(
      dimension: compact ? 44 : 56,
      child: ChamberWindow(
        radius: FsRadius.sm,
        child: CustomPaint(
          painter: FlamePainter(
            gravityG: mission.gravityG,
            phase: 0,
            animate: false,
          ),
        ),
      ),
    );
    Widget count(int n, String label, {bool warn = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fmt.integer(n),
          style: context.nums.sm.copyWith(color: warn && n > 0 ? c.warn : null),
        ),
        Text(label, style: context.text.labelSmall),
      ],
    );
    final counts = Wrap(
      spacing: FsSpace.s5,
      runSpacing: FsSpace.s2,
      children: [
        count(burn, l.missionCountBurn),
        count(out, l.missionCountOut),
        count(unknown, l.missionCountUnknown, warn: true),
      ],
    );
    final name = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.missionName(mission.nameKey), style: context.text.titleMedium),
        Text(
          missionAtmosphere(l, fmt, mission),
          style: context.text.bodyMedium,
        ),
        if (mission.isSourced)
          Tooltip(
            message: mission.source,
            child: FsButton(
              label: l.missionSource,
              variant: FsButtonVariant.ghost,
              size: FsButtonSize.sm,
              icon: Icons.open_in_new_rounded,
              onPressed: () => openSource(mission.source),
            ),
          )
        else
          Text(
            l.missionUnsourcedDebug,
            style: context.text.labelSmall!.copyWith(color: c.warn),
          ),
        if (compact) ...[const SizedBox(height: FsSpace.s2), counts],
      ],
    );
    return Semantics(
      link: true,
      label:
          '${l.missionName(mission.nameKey)}. ${missionAtmosphere(l, fmt, mission)}',
      child: FsFocusRing(
        radius: FsRadius.xs,
        child: InkWell(
          onTap: () => context.go('/missions/${mission.id}'),
          mouseCursor: SystemMouseCursors.click,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 88),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: FsSpace.s3,
                horizontal: FsSpace.s2,
              ),
              child: Row(
                children: [
                  thumb,
                  const SizedBox(width: FsSpace.s4),
                  Expanded(child: name),
                  if (!compact) ...[const SizedBox(width: FsSpace.s4), counts],
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
