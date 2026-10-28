import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/platform/browser.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_sheet.dart';
import '../../widgets/grid_background.dart';
import 'bottom_nav.dart';
import 'more_sheet.dart';
import 'nav_items.dart';
import 'nav_rail.dart';
import 'top_bar.dart';
import '../tour/tour_controller.dart';
import '../tour/tour_overlay.dart';

/// Responsive app shell around the StatefulShellRoute branches (DESIGN.md §8).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  NavSection get _current => NavSection.values[shell.currentIndex];

  void _select(NavSection s) =>
      shell.goBranch(s.index, initialLocation: s.index == shell.currentIndex);

  void _tour(WidgetRef ref) => ref.read(tourProvider.notifier).start();

  void _sheet(BuildContext context, WidgetRef ref, {required bool sections}) =>
      showFsSheet<void>(
        context,
        (_) => MoreSheet(
          current: _current,
          onSelect: _select,
          onTour: () => _tour(ref),
          showSections: sections,
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final size = FsWidth.of(context);
    // `?tour=1` (or the "Take the tour" links) start the Judge Tour once, then drop the query.
    if (GoRouterState.of(context).uri.queryParameters['tour'] == '1' &&
        ref.read(tourProvider) == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tourProvider.notifier).start();
        GoRouter.of(context).go(GoRouterState.of(context).uri.path);
      });
    }
    final title = _current.title(l);
    final docTitle = _current == NavSection.home
        ? l.homePageTitle
        : l.pageTitle(title);
    setDocumentTitle(docTitle);
    final bar = TopBar(
      title: title,
      wide: size.hasRail,
      onTour: () => _tour(ref),
      onMenu: () => _sheet(context, ref, sections: false),
    );
    final content = GridBackground(child: shell);
    return Title(
      title: docTitle,
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          Scaffold(
            body: size.hasRail
                ? Row(
                    children: [
                      NavRail(
                        current: _current,
                        onSelect: _select,
                        expanded: size.isLargeUp,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            bar,
                            Expanded(child: content),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SafeArea(bottom: false, child: bar),
                      Expanded(child: content),
                    ],
                  ),
            bottomNavigationBar: size.hasRail
                ? null
                : BottomNav(
                    current: _current,
                    onSelect: _select,
                    onMore: () => _sheet(context, ref, sections: true),
                  ),
          ),
          const Positioned.fill(child: TourOverlay()),
        ],
      ),
    );
  }
}
