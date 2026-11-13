import 'package:flutter/material.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/focus_ring.dart';

/// The six suggested questions (DESIGN.md §11.5).
List<String> suggestedQuestions(AppLocalizations l) => [
  l.askQ1,
  l.askQ2,
  l.askQ3,
  l.askQ4,
  l.askQ5,
  l.askQ6,
];

/// 2-column list of question buttons (1 column on compact).
class SuggestedQuestions extends StatelessWidget {
  const SuggestedQuestions({super.key, required this.onPick, this.firstKey});

  final ValueChanged<String> onPick;

  /// Tour target (step 7).
  final Key? firstKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final qs = suggestedQuestions(l);
    return LayoutBuilder(
      builder: (context, box) {
        final cols = FsWidth.of(context).isCompact ? 1 : 2;
        final w = (box.maxWidth - FsSpace.s3 * (cols - 1)) / cols;
        return Wrap(
          spacing: FsSpace.s3,
          runSpacing: FsSpace.s3,
          children: [
            for (var i = 0; i < qs.length; i++)
              SizedBox(
                key: i == 0 ? firstKey : null,
                width: w,
                child: FsFocusRing(
                  radius: FsRadius.md,
                  child: Material(
                    color: c.surface2,
                    borderRadius: BorderRadius.circular(FsRadius.md),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(FsRadius.md),
                      onTap: () => onPick(qs[i]),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: FsSpace.s4,
                            vertical: FsSpace.s3,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.forum_rounded,
                                size: FsSize.iconInline,
                                color: c.microg,
                              ),
                              const SizedBox(width: FsSpace.s3),
                              Expanded(
                                child: Text(
                                  qs[i],
                                  style: context.text.labelLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
