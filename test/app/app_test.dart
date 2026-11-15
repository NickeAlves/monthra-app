import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/components/amount_text.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/app.dart';
import '../helpers/frame.dart';

void main() {
  Env envFor(AppEnv appEnv) =>
      Env(appEnv: appEnv, apiBaseUrl: Uri.parse('https://api.example.com'));

  void deviceLocales(WidgetTester tester, List<Locale> locales) {
    tester.platformDispatcher.localesTestValue = locales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  void systemBrightness(WidgetTester tester, Brightness brightness) {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  }

  /// The locale the home page formats and translates with.
  Locale homeLocale(WidgetTester tester) =>
      Localizations.localeOf(tester.element(tester.appHome));

  for (final appEnv in [AppEnv.local, AppEnv.staging]) {
    testWidgets('shows the design system catalog in ${appEnv.name}', (
      tester,
    ) async {
      // The catalog's skeletons would keep pumpAndSettle busy.
      tester.reduceMotion();
      await tester.pumpMonthraApp(env: envFor(appEnv));
      await tester.pumpAndSettle();

      expect(find.byType(DesignSystemCatalog), findsOneWidget);
      expect(find.text(appEnv.name), findsOneWidget);
      expect(find.byType(PlaceholderPage), findsNothing);
    });
  }

  testWidgets('shows the brand page in production', (tester) async {
    await tester.pumpMonthraApp(env: envFor(AppEnv.production));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderPage), findsOneWidget);
    expect(find.text('Monthra'), findsOneWidget);
    expect(find.byType(DesignSystemCatalog), findsNothing);
  });

  testWidgets('uses the Monthra theme and follows a dark system', (
    tester,
  ) async {
    systemBrightness(tester, Brightness.dark);
    await tester.pumpMonthraApp(env: envFor(AppEnv.production));
    await tester.pumpAndSettle();

    final theme = tester.themeAt(find.byType(PlaceholderPage));
    expect(theme.brightness, Brightness.dark);
    expect(theme.textTheme.family, 'Inter');
    expect(theme.colorScheme.background, const Color(0xFF141414));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SvgPicture &&
            w.bytesLoader.toString().contains('monthra-simbolo-branco.svg'),
      ),
      findsOneWidget,
    );
  });

  group('preferences', () {
    testWidgets('the saved theme shows on the first frame', (tester) async {
      systemBrightness(tester, Brightness.light);
      await tester.pumpMonthraApp(
        env: envFor(AppEnv.production),
        store: MemoryPreferencesStore(
          const AppPreferences(theme: ThemePreference.dark),
        ),
      );
      // No settling: the first frame the home shows is already dark.
      final page = find.byType(PlaceholderPage);
      expect(tester.themeAt(page).brightness, Brightness.dark);
      expect(
        tester.themeAt(page).colorScheme.background,
        const Color(0xFF141414),
      );
    });

    testWidgets('the saved language wins over the device', (tester) async {
      deviceLocales(tester, const [Locale('pt', 'BR')]);
      await tester.pumpMonthraApp(
        store: MemoryPreferencesStore(
          const AppPreferences(locale: AppLocale.enUs),
        ),
      );
      expect(homeLocale(tester), const Locale('en', 'US'));
    });

    for (final (device, expected) in [
      (const Locale('es', 'MX'), AppLocale.esEs),
      (const Locale('pt', 'PT'), AppLocale.ptBr),
      (const Locale('en', 'GB'), AppLocale.enUs),
      (const Locale('fr', 'FR'), AppLocale.ptBr),
    ]) {
      testWidgets('a $device device gets ${expected.tag}', (tester) async {
        deviceLocales(tester, [device]);
        await tester.pumpMonthraApp();
        expect(homeLocale(tester), expected.locale);
      });
    }

    testWidgets('amounts follow the UI language', (tester) async {
      tester.reduceMotion();
      deviceLocales(tester, const [Locale('pt', 'BR')]);
      await tester.pumpMonthraApp();
      await tester.pumpAndSettle();
      // The catalog's "Kinds" row: an expense of R$ 129,90 (in the UI
      // language, since it names no locale).
      const ptBR = Locale('pt', 'BR');
      const enUS = Locale('en', 'US');
      final expense = find.byWidgetPredicate(
        (w) => w is AmountText && w.minor == 12990 && w.locale == null,
      );
      String shown() => tester
          .widget<Text>(
            find.descendant(of: expense, matching: find.byType(Text)),
          )
          .data!;
      expect(shown(), MoneyFormat.format(-12990, Currency.brl, ptBR));
      expect(shown(), endsWith('129,90'));

      await tester.appContainer
          .read(preferencesProvider.notifier)
          .setLocale(AppLocale.enUs);
      await tester.pumpUntilLocalized(tester.appHome, AppLocale.enUs);
      await tester.pumpAndSettle();
      expect(shown(), MoneyFormat.format(-12990, Currency.brl, enUS));
      expect(shown(), endsWith(r'R$129.90'));
    });

    testWidgets('a language change applies at once, without a restart', (
      tester,
    ) async {
      tester.reduceMotion();
      deviceLocales(tester, const [Locale('pt', 'BR')]);
      final store = MemoryPreferencesStore();
      await tester.pumpMonthraApp(store: store);
      await tester.pumpAndSettle();
      expect(find.text('Escuro'), findsOneWidget);
      final catalog = tester.element(find.byType(DesignSystemCatalog));

      await tester.tap(find.byType(LanguagePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español (España)').last);
      await tester.pumpUntilLocalized(tester.appHome, AppLocale.esEs);
      await tester.pumpAndSettle();

      expect(find.text('Oscuro'), findsOneWidget);
      expect(find.text('Escuro'), findsNothing);
      expect(homeLocale(tester), const Locale('es', 'ES'));
      expect(store.read().locale, AppLocale.esEs);
      // The same element, rebuilt: nothing restarted or remounted.
      expect(tester.element(find.byType(DesignSystemCatalog)), same(catalog));
    });

    testWidgets('saves the web boot hint on every change', (tester) async {
      tester.reduceMotion();
      deviceLocales(tester, const [Locale('en', 'US')]);
      final hints = <SavedBootHint>[];
      await tester.pumpMonthraApp(bootHints: hints);
      await tester.pumpAndSettle();
      expect(hints, [(languageTag: 'en-US', theme: null)]);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      final notifier = tester.appContainer.read(preferencesProvider.notifier);
      await notifier.setLocale(AppLocale.ptBr);
      await tester.pumpAndSettle();
      await notifier.setTheme(ThemePreference.system);
      await tester.pumpAndSettle();

      expect(hints, [
        (languageTag: 'en-US', theme: null),
        (languageTag: 'en-US', theme: 'dark'),
        (languageTag: 'pt-BR', theme: 'dark'),
        (languageTag: 'pt-BR', theme: null),
      ]);
    });
  });
}
