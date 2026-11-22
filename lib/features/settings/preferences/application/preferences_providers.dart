import 'package:flutter/widgets.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'preferences_providers.g.dart';

/// The local store, opened in `main` before the first frame and passed in
/// with `preferencesStoreProvider.overrideWithValue`.
@Riverpod(keepAlive: true)
PreferencesStore preferencesStore(Ref ref) => throw StateError(
  'preferencesStoreProvider is overridden in main (PreferencesStore.open)',
);

/// The preferences the root widget applies (§7.6): theme and language,
/// saved on the device.
///
/// Changes apply at once. The pickers go through `ProfileController`,
/// which also sends them to the profile (`PATCH /me/preferences`) when
/// someone is signed in; the profile's values replace these whenever it
/// loads ([replaceAll], at sign-in and start-up: the server wins).
@Riverpod(keepAlive: true)
class Preferences extends _$Preferences {
  @override
  AppPreferences build() => ref.watch(preferencesStoreProvider).read();

  /// Picks the UI language; null goes back to following the device.
  Future<void> setLocale(AppLocale? locale) =>
      _update(state.copyWith(locale: () => locale));

  Future<void> setTheme(ThemePreference theme) =>
      _update(state.copyWith(theme: theme));

  /// Takes every value from [preferences] (the profile's, at sign-in).
  Future<void> replaceAll(AppPreferences preferences) => _update(preferences);

  Future<void> _update(AppPreferences next) async {
    if (next == state) return;
    state = next;
    await ref.read(preferencesStoreProvider).write(next);
  }
}

/// The device's languages in the user's order, kept current while the app
/// runs (the system language can change with the app open).
@Riverpod(keepAlive: true)
class DeviceLocales extends _$DeviceLocales with WidgetsBindingObserver {
  @override
  List<Locale> build() {
    final binding = WidgetsBinding.instance..addObserver(this);
    ref.onDispose(() => binding.removeObserver(this));
    return binding.platformDispatcher.locales;
  }

  @override
  void didChangeLocales(List<Locale>? locales) => state = locales ?? const [];
}

/// The language the app speaks now: the chosen one, else the device's
/// best match ([AppLocale.resolve]). The one source for the UI locale and,
/// with the API client, the `Accept-Language` header.
@Riverpod(keepAlive: true)
AppLocale appLocale(Ref ref) =>
    ref.watch(preferencesProvider).locale ??
    AppLocale.resolve(ref.watch(deviceLocalesProvider));
