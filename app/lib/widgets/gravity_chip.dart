import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../domain/gravity.dart';

/// Color of a gravity class (DESIGN.md §10.2).
Color gravityColor(BuildContext context, GravityClass g) => switch (g) {
  GravityClass.micro => context.fs.microg,
  GravityClass.partial => context.fs.partial,
  GravityClass.earth => context.fs.ember,
};

/// Read-only pill: 8 px dot + label, e.g. "ISS orbit (10⁻⁶ g)" (DESIGN.md §9.4).
class GravityChip extends StatelessWidget {
  const GravityChip({
    super.key,
    required this.gravityClass,
    required this.label,
  });

  final GravityClass gravityClass;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    return Container(
      constraints: const BoxConstraints(minHeight: FsSize.badgeHeight),
      padding: const EdgeInsets.symmetric(horizontal: FsSpace.s3),
      decoration: ShapeDecoration(
        shape: StadiumBorder(side: BorderSide(color: c.outline)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: gravityColor(context, gravityClass),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: FsSpace.s2),
          Flexible(child: Text(label, style: context.text.labelLarge)),
        ],
      ),
    );
  }
}
