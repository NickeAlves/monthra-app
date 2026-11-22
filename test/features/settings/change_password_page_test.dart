import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/routes.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';
import 'security_test_helpers.dart';

const String save = 'Salvar nova senha';

Future<void> fill(
  WidgetTester tester, {
  String current = testPassword,
  String next = 'a brand new password',
}) async {
  await tester.enterText(field('Senha atual'), current);
  await tester.enterText(field('Nova senha'), next);
  await tester.pump();
}

void main() {
  testWidgets('opens from the security card, under Settings', (tester) async {
    await pumpSignedIn(tester, location: AppRoutes.settings);
    expect(find.text('Segurança'), findsOneWidget);

    await tapAndSettle(tester, button('Alterar senha'));

    expect(tester.appLocation.path, AppRoutes.settingsPassword);
    expect(find.text('Digite a senha atual e depois a nova.'), findsOneWidget);
    await tapAndSettle(tester, button('Configurações').first);
    expect(tester.appLocation.path, AppRoutes.settings);
  });

  testWidgets('saves the new password, says so and goes back', (tester) async {
    final server = await pumpSignedIn(
      tester,
      location: AppRoutes.settingsPassword,
    );
    await fill(tester);
    await tapAndSettle(tester, button(save));

    final sent = server.adapter.sent.last;
    expect('${sent.method} ${sent.path}', 'POST /api/v1/me/password');
    expect(sent.data, {
      'currentPassword': testPassword,
      'newPassword': 'a brand new password',
    });
    expect(server.password, 'a brand new password');
    expect(find.text('Senha alterada'), findsOneWidget);
    expect(find.text('Suas outras sessões foram encerradas.'), findsOneWidget);
    expect(tester.appLocation.path, AppRoutes.settings);
  });

  testWidgets('a wrong current password shows under it, selected', (
    tester,
  ) async {
    final server = await pumpSignedIn(
      tester,
      location: AppRoutes.settingsPassword,
    );
    await fill(tester, current: 'not my password');
    await tapAndSettle(tester, button(save));

    expect(find.text('Essa não é a sua senha atual.'), findsOneWidget);
    final current = tester.widget<EditableText>(field('Senha atual'));
    expect(current.focusNode.hasFocus, isTrue);
    expect(
      current.controller.selection,
      const TextSelection(baseOffset: 0, extentOffset: 15),
    );
    expect(server.password, testPassword);
    expect(tester.appLocation.path, AppRoutes.settingsPassword);

    await tester.enterText(field('Senha atual'), testPassword);
    await tester.pump();
    expect(find.text('Essa não é a sua senha atual.'), findsNothing);
  });

  testWidgets("the server's rules for the new one show under it", (
    tester,
  ) async {
    await pumpSignedIn(tester, location: AppRoutes.settingsPassword);
    await fill(tester, next: 'breached password');
    await tapAndSettle(tester, button(save));
    expect(
      find.text('Essa senha apareceu em vazamentos de dados. Escolha outra.'),
      findsOneWidget,
    );
  });

  testWidgets('a short or missing password is refused before sending', (
    tester,
  ) async {
    final server = await pumpSignedIn(
      tester,
      location: AppRoutes.settingsPassword,
    );
    final asked = server.adapter.sent.length;
    await fill(tester, current: '', next: 'short');
    await tapAndSettle(tester, button(save));
    expect(find.text('Obrigatório.'), findsOneWidget);
    expect(find.text('Use pelo menos 10 caracteres.'), findsOneWidget);
    expect(server.adapter.sent.length, asked);
  });

  testWidgets('a lockout holds the button for the wait asked', (tester) async {
    final server =
        await pumpSignedIn(tester, location: AppRoutes.settingsPassword)
          ..fail(
            '/api/v1/me/password',
            Reply.problem(429, 'rate_limited', headers: {'retry-after': '30'}),
          );
    await fill(tester);
    await tapAndSettle(tester, button(save));

    expect(
      find.text('Muitas tentativas. Tente de novo em 30 s.'),
      findsOneWidget,
    );
    expect(enabled(tester, save), isFalse);
    await tester.pump(const Duration(seconds: 31));
    expect(enabled(tester, save), isTrue);
    expect(server.password, testPassword);
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    for (final brightness in Brightness.values) {
      testWidgets('meets the guidelines on a $name, ${brightness.name}', (
        tester,
      ) async {
        await pumpSignedIn(
          tester,
          location: AppRoutes.settingsPassword,
          size: size,
          brightness: brightness,
        );
        await expectGuidelines(tester, phone: name == 'phone');
      });
    }
  }

  testWidgets('copes with twice the text size on a phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpSignedIn(
      tester,
      location: AppRoutes.settingsPassword,
      size: const Size(390, 1600),
    );
    expect(tester.takeException(), isNull);
  });
}
