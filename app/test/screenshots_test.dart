// Screenshots for docs/img/screens and the Open Graph image (PLAN.md Phase 14 step 6, DESIGN.md §15).
// Run: flutter test --update-goldens --dart-define=FS_SCREENSHOTS=true test/screenshots_test.dart
import 'dart:io';

import 'package:flamesense/core/theme/fs_theme_ext.dart';
import 'package:flamesense/core/theme/theme.dart';
import 'package:flamesense/core/theme/typography.dart';
import 'package:flamesense/l10n/app_localizations.dart';
import 'package:flamesense/widgets/brand_mark.dart';
import 'package:flamesense/widgets/flame_twin/flame_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_app.dart';

const enabled = bool.fromEnvironment('FS_SCREENSHOTS');

const pages = {
  'home': '/',
  'missions': '/missions',
  'explore': '/explore',
  'lab': '/lab',
  'map': '/map',
  'ask': '/ask',
  'earth': '/earth',
  'methods': '/methods',
  'about': '/about',
  'not_found': '/nope',
};

Future<void> loadIcons() async {
  final sdk = Directory(Platform.resolvedExecutable)
      .parent
      .parent
      .parent
      .parent
      .parent
      .path;
  final candidates = [
    '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/opt/homebrew/share/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final p in candidates) {
    if (File(p).existsSync()) {
      final loader = FontLoader(
        'MaterialIcons',
      )..addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
      await loader.load();
      return;
    }
  }
}

void main() {
  setUpAll(loadIcons);

  for (final (w, h) in [(1440.0, 900.0), (390.0, 844.0)]) {
    for (final theme in ['light', 'dark']) {
      for (final e in pages.entries) {
        testWidgets('screenshot ${e.key} $theme ${w.toInt()}', (tester) async {
          await pumpApp(
            tester,
            location: e.value,
            width: w,
            height: h,
            fixtures: false,
            prefs: {'fs.theme': theme},
          );
          await settle(tester, frames: 20);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '../../docs/img/screens/${e.key}_${theme}_${w.toInt()}.png',
            ),
          );
        }, skip: !enabled);
      }
    }
  }

  testWidgets('open graph image', (tester) async {
    await loadAppFonts();
    setWindow(tester, 1200, 630);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildDarkTheme(compact: false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Material(child: _OgCard()),
      ),
    );
    await tester.pump();
    await expectLater(find.byType(_OgCard), matchesGoldenFile('../web/og.png'));
  }, skip: !enabled);
}

class _OgCard extends StatelessWidget {
  const _OgCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ColoredBox(
      color: context.fs.chamberBg,
      child: Padding(
        padding: const EdgeInsets.all(64),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandLockup(markSize: 56),
                  const SizedBox(height: 28),
                  Text(l.tagline, style: context.text.headlineLarge),
                ],
              ),
            ),
            for (final g in [1.0, 1e-6])
              SizedBox(
                width: 220,
                height: 420,
                child: CustomPaint(
                  painter: FlamePainter(gravityG: g, phase: 0, animate: false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
