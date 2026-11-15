import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

void main() {
  late TestWidgetsFlutterBinding binding;

  setUpAll(() => binding = TestWidgetsFlutterBinding.ensureInitialized());

  void deviceLocales(List<Locale> locales) {
    binding.platformDispatcher.localesTestValue = locales;
    addTearDown(binding.platformDispatcher.clearLocalesTestValue);
  }

  ProviderContainer containerWith(PreferencesStore store) =>
      ProviderContainer.test(
        overrides: [preferencesStoreProvider.overrideWithValue(store)],
      );

  test('starts from the saved preferences', () {
    final store = MemoryPreferencesStore(
      const AppPreferences(locale: AppLocale.enUs, theme: ThemePreference.dark),
    );
    final container = containerWith(store);
    expect(container.read(preferencesProvider), store.read());
    expect(container.read(appLocaleProvider), AppLocale.enUs);
  });

  test('changes apply at once and are saved', () async {
    final store = MemoryPreferencesStore();
    final container = containerWith(store);
    final notifier = container.read(preferencesProvider.notifier);

    await notifier.setTheme(ThemePreference.dark);
    await notifier.setLocale(AppLocale.esEs);
    const expected = AppPreferences(
      locale: AppLocale.esEs,
      theme: ThemePreference.dark,
    );
    expect(container.read(preferencesProvider), expected);
    expect(store.read(), expected);
  });

  test('without a choice, follows the device and its changes', () async {
    deviceLocales(const [Locale('es', 'MX')]);
    final container = containerWith(MemoryPreferencesStore());
    final seen = <AppLocale>[];
    container.listen(appLocaleProvider, (_, next) => seen.add(next));
    expect(container.read(appLocaleProvider), AppLocale.esEs);

    // The system language changes while the app runs.
    deviceLocales(const [Locale('en', 'GB')]);
    expect(container.read(appLocaleProvider), AppLocale.enUs);

    // A choice wins over the device; clearing it follows the device again.
    final notifier = container.read(preferencesProvider.notifier);
    await notifier.setLocale(AppLocale.ptBr);
    expect(container.read(appLocaleProvider), AppLocale.ptBr);
    await notifier.setLocale(null);
    expect(container.read(appLocaleProvider), AppLocale.enUs);
    expect(seen, [AppLocale.enUs, AppLocale.ptBr, AppLocale.enUs]);
  });

  test('a device with none of the three languages gets pt-BR', () {
    deviceLocales(const [Locale('fr', 'FR'), Locale('de', 'DE')]);
    final container = containerWith(MemoryPreferencesStore());
    expect(container.read(appLocaleProvider), AppLocale.ptBr);
  });

  test('replaceAll takes every value (the profile at sign-in)', () async {
    final store = MemoryPreferencesStore(
      const AppPreferences(theme: ThemePreference.light),
    );
    final container = containerWith(store);
    const profile = AppPreferences(locale: AppLocale.enUs);
    await container.read(preferencesProvider.notifier).replaceAll(profile);
    expect(container.read(preferencesProvider), profile);
    expect(store.read(), profile);
  });

  test('an unchanged value is not saved again', () async {
    final store = _CountingStore();
    final container = containerWith(store);
    await container
        .read(preferencesProvider.notifier)
        .setTheme(ThemePreference.system);
    expect(store.writes, 0);
  });

  test('the store must come from main', () {
    final container = ProviderContainer.test();
    expect(
      () => container.read(preferencesStoreProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<StateError>(),
        ),
      ),
    );
  });
}

final class _CountingStore implements PreferencesStore {
  int writes = 0;

  @override
  AppPreferences read() => const AppPreferences();

  @override
  Future<void> write(AppPreferences preferences) async => writes++;
}
