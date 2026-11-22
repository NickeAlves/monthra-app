import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';
import 'security_test_helpers.dart';

int sessionReads(ProfileServer server) =>
    server.adapter.count('GET', '/api/v1/me/sessions');

void main() {
  testWidgets('lists this device first, then the others', (tester) async {
    await pumpSignedIn(tester, location: AppRoutes.settings);
    await tester.ensureVisible(find.text('Sessões'));
    await tester.pumpAndSettle();

    expect(find.text('Chrome no macOS'), findsOneWidget);
    expect(find.text('Este dispositivo'), findsOneWidget);
    expect(find.text('Em uso agora'), findsOneWidget);
    expect(find.text('IP 203.0.113.7'), findsOneWidget);
    expect(find.text('App Monthra no iOS'), findsOneWidget);
    final when = DateFormat.yMMMd('pt-BR')
        .add_Hm()
        .format(DateTime.utc(2026, 11, 21, 8, 15).toLocal());
    expect(find.text('Ativa por último em $when'), findsOneWidget);
    expect(find.text('IP 198.51.100.20'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Chrome no macOS')).dy,
      lessThan(tester.getTopLeft(find.text('App Monthra no iOS')).dy),
    );
    // Only the other device can be signed out from here.
    expect(button('Encerrar'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Encerrar App Monthra no iOS'),
      findsOneWidget,
    );
  });

  testWidgets('signs out one session', (tester) async {
    final server = await pumpSignedIn(tester, location: AppRoutes.settings);
    await tapAndSettle(tester, button('Encerrar'));

    expect(
      server.adapter.paths,
      contains('DELETE /api/v1/me/sessions/s-phone'),
    );
    expect(find.text('Sessão encerrada.'), findsOneWidget);
    expect(find.text('App Monthra no iOS'), findsNothing);
    expect(
      find.text('Nenhum outro dispositivo está conectado.'),
      findsOneWidget,
    );
    expect(button('Encerrar todas as outras sessões'), findsNothing);
  });

  testWidgets('signs out every other session once confirmed', (tester) async {
    final server = ProfileServer(
      sessions: [
        sessionInfoJson(id: 's-current', current: true),
        sessionInfoJson(id: 's-laptop', userAgent: 'Mozilla/5.0 (X11; Linux)'),
        sessionInfoJson(id: 's-phone', userAgent: 'Monthra (Android)'),
      ],
    );
    await pumpSignedIn(tester, location: AppRoutes.settings, server: server);

    await tapAndSettle(tester, button('Encerrar todas as outras sessões'));
    expect(find.text('Encerrar todas as outras sessões?'), findsOneWidget);
    await tapAndSettle(tester, button('Cancelar'));
    expect(server.adapter.paths, isNot(contains('DELETE /api/v1/me/sessions')));

    await tapAndSettle(tester, button('Encerrar todas as outras sessões'));
    await tapAndSettle(tester, button('Encerrar as outras'));
    expect(server.adapter.paths, contains('DELETE /api/v1/me/sessions'));
    expect(find.text('Outras sessões encerradas.'), findsOneWidget);
    expect(find.text('Linux'), findsNothing);
    expect(find.text('App Monthra no Android'), findsNothing);
    expect(find.text('Chrome no macOS'), findsOneWidget);
  });

  testWidgets('a failed sign-out says so and keeps the row', (tester) async {
    final server = await pumpSignedIn(tester, location: AppRoutes.settings)
      ..fail(
        '/api/v1/me/sessions/s-phone',
        Reply.problem(503, 'service_unavailable'),
      );
    await tapAndSettle(tester, button('Encerrar'));
    expect(find.text('A sessão não foi encerrada'), findsOneWidget);
    expect(find.text('App Monthra no iOS'), findsOneWidget);
    expect(server.sessions, hasLength(2));
  });

  testWidgets('a failed load offers to try again', (tester) async {
    // A 500: the client sends a read again after a 503 by itself.
    final server = ProfileServer()
      ..fail('/api/v1/me/sessions', Reply.problem(500, 'internal_error'));
    await pumpSignedIn(tester, location: AppRoutes.settings, server: server);
    expect(find.text('Não foi possível carregar as sessões'), findsOneWidget);

    await tapAndSettle(tester, button('Tentar de novo'));
    expect(find.text('Chrome no macOS'), findsOneWidget);
    expect(sessionReads(server), 2);
  });

  testWidgets('a password change loads the list again', (tester) async {
    final server = await pumpSignedIn(tester, location: AppRoutes.settings);
    expect(find.text('App Monthra no iOS'), findsOneWidget);

    await tapAndSettle(tester, button('Alterar senha'));
    await tester.enterText(field('Senha atual'), testPassword);
    await tester.enterText(field('Nova senha'), 'a brand new password');
    await tapAndSettle(tester, button('Salvar nova senha'));

    expect(tester.appLocation.path, AppRoutes.settings);
    expect(sessionReads(server), 2);
    expect(find.text('App Monthra no iOS'), findsNothing);
  });

  testWidgets('shows skeletons while loading', (tester) async {
    final server = ProfileServer();
    final gate = server.holdReads();
    await pumpSignedIn(tester, location: AppRoutes.settings, server: server);
    expect(find.byType(Skeleton), findsWidgets);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);
    expect(find.text('Chrome no macOS'), findsOneWidget);
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    for (final brightness in Brightness.values) {
      testWidgets('the settings meet the guidelines on a $name, '
          '${brightness.name}', (tester) async {
        await pumpSignedIn(
          tester,
          location: AppRoutes.settings,
          size: Size(size.width, 3000),
          brightness: brightness,
          server: ProfileServer(
            me: {
              ...ProfileServer().me,
              'preferences': {
                ...ProfileServer().preferences,
                'theme': brightness.name,
              },
              'mfa': {'enabled': true, 'recoveryCodesRemaining': 2},
            },
          ),
        );
        await expectGuidelines(tester, phone: name == 'phone');
      });
    }
  }
}
