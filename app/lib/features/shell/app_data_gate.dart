import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/browser.dart';
import '../../core/providers.dart';
import '../../core/theme/fs_theme_ext.dart';
import '../../data/asset_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/error_state.dart';
import 'loading_screen.dart';

/// Shows the loading screen until every asset is parsed, or the global error screen.
class AppDataGate extends ConsumerWidget {
  const AppDataGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider);
    return data.when(
      skipLoadingOnRefresh: false,
      data: (_) => child,
      loading: () => const LoadingScreen(),
      error: (e, _) {
        final l = AppLocalizations.of(context);
        final file = e is AssetLoadException ? e.file : '?';
        return Material(
          color: context.fs.bg,
          child: ErrorState(
            title: l.loadErrorTitle,
            body: l.loadErrorBody(file),
            actionLabel: l.reload,
            onAction: () {
              reloadPage();
              ref.invalidate(appDataProvider);
            },
          ),
        );
      },
    );
  }
}
