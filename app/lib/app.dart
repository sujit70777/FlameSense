import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/breakpoints.dart';
import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme/theme.dart';
import 'features/shell/app_data_gate.dart';
import 'l10n/app_localizations.dart';

/// Root widget: themes per width/locale, localisation, router and the data gate.
class FlameSenseApp extends ConsumerWidget {
  const FlameSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    final bn = settings.locale == 'bn';
    return LayoutBuilder(
      builder: (context, box) {
        final compact = FsWidth.forWidth(box.maxWidth).isCompact;
        return MaterialApp.router(
          title: 'FlameSense',
          debugShowCheckedModeBanner: false,
          theme: buildLightTheme(compact: compact, bn: bn),
          darkTheme: buildDarkTheme(compact: compact, bn: bn),
          themeMode: settings.themeMode,
          locale: Locale(settings.locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: router,
          builder: (context, child) =>
              AppDataGate(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
