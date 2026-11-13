import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/colors.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// Solid panel surface with optional header (DESIGN.md §6, §9.5). Never nest panels.
class FsPanel extends StatelessWidget {
  const FsPanel({
    super.key,
    required this.child,
    this.title,
    this.actions = const [],
    this.padding,
    this.background,
    this.semanticLabel,
  });

  final Widget child;
  final String? title;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  /// Override fill (e.g. `emberTint` over `surface1` for the Earth compare column).
  final Color? background;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final pad =
        padding ??
        EdgeInsets.all(FsWidth.of(context).isCompact ? FsSpace.s4 : FsSpace.s6);
    final radius = BorderRadius.circular(FsRadius.lg);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || actions.isNotEmpty) ...[
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title!, style: context.text.titleLarge),
                  ),
                )
              else
                const Spacer(),
              ...actions,
            ],
          ),
          const SizedBox(height: FsSpace.s4),
        ],
        child,
      ],
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface1,
          borderRadius: radius,
          border: Border.all(color: c.outline),
          boxShadow: c.isDark
              ? null
              : const [
                  BoxShadow(
                    color: FsFixedColors.panelShadowLight,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              if (background != null)
                Positioned.fill(child: ColoredBox(color: background!)),
              if (c.isDark)
                const Positioned(
                  top: 0,
                  left: FsRadius.lg,
                  right: FsRadius.lg,
                  height: 1,
                  child: ColoredBox(color: FsFixedColors.panelHighlightDark),
                ),
              Padding(padding: pad, child: body),
            ],
          ),
        ),
      ),
    );
  }
}
