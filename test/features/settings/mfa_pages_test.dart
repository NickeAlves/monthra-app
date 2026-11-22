import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/data/authenticator_launcher.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';
import 'security_test_helpers.dart';

class FakeLauncher implements AuthenticatorLauncher {
  new({this.installed = true, this.opens = true});

  final bool installed;
  final bool opens;
  final List<Uri> opened = [];

  @override
  Future<bool> canOpen(Uri uri) async => installed;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return opens;
  }
}

bool mfaOn(WidgetTester tester) => (tester.appContainer.read(
  authControllerProvider,
) as SignedIn).me.mfa.enabled;

Finder password() => field('Senha');

Finder totp() => field('Código');

/// Turns MFA on through the page, up to the recovery codes.
Future<void> enableUpToCodes(WidgetTester tester) async {
  await tester.enterText(password(), testPassword);
  await tapAndSettle(tester, button('Continuar'));
  await tester.enterText(totp(), testTotp);
  await tester.pumpAndSettle();
}

const String leaveTitle = 'Sair sem guardar os códigos?';

const String savedLabel = 'Guardei estes códigos num lugar seguro';

void main() {
  group('the security card', () {
    testWidgets('offers to turn it on while off', (tester) async {
      await pumpSignedIn(tester, location: AppRoutes.settings);
      expect(find.text('Verificação em duas etapas'), findsOneWidget);
      expect(find.text('Desativada'), findsOneWidget);
      expect(button('Ativar'), findsOneWidget);
      expect(find.text('Códigos de recuperação'), findsNothing);
    });

    testWidgets('shows the codes left while on, and warns when few', (
      tester,
    ) async {
      final server = ProfileServer(me: meJson(mfa: true));
      server.me = {
        ...server.me,
        'mfa': {'enabled': true, 'recoveryCodesRemaining': 2},
      };
      await pumpSignedIn(tester, location: AppRoutes.settings, server: server);
      expect(find.text('Ativada'), findsOneWidget);
      expect(button('Desativar'), findsOneWidget);
      expect(
        find.text('2 códigos restantes. Cada um faz login uma vez sem o app.'),
        findsOneWidget,
      );
      expect(find.text('Gere novos antes que acabem.'), findsOneWidget);
    });
  });

  group('turning it on', () {
    testWidgets('password, QR code and key, first code, recovery codes', (
      tester,
    ) async {
      final copied = watchClipboard(tester);
      final server = await pumpSignedIn(tester, location: AppRoutes.settings);
      await tapAndSettle(tester, button('Ativar'));
      expect(tester.appLocation.path, AppRoutes.settingsMfaEnable);

      await tester.enterText(password(), 'wrong password');
      await tapAndSettle(tester, button('Continuar'));
      expect(find.text('Essa não é a sua senha atual.'), findsOneWidget);

      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));
      final qr = tester.widget<QrCodeView>(find.byType(QrCodeView));
      expect(qr.data, testOtpauthUri);
      expect(
        find.text('JBSW Y3DP EHPK 3PXP JBSW Y3DP EHPK 3PXP'),
        findsOneWidget,
      );
      expect(button('Abrir no app autenticador'), findsNothing);
      await tapAndSettle(tester, button('Copiar chave'));
      expect(copied, [testMfaSecret]);

      await tester.enterText(totp(), '000000');
      await tester.pumpAndSettle();
      expect(
        find.text('Código incorreto ou já usado. Espere o próximo.'),
        findsOneWidget,
      );
      expect(mfaOn(tester), isFalse);

      await tester.enterText(totp(), testTotp);
      await tester.pumpAndSettle();
      expect(mfaOn(tester), isTrue);
      expect(find.text('Guarde seus códigos de recuperação'), findsOneWidget);
      for (final code in server.recoveryCodes) {
        expect(find.text(code), findsOneWidget);
      }
      await tapAndSettle(tester, button('Copiar todos'));
      expect(copied.last, server.recoveryCodes.join('\n'));

      expect(enabled(tester, 'Concluir'), isFalse);
      await waitOutToasts(tester);
      await tapAndSettle(tester, find.text(savedLabel));
      expect(enabled(tester, 'Concluir'), isTrue);
      await tapAndSettle(tester, button('Concluir'));
      expect(tester.appLocation.path, AppRoutes.settings);
      expect(find.text(leaveTitle), findsNothing);
      expect(find.text('Ativada'), findsOneWidget);
    });

    testWidgets('leaving unsaved codes asks first, whatever the way out', (
      tester,
    ) async {
      await pumpSignedIn(tester, location: AppRoutes.settingsMfaEnable);
      await enableUpToCodes(tester);

      await tapAndSettle(tester, button('Configurações').first);
      expect(find.text(leaveTitle), findsOneWidget);
      await tapAndSettle(tester, button('Ficar'));
      expect(tester.appLocation.path, AppRoutes.settingsMfaEnable);
      expect(find.text('Guarde seus códigos de recuperação'), findsOneWidget);

      // The platform's back waits for the answer: not awaited here.
      final popped = tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text(leaveTitle), findsOneWidget);
      await tapAndSettle(tester, button('Sair mesmo assim'));
      await popped;
      expect(tester.appLocation.path, AppRoutes.settings);
    });

    testWidgets('a sign-out never waits on unsaved codes', (tester) async {
      await pumpSignedIn(tester, location: AppRoutes.settingsMfaEnable);
      await enableUpToCodes(tester);

      // dio runs on timers: start the call, pump, then wait for it.
      final out = tester.appContainer
          .read(authControllerProvider.notifier)
          .signOut();
      await tester.pumpAndSettle();
      await out;
      await tester.pumpAndSettle();
      expect(find.text(leaveTitle), findsNothing);
      expect(tester.appLocation.path, AppRoutes.login);
    });

    testWidgets('an expired setup starts over', (tester) async {
      final server = await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaEnable,
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));
      expect(find.byType(QrCodeView), findsOneWidget);

      await tester.pump(const Duration(seconds: 900));
      await tester.pumpAndSettle();
      expect(find.byType(QrCodeView), findsNothing);
      expect(
        find.text('A configuração expirou. Comece de novo.'),
        findsOneWidget,
      );

      // The server's own word for it does the same.
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));
      server.setupPending = false;
      await tester.enterText(totp(), testTotp);
      await tester.pumpAndSettle();
      expect(
        find.text('A configuração expirou. Comece de novo.'),
        findsOneWidget,
      );
    });

    testWidgets('already on (another device) says so', (tester) async {
      await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaEnable,
        server: ProfileServer(me: meJson(mfa: true)),
      );
      expect(
        find.text('A verificação em duas etapas já está ativada.'),
        findsOneWidget,
      );
    });

    testWidgets('turned on elsewhere meanwhile: reads the profile again', (
      tester,
    ) async {
      final server = await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaEnable,
      );
      server.me = meJson(mfa: true);
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));
      expect(
        find.text('A verificação em duas etapas já está ativada.'),
        findsOneWidget,
      );
      expect(mfaOn(tester), isTrue);
    });

    testWidgets('a device with an authenticator app opens it', (tester) async {
      final launcher = FakeLauncher();
      await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaEnable,
        size: phone,
        overrides: [authenticatorLauncherProvider.overrideWithValue(launcher)],
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));

      await tapAndSettle(tester, button('Abrir no app autenticador'));
      expect(launcher.opened, [Uri.parse(testOtpauthUri)]);
    });

    testWidgets('says so when no app opened', (tester) async {
      await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaEnable,
        size: phone,
        overrides: [
          authenticatorLauncherProvider.overrideWithValue(
            FakeLauncher(opens: false),
          ),
        ],
      );
      await tester.enterText(password(), testPassword);
      await tapAndSettle(tester, button('Continuar'));
      await tapAndSettle(tester, button('Abrir no app autenticador'));
      expect(
        find.text('Nenhum app autenticador abriu. Digite a chave.'),
        findsOneWidget,
      );
    });
  });

  group('turning it off', () {
    testWidgets('takes the password and a recovery code', (tester) async {
      final server = ProfileServer(me: meJson(mfa: true));
      await pumpSignedIn(tester, location: AppRoutes.settings, server: server);
      await tapAndSettle(tester, button('Desativar'));
      expect(tester.appLocation.path, AppRoutes.settingsMfaDisable);

      await tester.enterText(password(), testPassword);
      await tester.enterText(totp(), '000000');
      await tester.pumpAndSettle();
      expect(
        find.text('Código incorreto ou já usado. Espere o próximo.'),
        findsOneWidget,
      );
      expect(server.mfaEnabled, isTrue);

      await tapAndSettle(tester, button('Usar um código de recuperação'));
      await tester.enterText(
        field('Código de recuperação'),
        server.recoveryCodes.first,
      );
      await tapAndSettle(tester, button('Desativar').first);

      expect(server.mfaEnabled, isFalse);
      expect(mfaOn(tester), isFalse);
      expect(
        find.text('Verificação em duas etapas desativada'),
        findsOneWidget,
      );
      expect(tester.appLocation.path, AppRoutes.settings);
      expect(find.text('Desativada'), findsOneWidget);
    });

    testWidgets('a wrong password shows under it', (tester) async {
      final server = await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaDisable,
        server: ProfileServer(me: meJson(mfa: true)),
      );
      await tester.enterText(password(), 'wrong password');
      await tester.enterText(totp(), testTotp);
      await tester.pumpAndSettle();
      expect(find.text('Essa não é a sua senha atual.'), findsOneWidget);
      expect(server.mfaEnabled, isTrue);
    });

    testWidgets('a lockout holds the button', (tester) async {
      final server = await pumpSignedIn(
        tester,
        location: AppRoutes.settingsMfaDisable,
        server: ProfileServer(me: meJson(mfa: true)),
      );
      server.fail(
        '/api/v1/auth/mfa/disable',
        Reply.problem(429, 'rate_limited', headers: {'retry-after': '20'}),
      );
      await tester.enterText(password(), testPassword);
      await tester.enterText(totp(), testTotp);
      await tester.pumpAndSettle();
      expect(
        find.text('Muitas tentativas. Tente de novo em 20 s.'),
        findsOneWidget,
      );
      expect(enabled(tester, 'Desativar'), isFalse);
      await tester.pump(const Duration(seconds: 21));
      expect(enabled(tester, 'Desativar'), isTrue);
    });

    testWidgets('while off says so', (tester) async {
      await pumpSignedIn(tester, location: AppRoutes.settingsMfaDisable);
      expect(
        find.text('A verificação em duas etapas está desativada.'),
        findsOneWidget,
      );
    });
  });

  group('new recovery codes', () {
    testWidgets('replace the old ones and are shown once', (tester) async {
      final server = ProfileServer(me: meJson(mfa: true));
      final old = server.recoveryCodes;
      await pumpSignedIn(tester, location: AppRoutes.settings, server: server);
      await tapAndSettle(tester, button('Gerar novos códigos'));
      expect(tester.appLocation.path, AppRoutes.settingsRecoveryCodes);

      await tester.enterText(password(), testPassword);
      await tester.enterText(totp(), testTotp);
      await tester.pumpAndSettle();

      expect(server.recoveryCodes, isNot(old));
      for (final code in server.recoveryCodes) {
        expect(find.text(code), findsOneWidget);
      }
      expect(find.text('Novos códigos de recuperação gerados'), findsOneWidget);

      await tapAndSettle(tester, button('Configurações').first);
      expect(find.text(leaveTitle), findsOneWidget);
      await tapAndSettle(tester, button('Ficar'));
      await waitOutToasts(tester);
      await tapAndSettle(tester, find.text(savedLabel));
      await tapAndSettle(tester, button('Concluir'));
      expect(tester.appLocation.path, AppRoutes.settings);
      expect(
        find.text('10 códigos restantes. Cada um faz login uma vez sem o app.'),
        findsOneWidget,
      );
    });
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    for (final brightness in Brightness.values) {
      testWidgets('the steps meet the guidelines on a $name, '
          '${brightness.name}', (tester) async {
        await pumpSignedIn(
          tester,
          location: AppRoutes.settingsMfaEnable,
          size: Size(size.width, 2000),
          brightness: brightness,
          overrides: [
            authenticatorLauncherProvider.overrideWithValue(FakeLauncher()),
          ],
        );
        await expectGuidelines(tester, phone: name == 'phone');
        await tester.enterText(password(), testPassword);
        await tapAndSettle(tester, button('Continuar'));
        await expectGuidelines(tester, phone: name == 'phone');
        await tester.enterText(totp(), testTotp);
        await tester.pumpAndSettle();
        await waitOutToasts(tester);
        await expectGuidelines(tester, phone: name == 'phone');
      });
    }
  }

  testWidgets('the steps cope with twice the text size on a phone', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSignedIn(
      tester,
      location: AppRoutes.settingsMfaEnable,
      size: const Size(390, 3000),
    );
    await tester.enterText(password(), testPassword);
    await tapAndSettle(tester, button('Continuar'));
    await tester.enterText(totp(), testTotp);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
