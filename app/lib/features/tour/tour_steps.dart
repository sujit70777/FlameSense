import 'package:flutter/widgets.dart';

import '../../data/models/missions_file.dart';
import '../../domain/missions.dart';
import '../../l10n/app_localizations.dart';
import 'tour_targets.dart';

/// One tour step: route, spotlight target, caption.
class TourStep {
  const TourStep(this.route, this.target, this.title, this.body);
  final String route;
  final GlobalKey target;
  final String title, body;
}

/// The 8 steps (DESIGN.md §11.10). Step 5 falls back to the Missions list when the
/// Artemis lunar habitat preset is not sourced yet.
List<TourStep> tourSteps(AppLocalizations l, MissionsFile missions) {
  final lunar = visibleMissions(missions).any((m) => m.id == 'artemis_lunar');
  return [
    TourStep('/', TourTargets.homeHero, l.tour1Title, l.tour1Body),
    TourStep('/lab', TourTargets.labConditions, l.tour2Title, l.tour2Body),
    TourStep('/lab', TourTargets.labPrediction, l.tour3Title, l.tour3Body),
    TourStep('/map', TourTargets.map, l.tour4Title, l.tour4Body),
    lunar
        ? TourStep(
            '/missions/artemis_lunar',
            TourTargets.mission,
            l.tour5Title,
            l.tour5Body,
          )
        : TourStep(
            '/missions',
            TourTargets.missions,
            l.tour5Title,
            l.tour5Body,
          ),
    TourStep('/explore', TourTargets.exploreRow, l.tour6Title, l.tour6Body),
    TourStep('/ask', TourTargets.askFirst, l.tour7Title, l.tour7Body),
    TourStep('/earth', TourTargets.earthFirst, l.tour8Title, l.tour8Body),
  ];
}
