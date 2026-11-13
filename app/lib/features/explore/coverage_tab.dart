import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/fs_segmented.dart';
import '../../widgets/inline_notice.dart';
import 'coverage_matrix.dart';
import 'coverage_table.dart';

/// "What NASA has tested": coverage matrix + investigation table (DESIGN.md §11.2b, F19).
class CoverageTab extends ConsumerStatefulWidget {
  const CoverageTab({super.key});

  @override
  ConsumerState<CoverageTab> createState() => _CoverageTabState();
}

class _CoverageTabState extends ConsumerState<CoverageTab> {
  String? _pressure;
  (String, String)? _cell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final file = ref.watch(loadedDataProvider).coverage;
    if (file.isEmpty) {
      return FsPanel(
        child: EmptyState(
          icon: Icons.grid_on_rounded,
          title: l.coverageEmptyTitle,
          body: l.coverageEmptyBody,
        ),
      );
    }
    final pressure =
        _pressure ?? file.pressureBands[file.pressureBands.length ~/ 2];
    final cell = _cell == null
        ? null
        : file.cell(_cell!.$1, _cell!.$2, pressure);
    final shown = cell == null
        ? file.investigations
        : file.investigations
              .where((i) => cell.investigations.contains(i.psiId))
              .toList();
    final caption = context.text.bodySmall!.copyWith(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FsPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FsSegmented<String>(
                semanticLabel: l.coveragePressureLabel,
                segments: [
                  for (final b in file.pressureBands)
                    FsSegment(b, l.coveragePressureBand(bandText(b))),
                ],
                selected: pressure,
                onChanged: (b) => setState(() {
                  _pressure = b;
                  _cell = null;
                }),
              ),
              const SizedBox(height: FsSpace.s4),
              CoverageMatrix(
                file: file,
                pressureBand: pressure,
                selected: _cell,
                onSelect: (s) => setState(() => _cell = s),
              ),
              const SizedBox(height: FsSpace.s3),
              Row(
                children: [
                  SizedBox(
                    width: FsSpace.s4,
                    height: FsSpace.s4,
                    child: CustomPaint(painter: HatchPainter(c.textPrimary)),
                  ),
                  const SizedBox(width: FsSpace.s2),
                  Text(l.coverageLegendEmpty, style: caption),
                ],
              ),
              const SizedBox(height: FsSpace.s3),
              Text(l.coverageCaption, style: caption),
              const SizedBox(height: FsSpace.s1),
              Text(
                l.coverageMatrixNote(
                  '${file.rowsInMatrix}',
                  '${file.totalRows}',
                ),
                style: caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: FsSpace.s6),
        if (cell != null) ...[
          InlineNotice(message: l.coverageFilterNotice),
          const SizedBox(height: FsSpace.s2),
          Align(
            alignment: Alignment.centerLeft,
            child: FsButton(
              label: l.coverageFilterClear,
              variant: FsButtonVariant.secondary,
              size: FsButtonSize.sm,
              onPressed: () => setState(() => _cell = null),
            ),
          ),
          const SizedBox(height: FsSpace.s3),
        ],
        FsPanel(
          padding: EdgeInsets.zero,
          child: CoverageTable(investigations: shown),
        ),
      ],
    );
  }
}
