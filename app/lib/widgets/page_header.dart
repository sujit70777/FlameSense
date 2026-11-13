import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// Page header for all pages except Home: h1, description, optional actions (DESIGN.md §8.4).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.description,
    this.actions = const [],
  });

  final String title;
  final String? description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final wide = FsWidth.of(context).hasRail;
    final heading = Semantics(
      header: true,
      child: Text(title, style: context.text.headlineLarge),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: FsSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide && actions.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: heading),
                Wrap(spacing: FsSpace.s3, children: actions),
              ],
            )
          else
            heading,
          if (description != null) ...[
            const SizedBox(height: FsSpace.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: FsSize.bodyMaxWidth),
              child: Text(
                description!,
                style: context.text.bodyLarge!.copyWith(
                  color: context.fs.textSecondary,
                ),
              ),
            ),
          ],
          if (!wide && actions.isNotEmpty) ...[
            const SizedBox(height: FsSpace.s4),
            Wrap(
              spacing: FsSpace.s3,
              runSpacing: FsSpace.s3,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
