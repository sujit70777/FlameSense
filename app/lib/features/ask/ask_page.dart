import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// AskPage page. Placeholder until Phase 12.
class AskPage extends StatelessWidget {
  const AskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.askTitle,
      description: l.askDesc,
      children: const [],
    );
  }
}
