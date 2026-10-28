import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/about/about_page.dart';
import '../features/ask/ask_page.dart';
import '../features/earth/earth_page.dart';
import '../features/explore/explore_page.dart';
import '../features/explore/run_detail_page.dart';
import '../features/gallery/gallery_page.dart';
import '../features/home/home_page.dart';
import '../features/lab/lab_page.dart';
import '../features/map/map_page.dart';
import '../features/methods/methods_page.dart';
import '../features/missions/mission_detail_page.dart';
import '../features/missions/missions_page.dart';
import '../features/not_found/not_found_page.dart';
import '../features/shell/app_shell.dart';
import '../features/shell/nav_items.dart';
import '../features/tour/tour_targets.dart';
import 'theme/tokens.dart';

/// Root navigator (dialogs and full-screen detail pages sit above the shell).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Builds a page whose content fades in and rises 8 px (DESIGN.md §7 mSlow).
Page<void> fsPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: FsMotion.slow,
      reverseTransitionDuration: FsMotion.fast,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: FsMotion.curveBase,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.01),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );

GoRoute _section(
  NavSection s,
  Widget page, {
  List<RouteBase> routes = const [],
}) => GoRoute(
  path: s.path,
  pageBuilder: (context, state) => fsPage(state, page),
  routes: routes,
);

/// The app router (PLAN.md Phase 6 step 5).
GoRouter buildRouter({String initialLocation = '/'}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
  errorBuilder: (context, state) => const NotFoundPage(standalone: true),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            _section(NavSection.home, HomePage(heroKey: TourTargets.homeHero)),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _section(
              NavSection.missions,
              MissionsPage(listKey: TourTargets.missions),
              routes: [
                GoRoute(
                  path: ':missionId',
                  pageBuilder: (context, state) => fsPage(
                    state,
                    MissionDetailPage(
                      missionId: state.pathParameters['missionId']!,
                      targetKey:
                          state.pathParameters['missionId'] == 'artemis_lunar'
                          ? TourTargets.mission
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _section(
              NavSection.explore,
              ExplorePage(firstRowKey: TourTargets.exploreRow),
              routes: [
                GoRoute(
                  path: 'run/:runId',
                  parentNavigatorKey: rootNavigatorKey,
                  pageBuilder: (context, state) =>
                      runDetailPage(context, state),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _section(
              NavSection.lab,
              LabPage(
                conditionsKey: TourTargets.labConditions,
                predictionKey: TourTargets.labPrediction,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [_section(NavSection.map, MapPage(mapKey: TourTargets.map))],
        ),
        StatefulShellBranch(
          routes: [
            _section(
              NavSection.ask,
              AskPage(firstQuestionKey: TourTargets.askFirst),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _section(
              NavSection.earth,
              EarthPage(firstLessonKey: TourTargets.earthFirst),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [_section(NavSection.methods, const MethodsPage())],
        ),
        StatefulShellBranch(
          routes: [_section(NavSection.about, const AboutPage())],
        ),
      ],
    ),
    if (!kReleaseMode)
      GoRoute(
        path: '/dev/gallery',
        builder: (context, state) => const GalleryPage(),
      ),
  ],
);

/// Router provider; built once so settings changes don't reset navigation.
final routerProvider = Provider<GoRouter>((ref) => buildRouter());
