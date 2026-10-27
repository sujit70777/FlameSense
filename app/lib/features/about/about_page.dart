import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// AboutPage page. Placeholder until Phase 13.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.aboutTitle,
      description: l.aboutDesc,
      children: const [],
    );
  }
}
