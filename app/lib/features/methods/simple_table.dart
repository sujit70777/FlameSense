import 'package:flutter/material.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';

/// Plain reading-column table with a surface2 header (DESIGN.md §9.22 styling).
class SimpleTable extends StatelessWidget {
  const SimpleTable({
    super.key,
    required this.headers,
    required this.rows,
    this.flex,
  });

  final List<String> headers;
  final List<List<Widget>> rows;
  final List<int>? flex;

  /// A text cell.
  static Widget t(BuildContext context, String s, {bool num = false}) => Text(
    s,
    style: num
        ? context.nums.sm
        : context.text.bodyMedium!.copyWith(color: context.fs.textPrimary),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final f = flex ?? List.filled(headers.length, 1);
    Widget row(List<Widget> cells, {Color? bg, bool header = false}) =>
        Container(
          color: bg,
          padding: const EdgeInsets.symmetric(
            horizontal: FsSpace.s3,
            vertical: FsSpace.s2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cells.length; i++)
                Expanded(
                  flex: f[i],
                  child: Padding(
                    padding: const EdgeInsets.only(right: FsSpace.s3),
                    child: cells[i],
                  ),
                ),
            ],
          ),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.outline),
        borderRadius: BorderRadius.circular(FsRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            [
              for (final h in headers)
                Text(
                  h,
                  style: context.text.labelLarge!.copyWith(
                    color: c.textSecondary,
                  ),
                ),
            ],
            bg: c.surface2,
            header: true,
          ),
          for (final r in rows) ...[
            Divider(color: c.outline, height: 1),
            row(r),
          ],
        ],
      ),
    );
  }
}
