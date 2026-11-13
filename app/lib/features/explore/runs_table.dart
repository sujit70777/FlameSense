import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'explore_filters.dart';
import 'explore_providers.dart';
import 'table_cells.dart';

/// Virtualized, sortable runs table with a sticky header and pinned Run column (DESIGN.md §9.22).
class RunsTableView extends ConsumerStatefulWidget {
  const RunsTableView({super.key, required this.onOpen, this.firstRowKey});

  final ValueChanged<RunRecord> onOpen;

  /// Tour target (first table row).
  final Key? firstRowKey;

  @override
  ConsumerState<RunsTableView> createState() => _RunsTableState();
}

class _RunsTableState extends ConsumerState<RunsTableView> {
  final _left = ScrollController(),
      _right = ScrollController(),
      _h = ScrollController();
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    void link(ScrollController from, ScrollController to) =>
        from.addListener(() {
          if (_syncing || !to.hasClients || to.offset == from.offset) return;
          _syncing = true;
          to.jumpTo(from.offset);
          _syncing = false;
        });
    link(_left, _right);
    link(_right, _left);
  }

  @override
  void dispose() {
    _left.dispose();
    _right.dispose();
    _h.dispose();
    super.dispose();
  }

  Widget _header(RunColumn c, double w) {
    final l = AppLocalizations.of(context);
    final (sortCol, asc) = ref.watch(exploreSortProvider);
    final active = sortCol == c;
    final fs = context.fs;
    return Semantics(
      button: true,
      label: l.sortBy(columnLabel(l, c)),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => ref.read(exploreSortProvider.notifier).sortBy(c),
        child: Container(
          width: w,
          height: FsSize.tableHeader,
          padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
          child: Row(
            mainAxisAlignment: numericColumns.contains(c)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  columnLabel(l, c),
                  style: context.text.labelLarge!.copyWith(
                    color: fs.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (active)
                Icon(
                  asc
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 16,
                  color: fs.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    RunRecord r,
    List<RunColumn> cols,
    Map<RunColumn, double> w, {
    Key? key,
  }) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    return InkWell(
      key: key,
      onTap: () => widget.onOpen(r),
      hoverColor: context.fs.surface3,
      mouseCursor: SystemMouseCursors.click,
      child: SizedBox(
        height: FsSize.tableRow,
        child: Row(
          children: [
            for (final c in cols)
              Container(
                width: w[c],
                padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
                child: runCell(context, l, fmt, r, c),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final runs = ref.watch(sortedRunsProvider);
    final fs = context.fs;
    return LayoutBuilder(
      builder: (context, box) {
        final total = columnWidths.values.reduce((a, b) => a + b);
        final scale = box.maxWidth > total ? box.maxWidth / total : 1.0;
        final w = columnWidths.map((k, v) => MapEntry(k, v * scale));
        final rest = RunColumn.values.where((c) => c != RunColumn.run).toList();
        final restWidth = rest.fold(0.0, (s, c) => s + w[c]!);
        final divider = Divider(color: fs.outline, height: 1);
        Widget list(ScrollController ctl, List<RunColumn> cols) =>
            ListView.separated(
              controller: ctl,
              itemCount: runs.length,
              separatorBuilder: (_, _) => divider,
              itemBuilder: (context, i) => _row(
                runs[i],
                cols,
                w,
                key: i == 0 && cols.contains(RunColumn.run)
                    ? widget.firstRowKey
                    : null,
              ),
            );
        Widget column(
          List<RunColumn> cols,
          ScrollController ctl,
          double width,
        ) => SizedBox(
          width: width,
          child: Column(
            children: [
              Container(
                color: fs.surface2,
                child: Row(children: [for (final c in cols) _header(c, w[c]!)]),
              ),
              Expanded(child: list(ctl, cols)),
            ],
          ),
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: fs.outline)),
              ),
              child: column(const [RunColumn.run], _left, w[RunColumn.run]!),
            ),
            Expanded(
              child: Scrollbar(
                controller: _h,
                child: SingleChildScrollView(
                  controller: _h,
                  scrollDirection: Axis.horizontal,
                  child: column(rest, _right, restWidth),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
