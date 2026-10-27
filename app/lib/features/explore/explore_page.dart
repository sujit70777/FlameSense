import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/inline_notice.dart';
import 'charts_panel.dart';
import 'explore_providers.dart';
import 'explore_skeleton.dart';
import 'filter_bar.dart';
import 'runs_table.dart';

/// Data Explorer: filters, charts, table and run detail (DESIGN.md §11.2, F2).
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key, this.firstRowKey});

  final Key? firstRowKey;

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  // First frame shows the skeleton while the table and charts are built.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  void _open(RunRecord r) =>
      context.go('/explore/run/${Uri.encodeComponent(r.runId)}');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(loadedDataProvider);
    final shown = ref.watch(filteredRunsProvider);
    final children = <Widget>[];
    if (!_ready) {
      children.add(const ExploreSkeleton());
    } else if (data.runs.records.isEmpty) {
      children.add(
        FsPanel(
          child: EmptyState(
            icon: Icons.table_chart_rounded,
            title: l.exploreNoDataTitle, // TODO(Q-5)
            body: l.exploreNoDataBody,
          ),
        ),
      );
    } else {
      children.addAll([
        const FilterBar(),
        const SizedBox(height: FsSpace.s4),
        if (data.meta.nExperiments == 1) ...[
          InlineNotice(message: l.noticeOneExperiment),
          const SizedBox(height: FsSpace.s4),
        ],
        if (shown.isEmpty)
          FsPanel(
            child: EmptyState(
              icon: Icons.filter_alt_off_rounded,
              title: l.exploreEmptyTitle,
              body: l.exploreEmptyBody,
              primaryLabel: l.exploreClear,
              onPrimary: ref.read(exploreFiltersProvider.notifier).clear,
            ),
          )
        else ...[
          ChartsPanel(onOpen: _open),
          const SizedBox(height: FsSpace.s6),
          FsPanel(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 520,
              child: RunsTableView(
                onOpen: _open,
                firstRowKey: widget.firstRowKey,
              ),
            ),
          ),
        ],
      ]);
    }
    return FsPage(
      title: l.exploreTitle,
      description: l.exploreDesc,
      children: children,
    );
  }
}
