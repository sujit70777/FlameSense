import 'package:flutter/material.dart';

import '../core/breakpoints.dart';
import '../core/theme/tokens.dart';
import 'page_header.dart';

/// Scrolling page body: responsive margins, max width, page header (DESIGN.md §8).
class FsPage extends StatelessWidget {
  const FsPage({
    super.key,
    required this.children,
    this.title,
    this.description,
    this.actions = const [],
    this.maxWidth = FsSize.contentMaxTool,
    this.controller,
  });

  final String? title, description;
  final List<Widget> actions;
  final List<Widget> children;
  final double maxWidth;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final size = FsWidth.of(context);
    return SingleChildScrollView(
      controller: controller,
      padding: EdgeInsets.symmetric(
        horizontal: size.margin,
        vertical: size.isCompact ? FsSpace.s6 : FsSpace.s8,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                PageHeader(
                  title: title!,
                  description: description,
                  actions: actions,
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
