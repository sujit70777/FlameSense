import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../domain/predictor.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/inline_notice.dart';

/// Every warning of a prediction as stacked InlineNotices (DESIGN.md §11.3).
class LabNotices extends ConsumerWidget {
  const LabNotices({super.key, required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final spec = ref.watch(loadedDataProvider).featureSpec;
    final notices = <Widget>[];
    for (final w in result.warnings) {
      final Widget? n = switch (w.kind) {
        WarningKind.outsideRange => () {
          final o = w.outside!, s = spec.inputs[o.input]!;
          final scale = s.displayScale;
          return InlineNotice(
            variant: NoticeVariant.warn,
            message: l.noticeOutside(
              l.inputLabel(o.input),
              o.input == 'gravity_g'
                  ? fmt.gravity(o.trainMin)
                  : fmt.sig(o.trainMin * scale),
              o.input == 'gravity_g'
                  ? fmt.gravity(o.trainMax)
                  : fmt.sig(o.trainMax * scale),
              s.displayUnit,
            ),
          );
        }(),
        WarningKind.lowSupport => InlineNotice(
          variant: NoticeVariant.danger,
          message: l.noticeLowSupport,
        ),
        WarningKind.partialGravity => InlineNotice(message: l.noticePartialG),
        WarningKind.sustainUnavailable => InlineNotice(
          message: l.noticeUnavailable(l.outputSustain),
        ),
        WarningKind.spreadUnavailable => InlineNotice(
          message: l.noticeUnavailable(l.outputSpread),
        ),
        WarningKind.quantilesReordered =>
          kDebugMode ? InlineNotice(message: l.noticeQuantiles) : null,
      };
      if (n != null) notices.add(n);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final n in notices)
          Padding(
            padding: const EdgeInsets.only(bottom: FsSpace.s3),
            child: n,
          ),
      ],
    );
  }
}
