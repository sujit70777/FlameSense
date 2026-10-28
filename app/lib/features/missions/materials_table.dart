import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/data_support_badge.dart';
import '../../widgets/fs_icon_button.dart';
import '../lab/lab_providers.dart';

/// Material table: verdict, worst case, airflow at worst case, support (DESIGN.md §11.12).
class MaterialsTable extends ConsumerWidget {
  const MaterialsTable({super.key, required this.rows});

  final List<MaterialAssessment> rows;

  Color _verdictColor(BuildContext context, Verdict v) => switch (v) {
    Verdict.likelyBurns => context.fs.ember,
    Verdict.likelyOut => context.fs.microg,
    Verdict.unknown => context.fs.warn,
    Verdict.uncertain => context.fs.textSecondary,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final c = context.fs;
    if (rows.isEmpty) {
      return Text(l.missionNoMaterials, style: context.text.bodyMedium);
    }
    const widths = [180.0, 220.0, 110.0, 160.0, 90.0];
    Widget cell(int i, Widget child, {bool end = false}) => SizedBox(
      width: widths[i],
      child: Align(
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
    final header = Container(
      color: c.surface2,
      height: FsSize.tableHeader,
      padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
      child: Row(
        children: [
          cell(
            0,
            Text(
              l.missionMaterial,
              style: context.text.labelLarge!.copyWith(color: c.textSecondary),
            ),
          ),
          cell(
            1,
            Text(
              l.missionVerdict,
              style: context.text.labelLarge!.copyWith(color: c.textSecondary),
            ),
          ),
          cell(
            2,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    l.missionWorstCase,
                    style: context.text.labelLarge!.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ),
                FsIconButton(
                  icon: Icons.info_outline_rounded,
                  tooltip: l.missionWorstCaseTip,
                  onPressed: () {},
                ),
              ],
            ),
            end: true,
          ),
          cell(
            3,
            Text(
              '${l.missionWorstFlow} (${l.unitMmS})',
              style: context.text.labelLarge!.copyWith(color: c.textSecondary),
            ),
            end: true,
          ),
          cell(
            4,
            Text(
              l.missionSupport,
              style: context.text.labelLarge!.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          for (final r in rows) ...[
            InkWell(
              onTap: () => context.go(labPath(r.input)),
              hoverColor: c.surface3,
              child: Container(
                height: FsSize.tableRow,
                padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
                child: Row(
                  children: [
                    cell(
                      0,
                      Text(
                        r.material.name,
                        style: context.text.bodyMedium!.copyWith(
                          color: c.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    cell(
                      1,
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _verdictColor(context, r.verdict),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: FsSpace.s2),
                          Flexible(
                            child: Text(
                              l.verdictLabel(r.verdict),
                              style: context.text.bodyMedium!.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    cell(
                      2,
                      Text(
                        r.verdict == Verdict.unknown || r.worstProb == null
                            ? l.notAvailable
                            : '${f.percentPoints(r.worstProb!)}%',
                        style: context.nums.sm,
                      ),
                      end: true,
                    ),
                    cell(
                      3,
                      Text(
                        r.worstFlowMmS == null
                            ? l.notAvailable
                            : f.sig(r.worstFlowMmS!),
                        style: context.nums.sm,
                      ),
                      end: true,
                    ),
                    cell(
                      4,
                      r.support == null
                          ? Text(l.notAvailable)
                          : DataSupportBadge(level: r.support!, compact: true),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: widths.reduce((a, b) => a + b) + FsSpace.s6,
              height: 1,
              color: c.outline,
            ),
          ],
        ],
      ),
    );
  }
}
