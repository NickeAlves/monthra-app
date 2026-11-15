import 'package:flutter/foundation.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The local copy of the preferences (§7.6: `shared_preferences`, nothing
/// sensitive), read before the first frame so the app opens in the saved
/// theme and language, ahead of any API answer. Values keep the API's
/// format (`pt-BR`, `dark`).
abstract interface class PreferencesStore {
  /// Loads the device's store, or a [MemoryPreferencesStore] when the
  /// platform store fails (storage blocked): the app still opens, with the
  /// defaults.
  static Future<PreferencesStore> open() async {
    try {
      return SharedPreferencesStore(
        await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: SharedPreferencesStore.keys,
          ),
        ),
      );
    } on Object catch (error, stack) {
      _report(error, stack, 'opening the preferences store');
      return MemoryPreferencesStore();
    }
  }

  /// What was saved; values this version does not know read as unset.
  AppPreferences read();

  /// Saves [preferences]. A failure is reported, never thrown: the app
  /// already shows the new value and the profile keeps the synced copy.
  Future<void> write(AppPreferences preferences);
}

/// [PreferencesStore] on the platform's preferences.
final class SharedPreferencesStore implements PreferencesStore {
  const new(this._prefs);

  static const String localeKey = 'prefs.locale';
  static const String themeKey = 'prefs.theme';
  static const Set<String> keys = {localeKey, themeKey};

  final SharedPreferencesWithCache _prefs;

  @override
  AppPreferences read() => AppPreferences(
    locale: AppLocale.fromTag(_prefs.getString(localeKey)),
    theme:
        ThemePreference.fromWire(_prefs.getString(themeKey)) ??
        ThemePreference.system,
  );

  @override
  Future<void> write(AppPreferences preferences) async {
    try {
      final locale = preferences.locale;
      await Future.wait([
        if (locale == null)
          _prefs.remove(localeKey)
        else
          _prefs.setString(localeKey, locale.tag),
        _prefs.setString(themeKey, preferences.theme.wire),
      ]);
    } on Object catch (error, stack) {
      _report(error, stack, 'saving the preferences');
    }
  }
}

/// [PreferencesStore] that forgets on restart (blocked storage, tests).
final class MemoryPreferencesStore implements PreferencesStore {
  new([this._saved = const AppPreferences()]);

  AppPreferences _saved;

  @override
  AppPreferences read() => _saved;

  @override
  Future<void> write(AppPreferences preferences) async => _saved = preferences;
}

void _report(Object error, StackTrace stack, String context) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stack,
      library: 'preferences',
      context: ErrorDescription(context),
    ),
  );
}
