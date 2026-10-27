import 'package:flutter/material.dart';

import 'colors.dart';
import 'fs_theme_ext.dart';
import 'tokens.dart';
import 'typography.dart';

/// Builds the FlameSense ThemeData for [brightness] (DESIGN.md §3, §4, §9).
ThemeData buildFsTheme(
  Brightness brightness, {
  required bool compact,
  bool bn = false,
}) {
  final c = brightness == Brightness.dark ? FsColors.dark : FsColors.light;
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.microgStrong,
    onPrimary: c.onMicrog,
    secondary: c.ember,
    onSecondary: c.onEmber,
    tertiary: c.partial,
    onTertiary: c.bg,
    error: c.danger,
    onError: dark ? FsFixedColors.onDangerDark : FsFixedColors.onDangerLight,
    surface: c.surface1,
    onSurface: c.textPrimary,
    onSurfaceVariant: c.textSecondary,
    surfaceContainerLowest: c.bg,
    surfaceContainerLow: c.surface1,
    surfaceContainer: c.surface2,
    surfaceContainerHigh: c.surface3,
    surfaceContainerHighest: c.surface3,
    outline: c.outlineStrong,
    outlineVariant: c.outline,
    shadow: Colors.black,
    scrim: c.scrim,
    inverseSurface: c.textPrimary,
    onInverseSurface: c.surface1,
    inversePrimary: c.microg,
  );
  final text = fsTextTheme(
    c.textPrimary,
    c.textSecondary,
    c.textTertiary,
    compact: compact,
    bn: bn,
  );
  OutlineInputBorder border(Color col, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(FsRadius.sm),
    borderSide: BorderSide(color: col, width: w),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: 'Archivo',
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
    focusColor: c.focusRing.withValues(
      alpha: 0.0,
    ), // ring is drawn by widgets (§9.0)
    hoverColor: c.textPrimary.withValues(alpha: dark ? 0.06 : 0.04),
    highlightColor: c.textPrimary.withValues(alpha: dark ? 0.10 : 0.08),
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    tooltipTheme: TooltipThemeData(
      waitDuration: FsMotion.tooltipWait,
      constraints: const BoxConstraints(maxWidth: FsSize.tooltipMaxWidth),
      decoration: BoxDecoration(
        color: dark ? c.surface3 : c.textPrimary,
        borderRadius: BorderRadius.circular(FsRadius.sm),
      ),
      textStyle: text.bodyMedium!.copyWith(
        color: dark ? c.textPrimary : c.surface1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: FsSpace.s2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface2,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FsSpace.s3,
        vertical: FsSpace.s3,
      ),
      border: border(c.outline),
      enabledBorder: border(c.outline),
      focusedBorder: border(c.microg),
      errorBorder: border(c.danger),
      focusedErrorBorder: border(c.danger, 1.5),
      hintStyle: text.bodyLarge!.copyWith(color: c.textTertiary),
      errorStyle: text.labelSmall!.copyWith(color: c.danger),
    ),
    sliderTheme: SliderThemeData(
      trackHeight: FsSize.sliderTrack,
      activeTrackColor: c.microgStrong,
      inactiveTrackColor: c.outline,
      thumbColor: dark ? c.textPrimary : c.surface1,
      overlayColor: c.microg.withValues(alpha: 0.12),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: FsSize.sliderThumb / 2,
      ),
      showValueIndicator: ShowValueIndicator.never,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: c.surface1,
      indicatorColor: c.microgTint,
      selectedIconTheme: IconThemeData(color: c.microg, size: FsSize.iconNav),
      unselectedIconTheme: IconThemeData(
        color: c.textSecondary,
        size: FsSize.iconNav,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface1,
      indicatorColor: c.microgTint,
      height: FsSize.bottomNav,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          size: FsSize.iconNav,
          color: s.contains(WidgetState.selected) ? c.microg : c.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelSmall!.copyWith(
          color: s.contains(WidgetState.selected) ? c.microg : c.textSecondary,
        ),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(
        c.outlineStrong.withValues(alpha: 0.7),
      ),
    ),
    extensions: [
      c,
      fsNumbers(c.textPrimary, compact: compact),
    ],
  );
}

/// Light theme ("Lab notebook").
ThemeData buildLightTheme({required bool compact, bool bn = false}) =>
    buildFsTheme(Brightness.light, compact: compact, bn: bn);

/// Dark theme ("Orbit night").
ThemeData buildDarkTheme({required bool compact, bool bn = false}) =>
    buildFsTheme(Brightness.dark, compact: compact, bn: bn);
