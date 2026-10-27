import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import '../../domain/gravity.dart';
import '../../widgets/chamber_window.dart';
import '../../widgets/flame_twin/flame_twin.dart';
import '../../widgets/gravity_slider.dart';
import 'hero_readout.dart';
import 'home_providers.dart';

/// Chamber window with the Earth flame and the user's-gravity flame, readouts,
/// the heroSeam and the gravity slider (DESIGN.md §11.1, F1).
class GravityHero extends ConsumerStatefulWidget {
  const GravityHero({super.key, this.targetKey});

  /// Tour spotlight target (gravity slider + window).
  final Key? targetKey;

  @override
  ConsumerState<GravityHero> createState() => _GravityHeroState();
}

class _GravityHeroState extends ConsumerState<GravityHero>
    with SingleTickerProviderStateMixin {
  static final _total = FsMotion.ignite + FsMotion.igniteStagger;
  late final AnimationController _ignite = AnimationController(
    vsync: this,
    duration: _total,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (homeIgnitedThisSession || MediaQuery.disableAnimationsOf(context)) {
      _ignite.value = 1;
    } else if (!_ignite.isAnimating && _ignite.value == 0) {
      homeIgnitedThisSession = true;
      _ignite.forward();
    }
  }

  @override
  void dispose() {
    _ignite.dispose();
    super.dispose();
  }

  double _phase(double start) {
    final t = _ignite.value * _total.inMilliseconds - start;
    return FsMotion.curveIgnite.transform(
      (t / FsMotion.ignite.inMilliseconds).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = ref.watch(homeGravityProvider);
    final compact = FsWidth.of(context).isCompact;
    final c = context.fs;
    final flameSize = compact ? const Size(140, 200) : const Size(260, 340);
    Widget flame(double gravity, double start) => SizedBox.fromSize(
      size: flameSize,
      child: AnimatedBuilder(
        animation: _ignite,
        builder: (context, _) =>
            FlameTwin(gravityG: gravity, intro: _phase(start)),
      ),
    );
    return Column(
      key: widget.targetKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChamberWindow(
          padding: EdgeInsets.all(compact ? FsSpace.s3 : FsSpace.s5),
          child: Column(
            children: [
              FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    flame(kEarthG, 0),
                    flame(g, FsMotion.igniteStagger.inMilliseconds.toDouble()),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: FsSpace.s3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    stops: const [0, 0.5, 0.5, 1],
                    colors: [
                      c.ember.withValues(alpha: 0),
                      c.ember.withValues(alpha: 0.18),
                      c.microg.withValues(alpha: 0.18),
                      c.microg.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              // The chamber is dark in both themes, so its text uses the dark theme.
              Theme(
                data: buildDarkTheme(
                  compact: compact,
                  bn: Localizations.localeOf(context).languageCode == 'bn',
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: HeroReadout(gravityG: kEarthG)),
                    const SizedBox(width: FsSpace.s4),
                    Expanded(child: HeroReadout(gravityG: g, alignEnd: true)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: FsSpace.s4),
        GravitySlider(
          value: g,
          onChanged: ref.read(homeGravityProvider.notifier).set,
        ),
      ],
    );
  }
}
