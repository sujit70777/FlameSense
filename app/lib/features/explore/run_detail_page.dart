import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_page.dart';

/// Run detail route: dialog ≥ 1024, full page below. Placeholder until Phase 9.
Page<void> runDetailPage(BuildContext context, GoRouterState state) =>
    fsPage(state, RunDetailPage(runId: state.pathParameters['runId']!));

/// Full-page run detail. Placeholder until Phase 9.
class RunDetailPage extends StatelessWidget {
  const RunDetailPage({super.key, required this.runId});

  final String runId;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FsPage(
      title: AppLocalizations.of(context).runTitle(runId),
      children: const [],
    ),
  );
}
