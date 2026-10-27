import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/fs_theme_ext.dart';
import '../../core/theme/tokens.dart';
import '../../core/theme/typography.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/chamber_window.dart';
import '../../widgets/fs_button.dart';
import 'drifting_flame.dart';

/// "This page drifted off" for any unknown route (DESIGN.md §11.9).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.standalone = false});

  /// True when shown outside the shell (router error page).
  final bool standalone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final body = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(FsSpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 280,
              height: 240,
              child: ChamberWindow(child: DriftingFlame()),
            ),
            const SizedBox(height: FsSpace.s6),
            Semantics(
              header: true,
              child: Text(
                l.notFoundTitle,
                style: context.text.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: FsSpace.s2),
            Text(
              l.notFoundBody,
              style: context.text.bodyLarge!.copyWith(
                color: context.fs.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FsSpace.s6),
            FsButton(
              label: l.notFoundCta,
              onPressed: () => GoRouter.of(context).go('/'),
            ),
          ],
        ),
      ),
    );
    if (!standalone) return body;
    return Title(
      title: l.pageTitle(l.notFoundTitle),
      color: Theme.of(context).colorScheme.primary,
      child: Scaffold(backgroundColor: context.fs.bg, body: body),
    );
  }
}
