import 'package:flutter/material.dart';

/// Tooltip styled by the theme (DESIGN.md §9.11): 400 ms delay, below by default.
class FsTooltip extends StatelessWidget {
  const FsTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Tooltip(message: message, preferBelow: true, child: child);
}
