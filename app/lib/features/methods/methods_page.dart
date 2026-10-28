import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_chip.dart';
import '../../widgets/page_header.dart';
import '../../widgets/section_header.dart';
import '../explore/filter_dialogs.dart';
import 'methods_data.dart';
import 'methods_more.dart';
import 'methods_physics.dart';
import 'methods_predictions.dart';
import 'methods_validation.dart';

/// Section ids (anchors) in page order (DESIGN.md §11.7).
const kMethodsSections = [
  'data',
  'predictions',
  'validation',
  'physics',
  'support',
  'limitations',
  'usability',
  'honesty',
];

/// Methods & honesty (DESIGN.md §11.7, F7). `?s=<section>` scrolls to an anchor.
class MethodsPage extends StatefulWidget {
  const MethodsPage({super.key});

  @override
  State<MethodsPage> createState() => _MethodsPageState();
}

class _MethodsPageState extends State<MethodsPage> {
  final _keys = {
    for (final s in kMethodsSections) s: GlobalKey(debugLabel: 'methods-$s'),
  };
  String? _applied;

  String _title(AppLocalizations l, String s) => switch (s) {
    'data' => l.methodsDataTitle,
    'predictions' => l.methodsPredTitle,
    'validation' => l.methodsValTitle,
    'physics' => l.methodsPhysTitle,
    'support' => l.methodsSupportTitle,
    'limitations' => l.methodsLimitsTitle,
    'usability' => l.methodsUsabilityTitle,
    _ => l.methodsHonestyTitle,
  };

  Widget _body(String s) => switch (s) {
    'data' => const MethodsData(),
    'predictions' => const MethodsPredictions(),
    'validation' => const MethodsValidation(),
    'physics' => const MethodsPhysics(),
    _ => MethodsMore(section: s),
  };

  void _jump(String s) {
    final ctx = _keys[s]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : FsMotion.slow,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = GoRouterState.of(context).uri.queryParameters['s'];
    if (s != null && s != _applied && _keys.containsKey(s)) {
      _applied = s;
      WidgetsBinding.instance.addPostFrameCallback((_) => _jump(s));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final size = FsWidth.of(context);
    final c = context.fs;
    final column = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: FsSize.readingColumn),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: l.methodsTitle, description: l.methodsDesc),
          if (!size.hasRail) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: FsChip(
                label: l.methodsTocLabel,
                dropdown: true,
                onTap: () async {
                  final r = await pickOne<String>(context, l.methodsToc, [
                    for (final s in kMethodsSections) (s, _title(l, s)),
                  ], null);
                  if (r?.$1 != null) _jump(r!.$1!);
                },
              ),
            ),
            const SizedBox(height: FsSpace.s6),
          ],
          for (final s in kMethodsSections)
            Padding(
              key: _keys[s],
              padding: const EdgeInsets.only(bottom: FsSpace.s10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(title: _title(l, s)),
                  _body(s),
                ],
              ),
            ),
        ],
      ),
    );
    final toc = SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.methodsToc,
            style: context.text.labelLarge!.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: FsSpace.s2),
          for (final s in kMethodsSections)
            TextButton(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                minimumSize: const Size(0, FsSize.touch),
              ),
              onPressed: () => _jump(s),
              child: Text(
                _title(l, s),
                style: context.text.bodyMedium!.copyWith(color: c.microg),
              ),
            ),
        ],
      ),
    );
    final pad = EdgeInsets.symmetric(
      horizontal: size.margin,
      vertical: size.isCompact ? FsSpace.s6 : FsSpace.s8,
    );
    final scroll = SingleChildScrollView(
      padding: pad,
      child: Center(child: column),
    );
    if (!size.hasRail) return scroll;
    // Sticky table of contents: it stays put while the reading column scrolls.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: size.margin, top: FsSpace.s8),
          child: toc,
        ),
        Expanded(child: scroll),
      ],
    );
  }
}
