import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/tokens.dart';

/// Extends the tap area of a smaller control to 44 px tall on compact widths
/// without changing its visual size (DESIGN.md §5.3, AUDIT §6 touch targets).
class HitTarget extends StatelessWidget {
  const HitTarget({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!FsWidth.of(context).isCompact || onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      excludeFromSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: FsSize.touch),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          heightFactor: 1,
          child: child,
        ),
      ),
    );
  }
}
