import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/data_provenance.dart';
import 'simple_table.dart';

/// "Where the data comes from" (DESIGN.md §11.7 #data).
class MethodsData extends ConsumerWidget {
  const MethodsData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final d = ref.watch(loadedDataProvider);
    final built = DateTime.tryParse(d.meta.buildTimeUtc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          d.meta.nRuns == 0
              ? l.homeDataPending
              : l.methodsDataBody(
                  f.integer(d.meta.nRuns),
                  f.integer(d.meta.nExperiments),
                ),
          style: context.text.bodyLarge,
        ),
        if (built != null)
          Text(
            l.methodsBuild(d.meta.dataVersion, f.date(built)),
            style: context.text.labelSmall,
          ),
        const SizedBox(height: FsSpace.s4),
        if (d.meta.sources.isEmpty)
          Text(l.methodsNoSources, style: context.text.bodyMedium)
        else
          const DataProvenance(),
        const SizedBox(height: FsSpace.s5),
        SimpleTable(
          headers: [l.colFlag, l.colMeaning],
          flex: const [1, 3],
          rows: [
            for (final (flag, desc) in [
              ('ok', l.qualityOkDesc),
              ('estimated', l.qualityEstimatedDesc),
              ('digitized', l.qualityDigitizedDesc),
              ('video_derived', l.qualityVideoDesc),
              ('suspect', l.qualitySuspectDesc),
            ])
              [
                SimpleTable.t(context, l.qualityLabel(flag)),
                SimpleTable.t(context, desc),
              ],
          ],
        ),
      ],
    );
  }
}
