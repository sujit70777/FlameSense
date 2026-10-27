import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// LabPage page. Placeholder until Phase 10.
class LabPage extends StatelessWidget {
  const LabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.labTitle,
      description: l.labDesc,
      children: const [],
    );
  }
}
