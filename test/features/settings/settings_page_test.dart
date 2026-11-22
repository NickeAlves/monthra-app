import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/presentation/settings_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/contrast.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/frame.dart';
import '../../helpers/profile_server.dart';

const Size phone = Size(390, 844);
const Size desktop = Size(1280, 1000);

/// The settings page, signed in as [server]'s profile, in pt-BR.
Future<ProfileServer> pumpSettings(
  WidgetTester tester, {
  ProfileServer? server,
  Size size = desktop,
  Brightness brightness = Brightness.light,
}) async {
  final api = server ?? ProfileServer();
  tester.reduceMotion();
  await tester.pumpFrame(
    const SettingsPage(),
    size: size,
    brightness: brightness,
    auth: SignedIn(Me.fromJson(api.me)),
    api: api.adapter,
    // The profile's theme, as after a sign-in.
    store: MemoryPreferencesStore(
      AppPreferences(
        theme: ThemePreference.fromWire(api.preferences['theme']! as String)!,
      ),
    ),
  );
  return api;
}

Me signedInMe(WidgetTester tester) =>
    (tester.frameContainer.read(authControllerProvider) as SignedIn).me;

Finder nameField() => find.byType(EditableText);

void main() {
  testWidgets('shows the profile and the preferences', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('ana@example.com'), findsOneWidget);
    expect(find.text('Preferências'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);
    expect(find.text('Real brasileiro (BRL)'), findsOneWidget);
    expect(tester.widget<ShadSwitch>(find.byType(ShadSwitch)).value, isTrue);
  });

  group('the name', () {
    testWidgets('saves trimmed, says so and shows everywhere', (tester) async {
      final server = await pumpSettings(tester);
      ShadButton save() => tester.widget<ShadButton>(
        find.ancestor(
          of: find.text('Salvar nome'),
          matching: find.byType(ShadButton),
        ),
      );
      expect(save().enabled, isFalse);

      await tester.enterText(nameField(), '  Bia Souza ');
      await tester.pump();
      expect(save().enabled, isTrue);
      await tester.tap(find.text('Salvar nome'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(server.adapter.sent.last.data, {'name': 'Bia Souza'});
      expect(signedInMe(tester).name, 'Bia Souza');
      expect(find.text('Nome salvo.'), findsOneWidget);
      expect(
        tester.widget<EditableText>(nameField()).controller.text,
        'Bia Souza',
      );
      expect(save().enabled, isFalse);
    });

    testWidgets('saves with Enter', (tester) async {
      final server = await pumpSettings(tester);
      await tester.enterText(nameField(), 'Bia');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(server.preferencePatches, isEmpty);
      expect(server.me['name'], 'Bia');
    });

    testWidgets('an empty name is refused before sending', (tester) async {
      final server = await pumpSettings(tester);
      await tester.enterText(nameField(), '   ');
      await tester.pump();
      await tester.tap(find.text('Salvar nome'));
      await tester.pumpAndSettle();
      expect(find.text('Obrigatório.'), findsOneWidget);
      expect(server.adapter.sent, isEmpty);
    });

    testWidgets("the server's field error shows under the field until the "
        'next change', (tester) async {
      final server = await pumpSettings(tester)
        ..fail(
          '/api/v1/me',
          Reply.problem(
            422,
            'validation_failed',
            errors: [
              {'field': 'name', 'code': 'invalid'},
            ],
          ),
        );
      await tester.enterText(nameField(), 'Bia‍');
      await tester.pump();
      await tester.tap(find.text('Salvar nome'));
      await tester.pumpAndSettle();
      expect(server.adapter.sent, hasLength(1));
      expect(find.text('Valor inválido.'), findsOneWidget);

      await tester.enterText(nameField(), 'Bia');
      await tester.pump();
      expect(find.text('Valor inválido.'), findsNothing);
    });

    testWidgets('another failure shows above the form', (tester) async {
      (await pumpSettings(tester))
          .fail('/api/v1/me', Reply.problem(503, 'unavailable'));
      await tester.enterText(nameField(), 'Bia');
      await tester.pump();
      await tester.tap(find.text('Salvar nome'));
      await tester.pumpAndSettle();
      expect(find.byType(ShadAlert), findsOneWidget);
      expect(signedInMe(tester).name, 'Ana');
    });
  });

  group('the preferences', () {
    testWidgets('the theme applies at once and is saved', (tester) async {
      final server = await pumpSettings(tester);
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      expect(
        tester.frameContainer.read(preferencesProvider).theme,
        ThemePreference.light,
      );
      expect(server.preferencePatches, [
        {'theme': 'light'},
      ]);
    });

    testWidgets('the currency is saved', (tester) async {
      final server = await pumpSettings(tester);
      await tester.tap(find.byType(ShadSelect<Currency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dólar americano (USD)').last);
      await tester.pumpAndSettle();
      expect(server.preferencePatches, [
        {'currency': 'USD'},
      ]);
      expect(find.text('Dólar americano (USD)'), findsOneWidget);
      expect(signedInMe(tester).preferences.currency, 'USD');
    });

    testWidgets('the budget alerts switch is saved, and goes back when '
        'refused', (tester) async {
      final server = await pumpSettings(tester);
      bool switchValue() =>
          tester.widget<ShadSwitch>(find.byType(ShadSwitch)).value;

      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();
      expect(server.preferencePatches.last, {'budgetAlerts': false});
      expect(switchValue(), isFalse);

      server.fail('/api/v1/me/preferences', Reply.problem(503, 'unavailable'));
      await tester.tap(find.byType(ShadSwitch));
      await tester.pump();
      expect(switchValue(), isTrue);
      await tester.pumpAndSettle();
      expect(switchValue(), isFalse);
    });
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    for (final brightness in Brightness.values) {
      testWidgets('meets the guidelines on a $name, ${brightness.name}', (
        tester,
      ) async {
        await pumpSettings(
          tester,
          size: name == 'phone' ? const Size(390, 1600) : size,
          brightness: brightness,
          server: ProfileServer(me: meJson(theme: brightness.name)),
        );
        await expectLater(
          tester,
          meetsGuideline(
            name == 'phone'
                ? iOSTapTargetGuideline
                : const MinimumTapTargetGuideline(
                    size: Size(24, 24),
                    link:
                        'https://www.w3.org/WAI/WCAG22/Understanding/'
                        'target-size-minimum',
                  ),
          ),
        );
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        expect(contrastIssues(tester), isEmpty);
      });
    }
  }

  testWidgets('copes with twice the text size on a phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSettings(tester, size: const Size(390, 3000));
    expect(tester.takeException(), isNull);
  });
}
