import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/breakpoints.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../data/models/lesson.dart';
import '../../domain/gravity.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/gravity_chip.dart';

/// One lesson: "In orbit" half (microg accent) and "On Earth" half (ember accent) (DESIGN.md §11.6).
class LessonRow extends StatelessWidget {
  const LessonRow({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.fs;
    final lang = l.localeName;
    Widget half({
      required Color accent,
      Color? tint,
      required List<Widget> children,
    }) => Container(
      padding: const EdgeInsets.all(FsSpace.s5),
      decoration: BoxDecoration(
        color: tint,
        border: Border(
          left: BorderSide(color: accent, width: FsSize.borderAccent),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
    final orbit = half(
      accent: c.microg,
      children: [
        GravityChip(gravityClass: GravityClass.micro, label: l.earthInOrbit),
        const SizedBox(height: FsSpace.s3),
        Semantics(
          header: true,
          child: Text(
            lesson.text('title', lang),
            style: context.text.titleLarge,
          ),
        ),
        const SizedBox(height: FsSpace.s2),
        Text(lesson.text('space_finding', lang), style: context.text.bodyLarge),
      ],
    );
    final earth = half(
      accent: c.ember,
      tint: c.emberTint,
      children: [
        GravityChip(gravityClass: GravityClass.earth, label: l.earthOnEarth),
        const SizedBox(height: FsSpace.s3),
        Text(lesson.text('earth_meaning', lang), style: context.text.bodyLarge),
        const SizedBox(height: FsSpace.s3),
        Text(l.earthPractice, style: context.text.labelLarge),
        const SizedBox(height: FsSpace.s1),
        Text(lesson.text('what_to_do', lang), style: context.text.bodyLarge),
      ],
    );
    final compact = FsWidth.of(context).isCompact;
    return Container(
      decoration: BoxDecoration(
        color: c.surface1,
        borderRadius: BorderRadius.circular(FsRadius.lg),
        border: Border.all(color: c.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!lesson.isApproved)
            Container(
              color: c.warnTint,
              padding: const EdgeInsets.all(FsSpace.s2),
              child: Text(lesson.status, style: context.text.labelSmall),
            ),
          if (compact) ...[
            orbit,
            earth,
          ] else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: orbit),
                  Expanded(child: earth),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(FsSpace.s3),
            child: Wrap(
              spacing: FsSpace.s2,
              children: [
                for (final s in lesson.sources.where((s) => s.url.isNotEmpty))
                  FsButton(
                    label: s.label.isEmpty ? s.url : s.label,
                    icon: Icons.open_in_new_rounded,
                    variant: FsButtonVariant.ghost,
                    size: FsButtonSize.sm,
                    semanticLabel: '${s.label}. ${l.openInNewTab}',
                    onPressed: () => launchUrl(
                      Uri.parse(s.url),
                      webOnlyWindowName: '_blank',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
