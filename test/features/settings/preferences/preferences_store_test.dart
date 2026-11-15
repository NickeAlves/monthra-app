import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemorySharedPreferencesAsync platform;

  void useDeviceData(Map<String, Object> data) {
    platform = InMemorySharedPreferencesAsync.withData(data);
    SharedPreferencesAsyncPlatform.instance = platform;
  }

  setUp(() => useDeviceData({}));

  test('opens empty with the defaults', () async {
    final store = await PreferencesStore.open();
    expect(store, isA<SharedPreferencesStore>());
    expect(store.read(), const AppPreferences());
  });

  test('reads what was saved, in the API format', () async {
    useDeviceData({'prefs.locale': 'es-ES', 'prefs.theme': 'dark'});
    final store = await PreferencesStore.open();
    expect(
      store.read(),
      const AppPreferences(locale: AppLocale.esEs, theme: ThemePreference.dark),
    );
  });

  test('reads unknown values as unset', () async {
    useDeviceData({'prefs.locale': 'fr-FR', 'prefs.theme': 'sepia'});
    final store = await PreferencesStore.open();
    expect(store.read(), const AppPreferences());
  });

  test('saves, and clears the locale to follow the device', () async {
    final store = await PreferencesStore.open();
    await store.write(
      const AppPreferences(
        locale: AppLocale.enUs,
        theme: ThemePreference.light,
      ),
    );
    expect(await _saved(platform), {
      'prefs.locale': 'en-US',
      'prefs.theme': 'light',
    });
    // A store opened later (the next launch) sees it.
    expect(
      (await PreferencesStore.open()).read(),
      const AppPreferences(
        locale: AppLocale.enUs,
        theme: ThemePreference.light,
      ),
    );

    await store.write(const AppPreferences(theme: ThemePreference.light));
    expect(await _saved(platform), {'prefs.theme': 'light'});
  });

  test('falls back to memory when the device store fails', () async {
    SharedPreferencesAsyncPlatform.instance = _BrokenPlatform();
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);

    final store = await PreferencesStore.open();
    expect(store, isA<MemoryPreferencesStore>());
    expect(store.read(), const AppPreferences());
    expect(errors.single.library, 'preferences');

    await store.write(const AppPreferences(theme: ThemePreference.dark));
    expect(store.read().theme, ThemePreference.dark);
  });

  test('reports a failed save instead of throwing', () async {
    final failing = _FailingWrites();
    SharedPreferencesAsyncPlatform.instance = failing;
    final store = await PreferencesStore.open();
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    addTearDown(() => FlutterError.onError = previous);

    await store.write(const AppPreferences(theme: ThemePreference.dark));
    expect(errors.single.context.toString(), contains('saving'));
  });
}

Future<Map<String, Object>> _saved(InMemorySharedPreferencesAsync platform) =>
    platform.getPreferences(
      const GetPreferencesParameters(filter: PreferencesFilters()),
      const SharedPreferencesOptions(),
    );

base class _BrokenPlatform extends InMemorySharedPreferencesAsync {
  new() : super.empty();

  @override
  Future<Map<String, Object>> getPreferences(
    GetPreferencesParameters parameters,
    SharedPreferencesOptions options,
  ) => Future.error(StateError('storage blocked'));
}

base class _FailingWrites extends InMemorySharedPreferencesAsync {
  new() : super.empty();

  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) => Future.error(StateError('quota exceeded'));
}
