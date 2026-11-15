import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  group('ThemePreferencePicker', () {
    final labels = {
      AppLocale.ptBr: ['Tema', 'Sistema', 'Claro', 'Escuro'],
      AppLocale.esEs: ['Tema', 'Sistema', 'Claro', 'Oscuro'],
      AppLocale.enUs: ['Theme', 'System', 'Light', 'Dark'],
    };
    for (final MapEntry(key: locale, value: texts) in labels.entries) {
      testWidgets('is labeled in ${locale.tag}', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpFrame(const ThemePreferencePicker(), locale: locale);
        expect(
          tester.getSemantics(find.byType(ThemePreferencePicker)),
          isSemantics(label: texts.first),
        );
        for (final option in texts.skip(1)) {
          expect(find.text(option), findsOneWidget);
        }
        semantics.dispose();
      });
    }

    testWidgets('reads each option as one selectable button', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpFrame(
        const ThemePreferencePicker(),
        store: MemoryPreferencesStore(
          const AppPreferences(theme: ThemePreference.dark),
        ),
      );
      expect(
        tester.getSemantics(find.text('Escuro')),
        isSemantics(
          label: 'Escuro',
          isButton: true,
          isFocusable: true,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Claro')),
        isSemantics(
          label: 'Claro',
          isButton: true,
          hasTapAction: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets('applies a tap or a key press at once', (tester) async {
      final store = MemoryPreferencesStore();
      await tester.pumpFrame(const ThemePreferencePicker(), store: store);
      final container = tester.frameContainer;

      await tester.tap(find.text('Escuro'));
      await tester.pump();
      expect(container.read(preferencesProvider).theme, ThemePreference.dark);
      expect(store.read().theme, ThemePreference.dark);

      // Keyboard: Tab to "Sistema", then Enter.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(container.read(preferencesProvider).theme, ThemePreference.system);
    });

    testWidgets('meets the tap target size and copes with large text', (
      tester,
    ) async {
      await tester.pumpFrame(const ThemePreferencePicker());
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpFrame(
        const ThemePreferencePicker(),
        size: const Size(320, 600),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('LanguagePicker', () {
    Finder select() => find.byType(ShadSelect<AppLocale>);

    Future<void> choose(WidgetTester tester, String language) async {
      await tester.tap(select());
      await tester.pumpAndSettle();
      await tester.tap(find.text(language).last);
      await tester.pumpAndSettle();
    }

    void deviceLocales(WidgetTester tester, List<Locale> locales) {
      tester.platformDispatcher.localesTestValue = locales;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }

    testWidgets("shows the device's language, written in itself", (
      tester,
    ) async {
      deviceLocales(tester, const [Locale('es', 'MX')]);
      await tester.pumpFrame(const LanguagePicker());
      expect(find.text('Español (España)'), findsOneWidget);
    });

    testWidgets('lists the three languages and saves the choice', (
      tester,
    ) async {
      deviceLocales(tester, const [Locale('pt', 'BR')]);
      final store = MemoryPreferencesStore();
      await tester.pumpFrame(const LanguagePicker(), store: store);
      expect(find.text('Português (Brasil)'), findsOneWidget);

      await tester.tap(select());
      await tester.pumpAndSettle();
      for (final l in AppLocale.values) {
        expect(find.text(l.nativeName), findsWidgets, reason: l.tag);
      }
      await tester.tap(find.text('English (US)').last);
      await tester.pumpAndSettle();

      expect(
        tester.frameContainer.read(preferencesProvider).locale,
        AppLocale.enUs,
      );
      expect(store.read().locale, AppLocale.enUs);
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.text('Português (Brasil)'), findsNothing);
    });

    testWidgets('follows a change made elsewhere', (tester) async {
      deviceLocales(tester, const [Locale('pt', 'BR')]);
      await tester.pumpFrame(const LanguagePicker());
      await tester.frameContainer
          .read(preferencesProvider.notifier)
          .setLocale(AppLocale.esEs);
      await tester.pump();
      expect(find.text('Español (España)'), findsOneWidget);
      expect(find.text('Português (Brasil)'), findsNothing);

      await choose(tester, 'Português (Brasil)');
      expect(
        tester.frameContainer.read(preferencesProvider).locale,
        AppLocale.ptBr,
      );
    });

    testWidgets('reads as a labeled button, 44 px, large text', (tester) async {
      deviceLocales(tester, const [Locale('en', 'US')]);
      final semantics = tester.ensureSemantics();
      await tester.pumpFrame(const LanguagePicker());
      expect(
        tester.getSemantics(select()),
        isSemantics(
          label: 'Idioma\nEnglish (US)',
          isButton: true,
          hasTapAction: true,
        ),
      );
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();

      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpFrame(
        const LanguagePicker(),
        size: const Size(320, 600),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
