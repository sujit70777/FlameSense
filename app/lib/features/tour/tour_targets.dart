import 'package:flutter/widgets.dart';

/// Widgets the Judge Tour spotlights (DESIGN.md §11.10). Each key is used once in the tree.
abstract final class TourTargets {
  static final homeHero = GlobalKey(debugLabel: 'tour-home-hero');
  static final labConditions = GlobalKey(debugLabel: 'tour-lab-conditions');
  static final labPrediction = GlobalKey(debugLabel: 'tour-lab-prediction');
  static final map = GlobalKey(debugLabel: 'tour-map');
  static final mission = GlobalKey(debugLabel: 'tour-mission');
  static final missions = GlobalKey(debugLabel: 'tour-missions');
  static final exploreRow = GlobalKey(debugLabel: 'tour-explore-row');
  static final askFirst = GlobalKey(debugLabel: 'tour-ask-first');
  static final earthFirst = GlobalKey(debugLabel: 'tour-earth-first');
}
