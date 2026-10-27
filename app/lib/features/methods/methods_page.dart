import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// MethodsPage page. Placeholder until Phase 13.
class MethodsPage extends StatelessWidget {
  const MethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FsPage(
      title: l.methodsTitle,
      description: l.methodsDesc,
      children: const [],
    );
  }
}
