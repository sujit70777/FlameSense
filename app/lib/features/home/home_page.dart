import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../domain/lab_input.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/site_footer.dart';
import 'data_sentence.dart';
import 'gravity_hero.dart';
import 'home_providers.dart';
import 'next_list.dart';
import '../tour/tour_controller.dart';

/// Home: the Gravity Twin hero, data sentence, next steps and footer (DESIGN.md §11.1).
class HomePage extends ConsumerWidget {
  const HomePage({super.key, this.heroKey});

  /// Tour target for step 1.
  final Key? heroKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final size = FsWidth.of(context);
    final g = ref.watch(homeGravityProvider);
    final gText = LabInput.queryNumber(g);
    final headline = Semantics(
      header: true,
      child: Text(l.homeHeadline, style: context.text.displayLarge),
    );
    final sub = Text(
      l.homeSubhead,
      style: context.text.bodyLarge!.copyWith(color: context.fs.textSecondary),
    );
    final ctas = [
      FsButton(
        label: l.homeCtaLab,
        fullWidth: size.isCompact,
        onPressed: () => context.go('/lab?g=$gText'),
      ),
      FsButton(
        label: l.takeTour,
        variant: FsButtonVariant.secondary,
        fullWidth: size.isCompact,
        onPressed: ref.read(tourProvider.notifier).start,
      ),
    ];
    final hero = GravityHero(targetKey: heroKey);
    final top = size.isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headline,
              const SizedBox(height: FsSpace.s4),
              sub,
              const SizedBox(height: FsSpace.s6),
              hero,
              const SizedBox(height: FsSpace.s6),
              ctas[0],
              const SizedBox(height: FsSpace.s3),
              ctas[1],
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headline,
                    const SizedBox(height: FsSpace.s5),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: FsSize.bodyMaxWidth,
                      ),
                      child: sub,
                    ),
                    const SizedBox(height: FsSpace.s8),
                    Wrap(
                      spacing: FsSpace.s3,
                      runSpacing: FsSpace.s3,
                      children: ctas,
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.gutter * 2),
              Expanded(flex: 7, child: hero),
            ],
          );
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: size.margin,
        vertical: size.isCompact ? FsSpace.s6 : FsSpace.s10,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: FsSize.contentMaxHome),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              top,
              const SizedBox(height: FsSpace.s10),
              const DataSentence(),
              const SizedBox(height: FsSpace.s10),
              const NextList(),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
