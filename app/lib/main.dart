import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';

/// Registers the bundled fonts' SIL OFL texts with the license page.
Stream<LicenseEntry> fontLicenses() async* {
  for (final (name, file) in [
    ('Archivo', 'Archivo-OFL.txt'),
    ('Noto Sans Bengali', 'NotoSansBengali-OFL.txt'),
  ]) {
    final text = await rootBundle.loadString('assets/fonts/LICENSES/$file');
    yield LicenseEntryWithLineBreaks([name], text);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  SemanticsBinding.instance.ensureSemantics();
  LicenseRegistry.addLicense(fontLicenses);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      // Asset failures show the error screen instead of retrying silently.
      retry: (_, _) => null,
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const FlameSenseApp(),
    ),
  );
}
