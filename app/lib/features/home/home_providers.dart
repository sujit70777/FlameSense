import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/gravity.dart';

/// Gravity of the hero's right-hand flame (default ISS, DESIGN.md §11.1).
class HomeGravityNotifier extends Notifier<double> {
  @override
  double build() => kIssG;

  /// Sets the hero gravity.
  void set(double g) => state = g;
}

final homeGravityProvider = NotifierProvider<HomeGravityNotifier, double>(
  HomeGravityNotifier.new,
);

/// The ignition moment plays only on the first Home visit per session (DESIGN.md §7).
bool homeIgnitedThisSession = false;
