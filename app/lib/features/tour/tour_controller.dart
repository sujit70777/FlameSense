import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current tour step index, or null when the tour is not running. The number of steps
/// depends on which features are ready (tour_steps.dart), so callers pass it to [next].
class TourController extends Notifier<int?> {
  @override
  int? build() => null;

  /// Starts at step 1.
  void start() => state = 0;

  /// Next step; finishing after the last of [total] steps ends the tour.
  void next(int total) =>
      state = state == null ? null : (state! + 1 < total ? state! + 1 : null);

  /// Previous step (stays on step 1).
  void back() => state = state == null ? null : (state! > 0 ? state! - 1 : 0);

  /// Ends the tour.
  void exit() => state = null;
}

final tourProvider = NotifierProvider<TourController, int?>(TourController.new);
