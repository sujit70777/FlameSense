import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/asset_repository.dart';
import 'format.dart';

/// SharedPreferences instance; overridden in `main()` and in tests.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Persisted user settings (PLAN.md Phase 6 step 3).
@immutable
class Settings {
  const Settings({required this.themeMode, required this.locale});

  final ThemeMode themeMode;

  /// 'en' or 'bn'.
  final String locale;

  Settings copyWith({ThemeMode? themeMode, String? locale}) => Settings(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
  );
}

/// Theme mode and locale, stored under `fs.theme` and `fs.locale`.
class SettingsNotifier extends Notifier<Settings> {
  static const themeKey = 'fs.theme', localeKey = 'fs.locale';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Settings build() {
    final theme = switch (_prefs.getString(themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final locale = _prefs.getString(localeKey) == 'bn' ? 'bn' : 'en';
    return Settings(themeMode: theme, locale: locale);
  }

  /// Sets and persists the theme mode.
  void setTheme(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setString(themeKey, mode.name);
  }

  /// Cycles System → Light → Dark → System (DESIGN.md §9.23).
  void cycleTheme() => setTheme(nextThemeMode(state.themeMode));

  /// Sets and persists the locale ('en' or 'bn').
  void setLocale(String locale) {
    state = state.copyWith(locale: locale == 'bn' ? 'bn' : 'en');
    _prefs.setString(localeKey, state.locale);
  }
}

/// The mode after [mode] in the System → Light → Dark cycle.
ThemeMode nextThemeMode(ThemeMode mode) => switch (mode) {
  ThemeMode.system => ThemeMode.light,
  ThemeMode.light => ThemeMode.dark,
  ThemeMode.dark => ThemeMode.system,
};

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(
  SettingsNotifier.new,
);

/// Number formatter for the current locale.
final formatProvider = Provider<FsFormat>(
  (ref) => FsFormat(ref.watch(settingsProvider).locale),
);

/// Asset repository; tests override it with a fixture bundle.
final assetRepositoryProvider = Provider<AssetRepository>(
  (ref) => AssetRepository(),
);

/// All app data, loaded once at startup (PLAN.md Phase 6 step 7).
final appDataProvider = FutureProvider<AppData>(
  (ref) => ref.watch(assetRepositoryProvider).load(),
);

/// Loaded app data; only valid below the AppDataGate (throws before load).
final loadedDataProvider = Provider<AppData>(
  (ref) => ref.watch(appDataProvider).requireValue,
);
