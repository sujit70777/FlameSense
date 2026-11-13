import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/data_support_badge.dart';

/// Compact sticky result bar shown once the gauge scrolls out of view (DESIGN.md §11.3).
class LabStickyBar extends ConsumerStatefulWidget {
  const LabStickyBar({super.key, required this.scroll, required this.gaugeKey});

  final ScrollController scroll;
  final GlobalKey gaugeKey;

  @override
  ConsumerState<LabStickyBar> createState() => _LabStickyBarState();
}

class _LabStickyBarState extends ConsumerState<LabStickyBar> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    widget.scroll.addListener(_check);
  }

  @override
  void dispose() {
    widget.scroll.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final box =
        widget.gaugeKey.currentContext?.findRenderObject() as RenderBox?;
    final me = context.findRenderObject() as RenderBox?;
    if (box == null || me == null || !box.attached) return;
    final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
    final show = bottom < me.localToGlobal(Offset.zero).dy;
    if (show != _show) setState(() => _show = show);
  }

  @override
  Widget build(BuildContext context) {
    final r = ref.watch(predictionProvider);
    if (!_show || r.sustainProb == null) {
      return const SizedBox(height: 0, width: double.infinity);
    }
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final c = context.fs;
    final pct = f.percentPoints(r.sustainProb!);
    return Material(
      color: c.surface1,
      elevation: 0,
      child: Container(
        height: FsSize.touch + FsSpace.s2,
        padding: const EdgeInsets.symmetric(horizontal: FsSpace.s4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                r.spreadQ50 == null
                    ? l.labStickyNoSpread(pct)
                    : l.labSticky(pct, f.sig(r.spreadQ50!)),
                style: context.text.labelLarge,
              ),
            ),
            DataSupportBadge(level: r.support.level, compact: true),
          ],
        ),
      ),
    );
  }
}
