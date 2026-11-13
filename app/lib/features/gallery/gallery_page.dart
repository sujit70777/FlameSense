import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/tokens.dart';
import 'gallery_column.dart';

/// Debug-only `/dev/gallery`: every shared widget in every state, light and dark
/// side by side (PLAN.md Phase 6 step 11). Excluded from release by the router.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = FsWidth.of(context).isCompact;
    Widget themed(Brightness b) => Theme(
      data: buildFsTheme(b, compact: compact),
      child: Builder(
        builder: (context) => ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: const Padding(
            padding: EdgeInsets.all(FsSpace.s6),
            child: GalleryColumn(),
          ),
        ),
      ),
    );
    final light = themed(Brightness.light), dark = themed(Brightness.dark);
    return Scaffold(
      body: SingleChildScrollView(
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [light, dark],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: light),
                  Expanded(child: dark),
                ],
              ),
      ),
    );
  }
}
