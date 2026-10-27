import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';

/// The draggable, keyboard-operable track of an [FsSlider] (DESIGN.md §9.7).
class FsSliderTrack extends StatefulWidget {
  const FsSliderTrack({
    super.key,
    required this.position,
    required this.onPosition,
    required this.onKeyStep,
    required this.semanticsLabel,
    required this.semanticsValue,
    required this.semanticsIncreased,
    required this.semanticsDecreased,
    this.activeColorAt,
    this.snapPositions = const [],
    this.enabled = true,
  });

  /// Current position 0–1.
  final double position;

  /// Called with a new position from a drag or tap (snap magnetism applied).
  final ValueChanged<double> onPosition;

  /// Called for keyboard steps: (+1/−1 steps, ×10 with Shift) or ±inf for End/Home.
  final ValueChanged<double> onKeyStep;
  final String semanticsLabel,
      semanticsValue,
      semanticsIncreased,
      semanticsDecreased;

  /// Active track color at a position (gravity slider lerps microg → ember).
  final Color Function(double p)? activeColorAt;

  /// Positions that attract the thumb within 2% of the track while dragging.
  final List<double> snapPositions;
  final bool enabled;

  @override
  State<FsSliderTrack> createState() => _FsSliderTrackState();
}

class _FsSliderTrackState extends State<FsSliderTrack> {
  final _focus = FocusNode(debugLabel: 'FsSliderTrack');
  bool _focused = false;

  static const _pad = FsSize.sliderThumb / 2;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  double _snap(double p) {
    for (final s in widget.snapPositions) {
      if ((p - s).abs() <= 0.02) return s;
    }
    return p;
  }

  void _fromDx(double dx, double width) {
    if (!widget.enabled) return;
    final p = ((dx - _pad) / (width - 2 * _pad)).clamp(0.0, 1.0);
    widget.onPosition(_snap(p));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final k = e.logicalKey;
    double? step;
    if (k == LogicalKeyboardKey.arrowRight || k == LogicalKeyboardKey.arrowUp) {
      step = 1;
    }
    if (k == LogicalKeyboardKey.arrowLeft ||
        k == LogicalKeyboardKey.arrowDown) {
      step = -1;
    }
    if (k == LogicalKeyboardKey.home) step = double.negativeInfinity;
    if (k == LogicalKeyboardKey.end) step = double.infinity;
    if (step == null || !widget.enabled) return KeyEventResult.ignored;
    widget.onKeyStep(step.isFinite && shift ? step * 10 : step);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final keyboard =
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    return Semantics(
      slider: true,
      label: widget.semanticsLabel,
      value: widget.semanticsValue,
      increasedValue: widget.semanticsIncreased,
      decreasedValue: widget.semanticsDecreased,
      enabled: widget.enabled,
      onIncrease: () => widget.onKeyStep(1),
      onDecrease: () => widget.onKeyStep(-1),
      child: Focus(
        focusNode: _focus,
        onKeyEvent: _onKey,
        onFocusChange: (f) => setState(() => _focused = f),
        child: LayoutBuilder(
          builder: (context, box) => MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) {
                _focus.requestFocus();
                _fromDx(d.localPosition.dx, box.maxWidth);
              },
              onHorizontalDragStart: (d) =>
                  _fromDx(d.localPosition.dx, box.maxWidth),
              onHorizontalDragUpdate: (d) =>
                  _fromDx(d.localPosition.dx, box.maxWidth),
              child: SizedBox(
                height: FsSize.touch,
                width: box.maxWidth,
                child: CustomPaint(
                  painter: _TrackPainter(
                    p: widget.position,
                    inactive: c.outline,
                    active:
                        widget.activeColorAt?.call(widget.position) ??
                        c.microgStrong,
                    thumbFill: c.isDark ? c.textPrimary : c.surface1,
                    thumbBorder: c.isDark ? null : c.microgStrong,
                    ring: c.surface1,
                    focus: _focused && keyboard ? c.focusRing : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.p,
    required this.inactive,
    required this.active,
    required this.thumbFill,
    required this.thumbBorder,
    required this.ring,
    required this.focus,
  });

  final double p;
  final Color inactive, active, thumbFill, ring;
  final Color? thumbBorder, focus;

  @override
  void paint(Canvas canvas, Size size) {
    const r = FsSize.sliderThumb / 2, h = FsSize.sliderTrack;
    final y = size.height / 2;
    final x = r + p * (size.width - 2 * r);
    final track = RRect.fromLTRBR(
      r,
      y - h / 2,
      size.width - r,
      y + h / 2,
      const Radius.circular(2),
    );
    canvas.drawRRect(track, Paint()..color = inactive);
    canvas.drawRRect(
      RRect.fromLTRBR(r, y - h / 2, x, y + h / 2, const Radius.circular(2)),
      Paint()..color = active,
    );
    final center = Offset(x, y);
    canvas.drawCircle(center, r + 3, Paint()..color = ring);
    canvas.drawCircle(center, r, Paint()..color = thumbFill);
    if (thumbBorder != null) {
      canvas.drawCircle(
        center,
        r - 1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = thumbBorder!,
      );
    }
    if (focus != null) {
      canvas.drawCircle(
        center,
        r + 3 + FsSize.focusRingOffset,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = FsSize.focusRingWidth
          ..color = focus!,
      );
    }
  }

  @override
  bool shouldRepaint(_TrackPainter o) =>
      o.p != p ||
      o.active != active ||
      o.focus != focus ||
      o.thumbFill != thumbFill;
}
