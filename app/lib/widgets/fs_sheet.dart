import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';

/// Bottom sheet with drag handle, xl top radius, max 90% height (DESIGN.md §9.18).
Future<T?> showFsSheet<T>(BuildContext context, WidgetBuilder builder) {
  final c = context.fs;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: c.scrim,
    backgroundColor: c.isDark ? c.surface3 : c.surface1,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(FsRadius.xl)),
    ),
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: FsSpace.s3),
        Container(
          width: FsSize.sheetHandleWidth,
          height: FsSize.sheetHandleHeight,
          decoration: BoxDecoration(
            color: c.outlineStrong,
            borderRadius: BorderRadius.circular(FsRadius.pill),
          ),
        ),
        const SizedBox(height: FsSpace.s3),
        Flexible(child: SingleChildScrollView(child: builder(ctx))),
      ],
    ),
  );
}
