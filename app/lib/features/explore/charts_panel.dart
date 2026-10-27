import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/fs_tabs.dart';
import 'burning_chart.dart';
import 'explore_providers.dart';
import 'runs_bar_chart.dart';
import 'spread_chart.dart';

/// Chart tabs panel, 440 px tall (320 compact) (DESIGN.md §11.2).
class ChartsPanel extends ConsumerWidget {
  const ChartsPanel({super.key, required this.onOpen});

  final ValueChanged<RunRecord> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final runs = ref.watch(filteredRunsProvider);
    final compact = FsWidth.of(context).isCompact;
    return FsPanel(
      child: DefaultTabController(
        length: 3,
        child: SizedBox(
          height: compact ? 320 : 440,
          child: Column(
            children: [
              FsTabBar(
                labels: [
                  l.exploreTabSpread,
                  l.exploreTabBurning,
                  l.exploreTabRuns,
                ],
              ),
              const SizedBox(height: FsSpace.s4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: FsSpace.s4,
                    top: FsSpace.s4,
                  ),
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      SpreadChart(runs: runs, onOpen: onOpen),
                      BurningChart(runs: runs, onOpen: onOpen),
                      RunsBarChart(runs: runs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
