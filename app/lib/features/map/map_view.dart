import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/run_record.dart';
import '../../l10n/app_localizations.dart';
import 'heatmap_painter.dart';
import 'map_grid.dart';

/// Heatmap with axes, hover, click/tap-to-pin and arrow-key cell navigation.
class MapView extends ConsumerStatefulWidget {
  const MapView({
    super.key,
    required this.grid,
    required this.runs,
    required this.showContour,
    required this.pinned,
    required this.onPin,
    this.onHover,
    this.markers = const [],
    this.aspect = 4 / 3,
  });

  final MapGrid? grid;
  final List<RunRecord> runs;
  final bool showContour;
  final (int, int)? pinned;
  final ValueChanged<(int, int)> onPin;
  final ValueChanged<(int, int)?>? onHover;
  final List<MapMarker> markers;
  final double aspect;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  (int, int)? _hover;

  (int, int) _cell(Offset p, Size s) => (
    (p.dx / s.width * kMapCols).floor().clamp(0, kMapCols - 1),
    ((1 - p.dy / s.height) * kMapRows).floor().clamp(0, kMapRows - 1),
  );

  void _setHover((int, int)? c) {
    setState(() => _hover = c);
    widget.onHover?.call(c);
  }

  KeyEventResult _key(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final (c, r) = widget.pinned ?? (kMapCols ~/ 2, kMapRows ~/ 2);
    final k = e.logicalKey;
    final next = switch (k) {
      LogicalKeyboardKey.arrowLeft => (c - 1, r),
      LogicalKeyboardKey.arrowRight => (c + 1, r),
      LogicalKeyboardKey.arrowUp => (c, r + 1),
      LogicalKeyboardKey.arrowDown => (c, r - 1),
      _ => null,
    };
    if (next == null) return KeyEventResult.ignored;
    widget.onPin((
      next.$1.clamp(0, kMapCols - 1),
      next.$2.clamp(0, kMapRows - 1),
    ));
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final fmt = ref.watch(formatProvider);
    final c = context.fs;
    final g = widget.grid;
    final tick = context.text.labelSmall!;
    final spec = ref.watch(loadedDataProvider).featureSpec;
    final o2 = spec.input('o2_mole_fraction'),
        flow = spec.input('flow_velocity_mm_s');
    final low = g == null ? 0 : g.lowSupport.where((b) => b).length;
    final summary = l.mapSemantics(
      fmt.sig(o2.min * 100),
      fmt.sig(o2.max * 100),
      fmt.sig(flow.min),
      fmt.sig(flow.max),
      fmt.integer(low),
      fmt.integer(kMapCols * kMapRows),
    );
    final map = SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          return MouseRegion(
            cursor: SystemMouseCursors.precise,
            onHover: (e) => _setHover(_cell(e.localPosition, size)),
            onExit: (_) => _setHover(null),
            child: GestureDetector(
              onTapDown: (d) => widget.onPin(_cell(d.localPosition, size)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(FsRadius.xs),
                child: CustomPaint(
                  size: size,
                  painter: HeatmapPainter(
                    grid: g,
                    colors: c,
                    runs: widget.runs,
                    showContour: widget.showContour,
                    pinned: widget.pinned,
                    hover: _hover,
                    markers: widget.markers,
                    labelStyle: tick,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    final yTicks = [
      for (var i = 0; i <= 4; i++) o2.min + (o2.max - o2.min) * i / 4,
    ];
    return Semantics(
      label: summary,
      child: Focus(
        onKeyEvent: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.axisO2, style: context.text.bodyMedium),
            const SizedBox(height: FsSpace.s1),
            LayoutBuilder(
              builder: (context, box) {
                final mapW = box.maxWidth - 36, mapH = mapW / widget.aspect;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 36,
                      height: mapH,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final t in yTicks.reversed)
                            Text(fmt.sig(t * 100), style: tick),
                        ],
                      ),
                    ),
                    SizedBox(width: mapW, height: mapH, child: map),
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, top: FsSpace.s1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i <= 4; i++)
                    Text(
                      fmt.sig(
                        MapGrid.flowScale.fromPosition(
                          i / 4,
                          flow.min,
                          flow.max,
                        ),
                      ),
                      style: tick,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 36, top: FsSpace.s1),
              child: Text(
                l.axisFlow,
                style: context.text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
