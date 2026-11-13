import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../widgets/flame_twin/flame_twin.dart';

/// Small space flame drifting ±6 px horizontally over 6 s; static in reduced motion (DESIGN.md §11.9).
class DriftingFlame extends StatefulWidget {
  const DriftingFlame({super.key});

  @override
  State<DriftingFlame> createState() => _DriftingFlameState();
}

class _DriftingFlameState extends State<DriftingFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: FsMotion.drift,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, child) => Transform.translate(
      offset: Offset(6 * math.sin(2 * math.pi * _c.value), 0),
      child: child,
    ),
    child: const Padding(
      padding: EdgeInsets.all(FsSpace.s8),
      child: FlameTwin(gravityG: kIssG),
    ),
  );
}
