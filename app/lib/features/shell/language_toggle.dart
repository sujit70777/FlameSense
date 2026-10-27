import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_segmented.dart';

/// "EN | বাং" segmented language switch (DESIGN.md §9.23).
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key, this.expand = false});

  final bool expand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return FsSegmented<String>(
      expand: expand,
      semanticLabel: l.langLabel,
      segments: [FsSegment('en', l.langEnglish), FsSegment('bn', l.langBangla)],
      selected: ref.watch(settingsProvider).locale,
      onChanged: ref.read(settingsProvider.notifier).setLocale,
    );
  }
}
