import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/files/file_saver.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/domain/download_names.dart';
import 'package:monthra/features/settings/presentation/security/widgets/recovery_codes_view.dart';
import 'package:monthra/l10n/generated/app_localizations.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/file_saver.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';
import 'security_test_helpers.dart';

Finder password() => field('Senha');

Finder code() => field('Código');

const String exportPage = 'Exportar meus dados';
const String exportSubmit = 'Exportar';
const String saveFile = 'Salvar arquivo';
const String ready = 'Seu arquivo está pronto';
const String saved = 'Arquivo salvo';
const String deleteSubmit = 'Excluir conta';
const String dialogTitle = 'Excluir a sua conta para sempre?';
const String dialogConfirm = 'Excluir para sempre';
const String wrongPassword = 'Essa não é a sua senha atual.';
const String wrongCode = 'Código incorreto ou já usado. Espere o próximo.';

/// The app signed in as [server] on a page of the data settings, with
/// [saver] in place of the platform's dialog.
Future<ProfileServer> pumpData(
  WidgetTester tester, {
  required String location,
  required FakeFileSaver saver,
  ProfileServer? server,
  Size size = desktop,
  Brightness brightness = Brightness.light,
}) => pumpSignedIn(
  tester,
  location: location,
  server: server,
  size: size,
  brightness: brightness,
  overrides: [fileSaverProvider.overrideWithValue(saver)],
);

AuthState authOf(WidgetTester tester) =>
    tester.appContainer.read(authControllerProvider);

void main() {
  testWidgets('the data card opens the export and the deletion', (
    tester,
  ) async {
    await pumpData(
      tester,
      location: AppRoutes.settings,
      saver: FakeFileSaver(),
    );
    await tapAndSettle(tester, button('Exportar'));
    expect(tester.appLocation.path, AppRoutes.settingsExport);
    expect(find.text(exportPage), findsWidgets);

    await tapAndSettle(tester, button('Configurações').first);
    expect(tester.appLocation.path, AppRoutes.settings);
    await tapAndSettle(tester, button('Excluir minha conta'));
    expect(tester.appLocation.path, AppRoutes.settingsDeleteAccount);
  });

  group('the export', () {
    testWidgets('without MFA takes the password, then saves the archive', (
      tester,
    ) async {
      final saver = FakeFileSaver();
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: saver,
      );
      expect(code(), findsNothing);
      expect(
        find.text(
          'Cada exportação envia um e-mail para ana@example.com. '
          'Dá para exportar algumas vezes por hora.',
        ),
        findsOneWidget,
      );

      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(exportSubmit));

      expect(server.exports, 1);
      final file = saver.files.single;
      // The day of the app's clock (held at testNow), not the real one.
      expect(file.name, exportFileName(testNow));
      expect(file.bytes, testExportZip);
      expect(file.mimeType, 'application/zip');
      expect(find.text(ready), findsOneWidget);
      expect(find.textContaining(file.name), findsOneWidget);
      expect(find.text(saved), findsOneWidget);

      // Saving again needs no new export (each one emails the owner).
      await waitOutToasts(tester);
      await tapAndSettle(tester, button(saveFile));
      expect(saver.files, hasLength(2));
      expect(server.exports, 1);
    });

    testWidgets('a cancelled save keeps the archive for another try', (
      tester,
    ) async {
      final saver = FakeFileSaver(outcome: SaveOutcome.cancelled);
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: saver,
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(exportSubmit));

      expect(
        find.text(
          'O arquivo não foi salvo. Dá para salvar de novo sem exportar '
          'outra vez.',
        ),
        findsOneWidget,
      );
      expect(find.text(saved), findsNothing);

      saver.outcome = SaveOutcome.saved;
      await tapAndSettle(tester, button(saveFile));
      expect(find.text(saved), findsOneWidget);
      expect(saver.files, hasLength(2));
      expect(server.exports, 1);
    });

    testWidgets('a failed save says so', (tester) async {
      await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: FakeFileSaver(outcome: SaveOutcome.fails),
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(exportSubmit));

      expect(
        find.text('Não foi possível salvar o arquivo. Tente de novo.'),
        findsOneWidget,
      );
      expect(enabled(tester, saveFile), isTrue);
    });

    testWidgets('with MFA on takes a code too', (tester) async {
      final saver = FakeFileSaver();
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: saver,
        server: ProfileServer(me: meJson(mfa: true)),
      );
      await tester.enterText(password(), testPassword);
      await tester.enterText(code(), '000000');
      await tester.pumpAndSettle();
      expect(find.text(wrongCode), findsOneWidget);
      expect(server.exports, 0);

      await tester.enterText(code(), testTotp);
      await tester.pumpAndSettle();
      expect(server.exports, 1);
      expect(saver.files, hasLength(1));
    });

    testWidgets('a wrong password shows under it', (tester) async {
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: FakeFileSaver(),
      );
      await tester.enterText(password(), 'wrong password');
      await tapAndSettle(tester, button(exportSubmit));

      expect(find.text(wrongPassword), findsOneWidget);
      expect(server.exports, 0);
      expect(find.text(ready), findsNothing);
    });

    testWidgets('the hourly limit holds the button', (tester) async {
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: FakeFileSaver(),
      );
      server.fail(
        '/api/v1/me/export',
        Reply.problem(429, 'rate_limited', headers: {'retry-after': '20'}),
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(exportSubmit));

      expect(
        find.text('Muitas tentativas. Tente de novo em 20 s.'),
        findsOneWidget,
      );
      expect(enabled(tester, exportSubmit), isFalse);
      await tester.pump(const Duration(seconds: 21));
      expect(enabled(tester, exportSubmit), isTrue);
    });

    testWidgets('MFA turned on elsewhere: asks for the code', (tester) async {
      final saver = FakeFileSaver();
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsExport,
        saver: saver,
      );
      server.me = meJson(mfa: true);

      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(exportSubmit));
      expect(find.text(wrongCode), findsOneWidget);
      expect(code(), findsOneWidget);
      expect(server.adapter.count('GET', '/api/v1/me'), 2);

      await tester.enterText(code(), testTotp);
      await tester.pumpAndSettle();
      expect(server.exports, 1);
    });
  });

  group('the account deletion', () {
    testWidgets('asks once more, then ends the session', (tester) async {
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsDeleteAccount,
        saver: FakeFileSaver(),
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button(deleteSubmit));
      expect(find.text(dialogTitle), findsOneWidget);

      await tapAndSettle(tester, button('Cancelar'));
      expect(find.text(dialogTitle), findsNothing);
      expect(server.adapter.count('DELETE', '/api/v1/me'), 0);
      expect(tester.appLocation.path, AppRoutes.settingsDeleteAccount);

      await tapAndSettle(tester, button(deleteSubmit));
      await tapAndSettle(tester, button(dialogConfirm));

      expect(server.deleted, isTrue);
      expect(
        authOf(tester),
        isA<SignedOut>().having(
          (s) => s.notice,
          'notice',
          AuthNotice.accountDeleted,
        ),
      );
      expect(tester.appLocation.toString(), AppRoutes.login);
      expect(
        find.text(
          'Sua conta e os dados dela foram excluídos. Enviamos uma '
          'confirmação por e-mail.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a wrong password deletes nothing', (tester) async {
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsDeleteAccount,
        saver: FakeFileSaver(),
      );
      await tester.enterText(password(), 'wrong password');
      await tapAndSettle(tester, button(deleteSubmit));
      await tapAndSettle(tester, button(dialogConfirm));

      expect(find.text(wrongPassword), findsOneWidget);
      expect(server.deleted, isFalse);
      expect(authOf(tester), isA<SignedIn>());
    });

    testWidgets('with MFA on, the code asks the question too', (tester) async {
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsDeleteAccount,
        saver: FakeFileSaver(),
        server: ProfileServer(me: meJson(mfa: true)),
      );
      await tester.enterText(password(), testPassword);
      await tester.enterText(code(), testTotp);
      await tester.pumpAndSettle();
      expect(find.text(dialogTitle), findsOneWidget);

      await tapAndSettle(tester, button(dialogConfirm));
      expect(server.deleted, isTrue);
      expect(tester.appLocation.path, AppRoutes.login);
    });

    testWidgets('offers the export first', (tester) async {
      await pumpData(
        tester,
        location: AppRoutes.settingsDeleteAccount,
        saver: FakeFileSaver(),
      );
      await tapAndSettle(tester, button('Exportar meus dados antes'));
      expect(tester.appLocation.path, AppRoutes.settingsExport);
    });
  });

  group('the recovery codes file', () {
    testWidgets('saves the new codes as text, without ticking the box', (
      tester,
    ) async {
      final saver = FakeFileSaver();
      final server = await pumpData(
        tester,
        location: AppRoutes.settingsRecoveryCodes,
        saver: saver,
        server: ProfileServer(me: meJson(mfa: true)),
      );
      await tester.enterText(password(), testPassword);
      await tester.enterText(code(), testTotp);
      await tester.pumpAndSettle();
      await waitOutToasts(tester);

      await tapAndSettle(tester, button('Baixar .txt'));
      final file = saver.files.single;
      expect(file.name, 'monthra-recovery-codes.txt');
      expect(file.mimeType, 'text/plain');
      final text = utf8.decode(file.bytes);
      expect(text, startsWith('Códigos de recuperação do Monthra\n'));
      expect(text, contains('Conta: ana@example.com\n'));
      expect(text, contains('${server.recoveryCodes.join('\n')}\n'));
      expect(
        text,
        endsWith(
          'Cada código faz login uma vez, no lugar de um código do app '
          'autenticador.\n',
        ),
      );
      expect(find.text(saved), findsOneWidget);
      expect(enabled(tester, 'Concluir'), isFalse);
    });

    test('reads, in English', () async {
      await initializeDateFormatting('en');
      final text = recoveryCodesText(
        lookupAppLocalizations(const Locale('en')),
        email: 'ana@example.com',
        codes: const ['aaaa-bbbb', 'cccc-dddd'],
        at: DateTime(2026, 11, 22, 18),
      );
      expect(
        text,
        'Monthra recovery codes\n'
        'Account: ana@example.com\n'
        'Created: November 22, 2026\n'
        '\n'
        'aaaa-bbbb\n'
        'cccc-dddd\n'
        '\n'
        'Each code signs you in once, in place of a code from the '
        'authenticator app.\n',
      );
    });
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    for (final brightness in Brightness.values) {
      testWidgets('the pages meet the guidelines on a $name, '
          '${brightness.name}', (tester) async {
        final server = await pumpData(
          tester,
          location: AppRoutes.settingsExport,
          saver: FakeFileSaver(outcome: SaveOutcome.cancelled),
          size: Size(size.width, 2000),
          brightness: brightness,
          server: ProfileServer(me: meJson(mfa: true, theme: brightness.name)),
        );
        final isPhone = name == 'phone';
        await expectGuidelines(tester, phone: isPhone);
        await tester.enterText(password(), testPassword);
        await tester.enterText(code(), testTotp);
        await tester.pumpAndSettle();
        expect(server.exports, 1);
        await expectGuidelines(tester, phone: isPhone);

        await tapAndSettle(tester, button('Configurações').first);
        await tapAndSettle(tester, button('Excluir minha conta'));
        await expectGuidelines(tester, phone: isPhone);
        await tester.enterText(password(), testPassword);
        await tester.enterText(code(), testTotp);
        await tester.pumpAndSettle();
        expect(find.text(dialogTitle), findsOneWidget);
        await expectGuidelines(tester, phone: isPhone);
      });
    }
  }

  testWidgets('the pages cope with twice the text size on a phone', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpData(
      tester,
      location: AppRoutes.settingsExport,
      saver: FakeFileSaver(),
      size: const Size(390, 3000),
    );
    await tester.enterText(password(), testPassword);
    await tapAndSettle(tester, button(exportSubmit));
    expect(find.text(ready), findsOneWidget);
    await waitOutToasts(tester);
    await tapAndSettle(tester, button('Configurações').first);
    await tapAndSettle(tester, button('Excluir minha conta'));
    await tester.enterText(password(), testPassword);
    await tapAndSettle(tester, button(deleteSubmit));
    expect(find.text(dialogTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
