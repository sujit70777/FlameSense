import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'focus_ring.dart';

/// One option of an [FsSegmented] control.
class FsSegment<T> {
  const FsSegment(this.value, this.label);
  final T value;
  final String label;
}

/// Segmented control, 36 px, equal-width segments (DESIGN.md §9.8).
class FsSegmented<T> extends StatelessWidget {
  const FsSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.semanticLabel,
    this.expand = true,
  });

  final List<FsSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;

  /// Fill the available width (false: size to content, used in the top bar).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final children = [
      for (final s in segments)
        _segment(context, s, s.value == selected, expand),
    ];
    return Semantics(
      label: semanticLabel,
      container: true,
      child: Container(
        // 44 px on compact so each segment meets the touch-target minimum (TODO(Q-12)).
        height: FsWidth.of(context).isCompact
            ? FsSize.touch
            : FsSize.segmentedHeight,
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(FsRadius.sm),
          border: Border.all(color: c.outline),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    FsSegment<T> s,
    bool isSelected,
    bool expand,
  ) {
    final c = context.fs;
    final radius = BorderRadius.circular(FsRadius.sm - 2);
    final body = Semantics(
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: s.label,
      excludeSemantics: true,
      child: FsFocusRing(
        radius: FsRadius.sm - 2,
        child: Material(
          color: isSelected
              ? (c.isDark ? c.surface3 : c.surface1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: isSelected
                ? BorderSide(color: c.outlineStrong)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: () => onChanged(s.value),
            mouseCursor: SystemMouseCursors.click,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
              child: Text(
                s.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge!.copyWith(
                  color: isSelected ? c.textPrimary : c.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return expand ? Expanded(child: body) : body;
  }
}
