import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/breakpoints.dart';
import '../../core/providers.dart';
import '../../core/router.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/fs_button.dart';
import '../../widgets/fs_dialog.dart';
import '../../widgets/fs_page.dart';
import '../not_found/not_found_page.dart';
import 'run_detail_content.dart';
import 'run_to_lab.dart';

/// A go_router page that shows its child as a modal dialog.
class DialogPage<T> extends Page<T> {
  const DialogPage({super.key, required this.child});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
    context: context,
    settings: this,
    barrierColor: context.fs.scrim,
    builder: (_) => child,
  );
}

/// Run detail route: dialog ≥ 1024 px, full page below (PLAN.md Phase 9 step 4).
Page<void> runDetailPage(BuildContext context, GoRouterState state) {
  final id = state.pathParameters['runId']!;
  if (FsWidth.of(context).hasRail) {
    return DialogPage(
      key: state.pageKey,
      child: RunDetail(runId: id, asDialog: true),
    );
  }
  return fsPage(state, RunDetail(runId: id, asDialog: false));
}

/// Looks up the run and renders it, or the not-found page for an unknown id.
class RunDetail extends ConsumerWidget {
  const RunDetail({super.key, required this.runId, required this.asDialog});

  final String runId;
  final bool asDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final run = ref.watch(loadedDataProvider).runs.byId(runId);
    if (run == null) {
      return asDialog
          ? const Dialog(child: SizedBox(height: 520, child: NotFoundPage()))
          : const NotFoundPage(standalone: true);
    }
    void close() => context.canPop() ? context.pop() : context.go('/explore');
    final actions = [
      FsButton(
        label: l.close,
        variant: FsButtonVariant.secondary,
        onPressed: close,
      ),
      FsButton(
        label: l.runLoadLab,
        onPressed: () => context.go(labLinkForRun(run)),
      ),
    ];
    final title = l.runTitle(run.runId);
    if (asDialog) {
      return FsDialog(
        title: title,
        maxWidth: FsSize.dialogMaxRun,
        actions: actions,
        child: RunDetailContent(run: run),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.fs.surface1,
        leading: BackButton(onPressed: close),
      ),
      body: FsPage(
        title: title,
        maxWidth: FsSize.dialogMaxRun,
        children: [
          RunDetailContent(run: run),
          const SizedBox(height: FsSpace.s6),
          Wrap(spacing: FsSpace.s3, runSpacing: FsSpace.s3, children: actions),
        ],
      ),
    );
  }
}
