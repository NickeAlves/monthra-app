import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

void main() {
  group('AppLocale', () {
    test('has the API tags, pt-BR first', () {
      expect(AppLocale.values.map((l) => l.tag), ['pt-BR', 'es-ES', 'en-US']);
      expect(AppLocale.supportedLocales.first, const Locale('pt', 'BR'));
      expect(AppLocale.fallback, AppLocale.ptBr);
    });

    test('parses exact tags only', () {
      for (final l in AppLocale.values) {
        expect(AppLocale.fromTag(l.tag), l);
      }
      for (final tag in ['pt', 'pt_BR', 'pt-PT', 'fr-FR', '', null]) {
        expect(AppLocale.fromTag(tag), isNull, reason: '$tag');
      }
    });

    // The same answers as the server's i18n.FromAcceptLanguage.
    final cases = <List<Locale>, AppLocale>{
      [const Locale('pt', 'BR')]: AppLocale.ptBr,
      [const Locale('pt', 'PT')]: AppLocale.ptBr,
      [const Locale('pt')]: AppLocale.ptBr,
      [const Locale('es', 'MX')]: AppLocale.esEs,
      [const Locale('es', 'AR')]: AppLocale.esEs,
      [const Locale('en', 'GB')]: AppLocale.enUs,
      [const Locale('en')]: AppLocale.enUs,
      [const Locale('fr', 'FR')]: AppLocale.ptBr,
      [const Locale('fr', 'FR'), const Locale('es', 'AR')]: AppLocale.esEs,
      [const Locale('en', 'US'), const Locale('pt', 'BR')]: AppLocale.enUs,
      [const Locale.fromSubtags()]: AppLocale.ptBr,
      const []: AppLocale.ptBr,
    };
    for (final MapEntry(key: device, value: expected) in cases.entries) {
      test('resolves $device to ${expected.tag}', () {
        expect(AppLocale.resolve(device), expected);
      });
    }

    test('names each language in itself', () {
      expect(AppLocale.values.map((l) => l.nativeName), [
        'Português (Brasil)',
        'Español (España)',
        'English (US)',
      ]);
    });
  });

  group('ThemePreference', () {
    test('maps the API values to theme modes', () {
      expect(ThemePreference.values.map((t) => t.wire), [
        'system',
        'light',
        'dark',
      ]);
      expect(ThemePreference.values.map((t) => t.themeMode), [
        ThemeMode.system,
        ThemeMode.light,
        ThemeMode.dark,
      ]);
      expect(ThemePreference.fromWire('dark'), ThemePreference.dark);
      expect(ThemePreference.fromWire('sepia'), isNull);
      expect(ThemePreference.fromWire(null), isNull);
    });
  });

  group('AppPreferences', () {
    test('defaults to the device language and the system theme', () {
      const prefs = AppPreferences();
      expect(prefs.locale, isNull);
      expect(prefs.theme, ThemePreference.system);
    });

    test('copies with a cleared or replaced locale', () {
      const prefs = AppPreferences(
        locale: AppLocale.esEs,
        theme: ThemePreference.dark,
      );
      expect(
        prefs.copyWith(locale: () => null),
        const AppPreferences(theme: ThemePreference.dark),
      );
      expect(
        prefs.copyWith(theme: ThemePreference.light),
        const AppPreferences(
          locale: AppLocale.esEs,
          theme: ThemePreference.light,
        ),
      );
      expect(prefs.copyWith(), prefs);
      expect(prefs.hashCode, prefs.copyWith().hashCode);
    });
  });
}
