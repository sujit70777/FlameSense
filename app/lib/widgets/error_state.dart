import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import 'empty_state.dart';

/// Error state: says what failed and what to do, with a retry button (DESIGN.md §9.13).
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title, body, actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: Icons.error_outline_rounded,
    iconColor: context.fs.danger,
    title: title,
    body: body,
    primaryLabel: actionLabel,
    onPrimary: onAction,
  );
}
