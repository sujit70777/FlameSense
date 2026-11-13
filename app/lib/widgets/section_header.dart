import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';

/// `h2` + optional description; no eyebrow (DESIGN.md §9.12).
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FsSpace.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: context.text.headlineMedium),
          ),
          if (description != null) ...[
            const SizedBox(height: FsSpace.s2),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: FsSize.bodyMaxWidth),
              child: Text(
                description!,
                style: context.text.bodyLarge!.copyWith(
                  color: context.text.bodyMedium!.color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
