import 'package:flutter/material.dart';

import '../core/theme/fs_theme_ext.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../l10n/app_localizations.dart';
import 'focus_ring.dart';

/// Numbered citation chip "[1]" linking to a source card (DESIGN.md §9.10).
class CitationChip extends StatelessWidget {
  const CitationChip({
    super.key,
    required this.n,
    required this.tooltip,
    required this.onTap,
  });

  final int n;

  /// Source title + page.
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fs;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FsRadius.xs),
      side: BorderSide(color: c.microg),
    );
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: AppLocalizations.of(context).askCitationSemantics('$n'),
        excludeSemantics: true,
        child: FsFocusRing(
          radius: FsRadius.xs,
          child: Material(
            type: MaterialType.transparency,
            shape: shape,
            child: InkWell(
              customBorder: shape,
              onTap: onTap,
              mouseCursor: SystemMouseCursors.click,
              child: Container(
                height: FsSize.citationChip,
                constraints: const BoxConstraints(
                  minWidth: FsSize.citationChip,
                ),
                padding: const EdgeInsets.symmetric(horizontal: FsSpace.s1),
                alignment: Alignment.center,
                child: Text(
                  '$n',
                  style: context.nums.sm.copyWith(color: c.microg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
