import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import 'simple_table.dart';

/// One data source as seen in the runs.
class SourceSummary {
  const SourceSummary(
    this.id,
    this.experiments,
    this.runs,
    this.url,
    this.citation,
  );
  final String id, citation;
  final Set<String> experiments;
  final int runs;
  final String? url;
}

/// Sources table rows computed from runs.json (every run carries source_id/citation/url).
List<SourceSummary> sourceSummaries(List<RunRecord> runs) {
  final by = <String, List<RunRecord>>{};
  for (final r in runs) {
    by.putIfAbsent(r.sourceId, () => []).add(r);
  }
  return [
    for (final e in by.entries)
      SourceSummary(
        e.key,
        {for (final r in e.value) r.experiment},
        e.value.length,
        e.value.map((r) => r.sourceUrl).nonNulls.firstOrNull,
        e.value.first.sourceCitation,
      ),
  ]..sort((a, b) => b.runs.compareTo(a.runs));
}

/// "Where the data comes from" (DESIGN.md §11.7 #data).
class MethodsData extends ConsumerWidget {
  const MethodsData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final d = ref.watch(loadedDataProvider);
    final sources = sourceSummaries(d.runs.records);
    final built = DateTime.tryParse(d.meta.buildTimeUtc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.methodsDataBody(
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
        if (sources.isEmpty)
          Text(l.methodsNoSources, style: context.text.bodyMedium)
        else
          SimpleTable(
            headers: [l.colSource, l.colExperiment, l.colRuns, l.colLink],
            flex: const [3, 2, 1, 2],
            rows: [
              for (final s in sources)
                [
                  SimpleTable.t(context, s.citation),
                  SimpleTable.t(context, s.experiments.join(', ')),
                  SimpleTable.t(context, f.integer(s.runs), num: true),
                  s.url == null
                      ? SimpleTable.t(context, l.notAvailable)
                      : FsButton(
                          label: l.runOpenSource,
                          variant: FsButtonVariant.ghost,
                          size: FsButtonSize.sm,
                          onPressed: () => launchUrl(
                            Uri.parse(s.url!),
                            webOnlyWindowName: '_blank',
                          ),
                        ),
                ],
            ],
          ),
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
