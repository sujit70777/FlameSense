import 'package:flamesense/core/providers.dart';
import 'package:flamesense/features/gallery/gallery_column.dart';
import 'package:flamesense/features/shell/nav_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('theme toggle cycles and persists across a restart', (
    tester,
  ) async {
    final prefs = await pumpApp(tester);
    expect(find.byTooltip('Switch to Light theme'), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to Light theme'));
    await settle(tester, frames: 5);
    expect(prefs.getString('fs.theme'), 'light');
    // A fresh container reading the same preferences restores the mode.
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    expect(container.read(settingsProvider).themeMode, ThemeMode.light);
  });

  testWidgets('language switch shows Bangla and persists', (tester) async {
    final prefs = await pumpApp(tester);
    expect(find.text('Explore'), findsWidgets);
    await tester.tap(find.text('বাং'));
    await settle(tester, frames: 5);
    expect(find.text('এক্সপ্লোর'), findsWidgets);
    expect(prefs.getString('fs.locale'), 'bn');
  });

  testWidgets('saved locale and theme are restored on start', (tester) async {
    await pumpApp(tester, prefs: {'fs.locale': 'bn', 'fs.theme': 'dark'});
    expect(find.text('হোম'), findsWidgets);
    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('unknown route shows the not-found page', (tester) async {
    await pumpApp(tester, location: '/nope');
    expect(find.text('This page drifted off'), findsOneWidget);
    expect(find.text('Go to Home'), findsOneWidget);
  });

  testWidgets('every section route is reachable from the rail', (tester) async {
    await pumpApp(tester);
    for (final s in NavSection.values) {
      await tester.tap(
        find.bySemanticsLabel(RegExp('^${RegExp.escape(_label(s))}\$')).first,
      );
      await settle(tester, frames: 8);
      expect(find.text(_title(s)), findsWidgets, reason: s.path);
    }
  });

  testWidgets('compact layout shows bottom navigation with More', (
    tester,
  ) async {
    await pumpApp(tester, width: 360, height: 800);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets(
    'missing asset shows the global error screen with the file name',
    (tester) async {
      await pumpApp(tester, missing: {'runs.json'});
      expect(find.text("FlameSense couldn't load its data"), findsOneWidget);
      expect(find.textContaining('runs.json'), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
    },
  );

  for (final brightness in Brightness.values) {
    testWidgets(
      'shared widgets render at 360 px without overflow ($brightness)',
      (tester) async {
        await loadAppFonts();
        await testPrefs();
        setWindow(tester, 360, 4000);
        await tester.pumpWidget(
          themed(
            const SingleChildScrollView(child: GalleryColumn()),
            brightness: brightness,
            compact: true,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('SharedPreferences keys follow the plan', () async {
    SharedPreferences.setMockInitialValues({
      'fs.theme': 'system',
      'fs.locale': 'en',
    });
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(c.dispose);
    expect(c.read(settingsProvider).locale, 'en');
    expect(c.read(settingsProvider).themeMode, ThemeMode.system);
  });
}

String _label(NavSection s) => switch (s) {
  NavSection.home => 'Home',
  NavSection.missions => 'Missions',
  NavSection.explore => 'Explore',
  NavSection.lab => 'Fire Lab',
  NavSection.map => 'Map',
  NavSection.ask => 'Ask',
  NavSection.earth => 'Earth lessons',
  NavSection.methods => 'Methods',
  NavSection.about => 'About',
};

String _title(NavSection s) => switch (s) {
  NavSection.home => 'Home',
  NavSection.missions => 'Plan for a mission',
  NavSection.explore => 'Explore the experiments',
  NavSection.lab => 'Fire Lab',
  NavSection.map => 'Flammability map',
  NavSection.ask => 'Ask the NASA papers',
  NavSection.earth => 'Lessons for Earth',
  NavSection.methods => 'Methods',
  NavSection.about => 'About',
};
