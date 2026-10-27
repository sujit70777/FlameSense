import 'package:flutter/material.dart';

import '../../core/theme/tokens.dart';
import '../../widgets/skeleton_block.dart';

/// Loading skeleton: chips, chart block and 8 rows (DESIGN.md §11.2).
class ExploreSkeleton extends StatelessWidget {
  const ExploreSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: FsSpace.s2,
        children: [
          for (var i = 0; i < 6; i++)
            const SkeletonBlock(
              width: 110,
              height: FsSize.chipHeight,
              radius: FsRadius.pill,
            ),
        ],
      ),
      const SizedBox(height: FsSpace.s6),
      const SkeletonBlock(height: 440, radius: FsRadius.lg),
      const SizedBox(height: FsSpace.s6),
      for (var i = 0; i < 8; i++) ...[
        const SkeletonBlock(
          height: FsSize.tableRow - FsSpace.s2,
          radius: FsRadius.xs,
        ),
        const SizedBox(height: FsSpace.s2),
      ],
    ],
  );
}
