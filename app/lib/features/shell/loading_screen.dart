import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/brand_mark.dart';

/// Full-screen asset loading screen matching the HTML splash (DESIGN.md §11.0).
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: FsMotion.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return ColoredBox(
      color: c.bg,
      child: Center(
        child: Semantics(
          liveRegion: true,
          label: AppLocalizations.of(context).loadingData,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => BrandMark(
                  size: FsSize.brandMarkLoading,
                  circleOpacity: reduced ? 1 : 0.6 + 0.4 * _pulse.value,
                ),
              ),
              const SizedBox(height: FsSpace.s4),
              ExcludeSemantics(
                child: Text(
                  AppLocalizations.of(context).loadingData,
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
