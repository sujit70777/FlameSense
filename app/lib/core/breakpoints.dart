import 'package:flutter/widgets.dart';

import 'theme/tokens.dart';

/// Layout size classes from DESIGN.md §8.1.
enum FsWidth {
  compact,
  medium,
  expanded,
  large,
  xl;

  /// Size class for a logical [width].
  static FsWidth forWidth(double width) {
    if (width < FsBreak.compact) return FsWidth.compact;
    if (width < FsBreak.expanded) return FsWidth.medium;
    if (width < FsBreak.large) return FsWidth.expanded;
    if (width < FsBreak.xl) return FsWidth.large;
    return FsWidth.xl;
  }

  /// Size class of the current window.
  static FsWidth of(BuildContext context) =>
      forWidth(MediaQuery.sizeOf(context).width);

  /// Page side margin (DESIGN.md §8.1); xl uses the large margin inside a max width.
  double get margin => switch (this) {
    FsWidth.compact => FsSpace.s4,
    FsWidth.medium => FsSpace.s6,
    FsWidth.expanded => FsSpace.s8,
    FsWidth.large || FsWidth.xl => FsSpace.s10,
  };

  /// Grid gutter (DESIGN.md §8.1).
  double get gutter => switch (this) {
    FsWidth.compact => FsSpace.s4,
    FsWidth.medium => FsSpace.s5,
    _ => FsSpace.s6,
  };

  bool get isCompact => this == FsWidth.compact;

  /// True when the app shows the navigation rail (≥ 1024 px).
  bool get hasRail => index >= FsWidth.expanded.index;

  /// True at ≥ 1280 px (three-column tool layouts, expanded rail).
  bool get isLargeUp => index >= FsWidth.large.index;
}
