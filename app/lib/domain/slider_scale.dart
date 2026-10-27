import 'dart:math' as math;

/// How an [FsSlider] maps track position (0–1) to value.
enum FsSliderScale {
  linear,

  /// Position ∝ log10(value); min must be > 0 (gravity, thickness).
  log,

  /// Position ∝ log10(value + 1), so 0 is allowed (airflow).
  log1p;

  double _t(double v) => switch (this) {
    FsSliderScale.linear => v,
    FsSliderScale.log => math.log(math.max(v, 1e-12)) / math.ln10,
    FsSliderScale.log1p => math.log(math.max(v, 0) + 1) / math.ln10,
  };

  double _inv(double t) => switch (this) {
    FsSliderScale.linear => t,
    FsSliderScale.log => math.pow(10, t).toDouble(),
    FsSliderScale.log1p => math.pow(10, t).toDouble() - 1,
  };

  /// Track position of [value] in [min, max], clamped to 0–1.
  double toPosition(double value, double min, double max) {
    final a = _t(min), b = _t(max);
    if (b == a) return 0;
    return ((_t(value) - a) / (b - a)).clamp(0.0, 1.0);
  }

  /// Value at track position [p].
  double fromPosition(double p, double min, double max) {
    final a = _t(min), b = _t(max);
    return _inv(a + p.clamp(0.0, 1.0) * (b - a)).clamp(min, max);
  }
}
