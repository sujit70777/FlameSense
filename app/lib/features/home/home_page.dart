import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// HomePage page. Placeholder until Phase 8.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.homeHeadline,
      description: l.homeSubhead,
      children: const [],
    );
  }
}
