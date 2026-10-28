import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_icon_button.dart';
import 'tour_controller.dart';

/// Caption card placed beside the target: right, else below, else above (DESIGN.md §11.10).
class TourCaption extends ConsumerWidget {
  const TourCaption({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.body,
    required this.target,
    required this.area,
    required this.animate,
  });

  final int step, total;
  final String title, body;
  final Rect? target;
  final Size area;
  final bool animate;

  static const width = 360.0, estHeight = 220.0, gap = FsSpace.s4;

  /// Top-left corner of the card for [target] inside [area].
  static Offset place(Rect? target, Size area) {
    final w = area.width < width + 2 * gap ? area.width - 2 * gap : width;
    Offset clamp(Offset o) => Offset(
      o.dx.clamp(gap, area.width - w - gap),
      o.dy.clamp(gap, area.height - estHeight - gap),
    );
    if (target == null) {
      return clamp(Offset((area.width - w) / 2, (area.height - estHeight) / 2));
    }
    final t = target.inflate(8);
    if (t.right + gap + w + gap <= area.width) {
      return clamp(Offset(t.right + gap, t.top));
    }
    if (t.bottom + gap + estHeight + gap <= area.height) {
      return clamp(Offset(t.left, t.bottom + gap));
    }
    return clamp(Offset(t.left, t.top - gap - estHeight));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(formatProvider);
    final c = context.fs;
    final ctl = ref.read(tourProvider.notifier);
    final last = step == total - 1;
    final pos = place(target, area);
    final w = area.width < width + 2 * gap ? area.width - 2 * gap : width;
    final card = Material(
      color: c.isDark ? c.surface3 : c.surface1,
      borderRadius: BorderRadius.circular(FsRadius.lg),
      elevation: c.isDark ? 0 : 12,
      child: Container(
        width: w,
        padding: const EdgeInsets.all(FsSpace.s5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(FsRadius.lg),
          border: Border.all(color: c.outlineStrong),
        ),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.tourStep(f.integer(step + 1), f.integer(total)),
                      style: context.text.labelSmall,
                    ),
                  ),
                  FsIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l.exitTour,
                    onPressed: ctl.exit,
                  ),
                ],
              ),
              Semantics(
                header: true,
                child: Text(title, style: context.text.titleMedium),
              ),
              const SizedBox(height: FsSpace.s2),
              Text(body, style: context.text.bodyMedium),
              const SizedBox(height: FsSpace.s4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (step > 0)
                    FsButton(
                      label: l.back,
                      variant: FsButtonVariant.ghost,
                      size: FsButtonSize.sm,
                      onPressed: ctl.back,
                    ),
                  const SizedBox(width: FsSpace.s2),
                  FsButton(
                    label: last ? l.finish : l.next,
                    size: FsButtonSize.sm,
                    onPressed: ctl.next,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return AnimatedPositioned(
      duration: animate ? FsMotion.base : Duration.zero,
      curve: FsMotion.curveBase,
      left: pos.dx,
      top: pos.dy,
      child: card,
    );
  }
}
