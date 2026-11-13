import 'package:flutter/widgets.dart';

import '../../core/features.dart';
import '../../data/models/missions_file.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import 'tour_targets.dart';

/// One tour step: route, spotlight target, caption.
class TourStep {
  TourStep(this.route, GlobalKey target, this.title, this.body)
    : findTarget = (() => target.currentContext);

  /// Step whose target is looked up when measured (see [TourTargets.mission]).
  TourStep.lookup(this.route, this.findTarget, this.title, this.body);

  final String route;

  /// Context of the spotlit widget, or null while it is not built.
  final BuildContext? Function() findTarget;
  final String title, body;
}

/// The 8 steps (DESIGN.md §11.10), minus steps on pages whose feature is not ready
/// (PLAN.md §1.0). Step 5 falls back to the Missions list when the Artemis lunar
/// habitat preset is not sourced yet.
List<TourStep> tourSteps(
  AppLocalizations l,
  MissionsFile missions,
  FeatureRegistry features,
) {
  final lunar = visibleMissions(missions).any((m) => m.id == 'artemis_lunar');
  final all = [
    TourStep('/', TourTargets.homeHero, l.tour1Title, l.tour1Body),
    TourStep('/lab', TourTargets.labConditions, l.tour2Title, l.tour2Body),
    TourStep('/lab', TourTargets.labPrediction, l.tour3Title, l.tour3Body),
    TourStep('/map', TourTargets.map, l.tour4Title, l.tour4Body),
    lunar
        ? TourStep.lookup(
            '/missions/artemis_lunar',
            () => TourTargets.mission?.currentContext,
            l.tour5Title,
            l.tour5Body,
          )
        : TourStep(
            '/missions',
            TourTargets.missions,
            l.tour5Title,
            l.tour5Body,
          ),
    TourStep(
      '/explore?tab=runs',
      TourTargets.exploreRow,
      l.tour6Title,
      l.tour6Body,
    ),
    TourStep('/ask', TourTargets.askFirst, l.tour7Title, l.tour7Body),
    TourStep('/earth', TourTargets.earthFirst, l.tour8Title, l.tour8Body),
  ];
  return all.where((s) => features.allowsLocation(s.route)).toList();
}
