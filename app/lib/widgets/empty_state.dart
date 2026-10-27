import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import 'fs_button.dart';

/// Centered empty state: icon, title, body, optional buttons (DESIGN.md §9.13).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.iconColor,
  });

  final IconData icon;
  final String title, body;
  final String? primaryLabel, secondaryLabel;
  final VoidCallback? onPrimary, onSecondary;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(FsSpace.s6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: FsSize.emptyBodyMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: FsSize.iconEmpty,
                color: iconColor ?? c.textTertiary,
              ),
              const SizedBox(height: FsSpace.s4),
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: context.text.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: FsSpace.s2),
              Text(
                body,
                style: context.text.bodyLarge!.copyWith(color: c.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (primaryLabel != null || secondaryLabel != null) ...[
                const SizedBox(height: FsSpace.s5),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: FsSpace.s3,
                  runSpacing: FsSpace.s3,
                  children: [
                    if (secondaryLabel != null)
                      FsButton(
                        label: secondaryLabel!,
                        onPressed: onSecondary,
                        variant: FsButtonVariant.secondary,
                      ),
                    if (primaryLabel != null)
                      FsButton(label: primaryLabel!, onPressed: onPrimary),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
