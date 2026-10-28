import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current tour step index (0–7), or null when the tour is not running.
class TourController extends Notifier<int?> {
  static const steps = 8;

  @override
  int? build() => null;

  /// Starts at step 1.
  void start() => state = 0;

  /// Next step; finishing after the last step ends the tour.
  void next() =>
      state = state == null ? null : (state! + 1 < steps ? state! + 1 : null);

  /// Previous step (stays on step 1).
  void back() => state = state == null ? null : (state! > 0 ? state! - 1 : 0);

  /// Ends the tour.
  void exit() => state = null;
}

final tourProvider = NotifierProvider<TourController, int?>(TourController.new);
