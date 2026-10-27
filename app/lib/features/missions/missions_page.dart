import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// MissionsPage page. Placeholder until Phase 11B.
class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.missionsTitle,
      description: l.missionsDesc,
      children: const [],
    );
  }
}
