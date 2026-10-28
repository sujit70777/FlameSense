import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fs_page.dart';
import '../../widgets/fs_panel.dart';
import '../../widgets/inline_notice.dart';
import 'lesson_row.dart';
import 'lessons_filter.dart';

/// Lessons for Earth (DESIGN.md §11.6, F6). Text comes only from the lead's lessons.json.
class EarthPage extends ConsumerWidget {
  const EarthPage({super.key, this.firstLessonKey});

  /// Tour target (step 8).
  final Key? firstLessonKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lessons = visibleLessons(ref.watch(loadedDataProvider).lessons);
    return FsPage(
      title: l.earthTitle,
      description: l.earthDesc,
      maxWidth: FsSize.contentMaxHome,
      children: [
        if (lessons.isEmpty)
          FsPanel(
            key: firstLessonKey,
            child: EmptyState(
              icon: Icons.public_rounded,
              title: l.earthEmptyTitle,
              body: l.earthEmptyBody,
            ),
          )
        else
          for (var i = 0; i < lessons.length; i++) ...[
            LessonRow(key: i == 0 ? firstLessonKey : null, lesson: lessons[i]),
            const SizedBox(height: FsSpace.s5),
          ],
        const SizedBox(height: FsSpace.s4),
        InlineNotice(message: l.earthFooter),
      ],
    );
  }
}
