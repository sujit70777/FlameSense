import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import 'flame_painter.dart';

/// Animated flame for [gravityG] (DESIGN.md §9.20). The 4 s loop pauses when
/// the route is offstage (TickerMode) and is fully static in reduced motion.
class FlameTwin extends StatefulWidget {
  const FlameTwin({
    super.key,
    required this.gravityG,
    this.intro = 1,
    this.semanticLabel,
  });

  final double gravityG;

  /// Ignition progress 0–1 (Home's first visit only).
  final double intro;
  final String? semanticLabel;

  @override
  State<FlameTwin> createState() => FlameTwinState();
}

/// State exposed so tests can check the controller is idle in reduced motion.
class FlameTwinState extends State<FlameTwin>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: FsMotion.flameLoop,
  );

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  void _sync() {
    // No buoyant flicker in microgravity, so no need to tick there either.
    final flickers = FlamePainter.buoyancy(widget.gravityG) > 0.25;
    if (_reduced || !flickers) {
      controller.stop();
    } else if (!controller.isAnimating) {
      controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FlameTwin oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = FlamePainter.buoyancy(widget.gravityG);
    final shape = b > 0.75
        ? l.flameShapeEarth
        : (b < 0.25 ? l.flameShapeSpace : l.flameShapeMid);
    final label =
        widget.semanticLabel ??
        l.flameSemantics(
          gravityLabel(widget.gravityG, l, FsFormat(l.localeName)),
          shape,
        );
    return Semantics(
      image: true,
      label: label,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: FlamePainter(
              gravityG: widget.gravityG,
              phase: controller.value,
              animate: !_reduced,
              intro: widget.intro,
            ),
          ),
        ),
      ),
    );
  }
}
