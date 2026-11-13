import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/typography.dart';
import '../../data/models/coverage.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../methods/simple_table.dart';

/// Investigation table of the coverage atlas (DESIGN.md §11.2b).
class CoverageTable extends StatelessWidget {
  const CoverageTable({super.key, required this.investigations});

  final List<CoverageInvestigation> investigations;

  /// Width the table needs before it scrolls sideways on compact screens.
  static const _minWidth = 960.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final table = SimpleTable(
      headers: [
        l.coverageColInvestigation,
        l.coverageColTitle,
        l.coverageColPlatform,
        l.coverageColYears,
        l.coverageColRows,
        l.coverageColUsed,
        l.coverageColDoi,
      ],
      flex: const [2, 5, 3, 2, 1, 4, 2],
      rows: [
        for (final i in investigations)
          [
            SimpleTable.t(context, i.label),
            SimpleTable.t(context, i.title),
            SimpleTable.t(
              context,
              i.platform.isEmpty ? l.notAvailable : i.platform,
            ),
            SimpleTable.t(
              context,
              i.years.isEmpty ? l.notAvailable : i.years,
              num: true,
            ),
            SimpleTable.t(context, '${i.rows}', num: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleTable.t(
                  context,
                  i.usedInModels ? l.coverageUsedYes : l.coverageUsedNo,
                ),
                if (!i.usedInModels && i.whyNotUsed.isNotEmpty)
                  Text(
                    i.whyNotUsed,
                    style: context.text.bodySmall!.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
              ],
            ),
            i.doi.isEmpty
                ? SimpleTable.t(context, l.notAvailable)
                : FsButton(
                    label: l.coverageOpenDoi,
                    variant: FsButtonVariant.ghost,
                    size: FsButtonSize.sm,
                    semanticLabel: '${l.coverageOpenDoi} ${i.label}',
                    onPressed: () => launchUrl(
                      Uri.parse('https://doi.org/${i.doi}'),
                      webOnlyWindowName: '_blank',
                    ),
                  ),
          ],
      ],
    );
    if (!FsWidth.of(context).isCompact) return table;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(width: _minWidth, child: table),
    );
  }
}
