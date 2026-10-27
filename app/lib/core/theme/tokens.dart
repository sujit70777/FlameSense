import 'package:flutter/animation.dart';

/// Spacing (DESIGN.md §5.1).
abstract final class FsSpace {
  static const s1 = 4.0,
      s2 = 8.0,
      s3 = 12.0,
      s4 = 16.0,
      s5 = 20.0,
      s6 = 24.0,
      s8 = 32.0,
      s10 = 40.0,
      s12 = 48.0,
      s16 = 64.0,
      s20 = 80.0;
}

/// Radii (DESIGN.md §5.2).
abstract final class FsRadius {
  static const xs = 6.0,
      sm = 10.0,
      md = 14.0,
      lg = 20.0,
      xl = 28.0,
      pill = 999.0;
}

/// Motion (DESIGN.md §7).
abstract final class FsMotion {
  static const fast = Duration(milliseconds: 120),
      base = Duration(milliseconds: 200),
      slow = Duration(milliseconds: 320),
      ignite = Duration(milliseconds: 700),
      value = Duration(milliseconds: 260);

  /// Flame animation loop (DESIGN.md §9.20).
  static const flameLoop = Duration(seconds: 4);

  /// Loading mark pulse (DESIGN.md §11.0).
  static const pulse = Duration(milliseconds: 1600);

  /// Skeleton shimmer sweep (DESIGN.md §9.13).
  static const shimmer = Duration(milliseconds: 1200);

  /// Citation source pulse highlight (DESIGN.md §9.10).
  static const citationPulse = Duration(milliseconds: 900);

  /// 404 flame drift loop (DESIGN.md §11.9).
  static const drift = Duration(seconds: 6);

  /// Space flame ignition delay after the Earth flame (DESIGN.md §7 mIgnite).
  static const igniteStagger = Duration(milliseconds: 120);

  /// Tooltip delay (DESIGN.md §9.11).
  static const tooltipWait = Duration(milliseconds: 400);

  /// Toast auto-dismiss (DESIGN.md §9.21).
  static const toast = Duration(seconds: 4);

  static const curveFast = Curves.easeOut;
  static const curveBase = Cubic(0.2, 0, 0, 1);
  static const curveIgnite = Cubic(0.16, 1, 0.3, 1);
  static const curveValue = Curves.easeOutCubic;

  /// [d], or zero when reduced motion is on (DESIGN.md §7 rules).
  static Duration of(Duration d, {required bool reduced}) =>
      reduced ? Duration.zero : d;
}

/// Breakpoints (DESIGN.md §8.1).
abstract final class FsBreak {
  static const compact = 600.0, expanded = 1024.0, large = 1280.0, xl = 1600.0;
}

/// Fixed sizes (DESIGN.md §5.3, §8, §9).
abstract final class FsSize {
  static const touch = 44.0;
  static const buttonMd = 44.0, buttonSm = 36.0, input = 44.0;
  static const topBar = 64.0, topBarCompact = 56.0;
  static const railExpanded = 248.0,
      railCompact = 80.0,
      railItem = 44.0,
      railBrand = 72.0;
  static const bottomNav = 72.0;
  static const iconButton = 18.0,
      iconInline = 20.0,
      iconNav = 22.0,
      iconAction = 24.0,
      iconEmpty = 40.0;
  static const sliderThumb = 20.0, sliderTrack = 4.0;
  static const pointDefault = 4.0, pointHover = 6.0, pointMap = 7.0;
  static const chipHeight = 32.0, segmentedHeight = 36.0, badgeHeight = 28.0;
  static const citationChip = 22.0,
      numberField = 96.0,
      numberFieldHeight = 36.0;
  static const tabHeight = 44.0, tableHeader = 40.0, tableRow = 44.0;
  static const focusRingWidth = 2.0, focusRingOffset = 2.0;
  static const contentMaxTool = 1440.0,
      contentMaxHome = 1200.0,
      readingColumn = 720.0;
  static const bodyMaxWidth = 640.0, emptyBodyMaxWidth = 420.0;
  static const dialogMaxRun = 640.0, dialogMaxConfirm = 480.0;
  static const toastMaxWidth = 420.0, tooltipMaxWidth = 280.0;
  static const brandMarkLoading = 56.0,
      brandMarkRail = 28.0,
      brandMarkMin = 20.0;
  static const navIndicatorWidth = 56.0, navIndicatorHeight = 32.0;
  static const activeBarWidth = 3.0, activeBarHeight = 20.0;
  static const sheetHandleWidth = 36.0, sheetHandleHeight = 4.0;
  static const borderAccent = 3.0;
}
