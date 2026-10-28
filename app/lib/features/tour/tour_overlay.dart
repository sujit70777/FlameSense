import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import 'tour_caption.dart';
import 'tour_controller.dart';
import 'tour_steps.dart';

/// Scrim + spotlight + caption over the whole app while the tour runs (DESIGN.md §11.10).
class TourOverlay extends ConsumerStatefulWidget {
  const TourOverlay({super.key});

  @override
  ConsumerState<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends ConsumerState<TourOverlay> {
  Rect? _target;
  int? _measuredFor;
  final _focus = FocusNode(debugLabel: 'tour');

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _measure(int step, TourStep s, {int attempt = 0}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(tourProvider) != step) return;
      final ctx = s.target.currentContext;
      final me = context.findRenderObject() as RenderBox?;
      if (ctx == null || me == null) {
        if (attempt < 20) _measure(step, s, attempt: attempt + 1);
        if (attempt == 20) setState(() => _target = null);
        return;
      }
      if (attempt == 0) {
        Scrollable.maybeOf(ctx)?.position
            .ensureVisible(ctx.findRenderObject()!);
      }
      final box = ctx.findRenderObject() as RenderBox;
      final rect = box.localToGlobal(Offset.zero, ancestor: me) & box.size;
      setState(() => _target = rect.intersect(Offset.zero & me.size));
      if (attempt < 3) {
        _measure(step, s, attempt: attempt + 1); // settle after scrolling
      }
      _focus.requestFocus();
    });
  }

  KeyEventResult _key(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final t = ref.read(tourProvider.notifier);
    if (e.logicalKey == LogicalKeyboardKey.arrowRight) t.next();
    if (e.logicalKey == LogicalKeyboardKey.arrowLeft) t.back();
    if (e.logicalKey == LogicalKeyboardKey.escape) t.exit();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(tourProvider);
    if (step == null) {
      _measuredFor = null;
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final steps = tourSteps(l, ref.watch(loadedDataProvider).missions);
    final s = steps[step];
    if (_measuredFor != step) {
      _measuredFor = step;
      _target = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final router = GoRouter.of(context);
        if (router.state.uri.path != s.route) router.go(s.route);
        _measure(step, s);
      });
    }
    final c = context.fs;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _key,
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: CustomPaint(
                  painter: _SpotlightPainter(_target, c.scrim, c.microg),
                ),
              ),
            ),
            TourCaption(
              key: ValueKey(step),
              step: step,
              total: steps.length,
              title: s.title,
              body: s.body,
              target: _target,
              area: box.biggest,
              animate: !reduced,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.target, this.scrim, this.border);

  final Rect? target;
  final Color scrim, border;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    if (target == null) {
      canvas.drawPath(full, Paint()..color = scrim);
      return;
    }
    final hole = RRect.fromRectAndRadius(
      target!.inflate(8),
      const Radius.circular(FsRadius.lg),
    );
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, Path()..addRRect(hole)),
      Paint()..color = scrim,
    );
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter o) =>
      o.target != target || o.scrim != scrim;
}
