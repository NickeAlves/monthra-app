import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/application/sessions_controller.dart';
import 'package:monthra/features/settings/data/models/session_info.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';
import '../../helpers/stub_auth.dart';

ProviderContainer signedIn(ProfileServer server, {String id = 'u1'}) {
  final container = ProviderContainer.test(
    overrides: [
      ...appOverrides(env: localEnv, preferences: MemoryPreferencesStore()),
      httpAdapterProvider.overrideWithValue(server.adapter),
      sessionModeProvider.overrideWithValue(SessionMode.bearer),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore(savedTokens)),
      authControllerProvider.overrideWith(
        () => StubAuthController(SignedIn(Me.fromJson(meJson(id: id)))),
      ),
    ],
  )..listen(sessionsControllerProvider, (_, _) {});
  return container;
}

Future<List<String>> ids(ProviderContainer c) async => [
  for (final s in await c.read(sessionsControllerProvider.future)) s.id,
];

void main() {
  test('lists this device first, then the others as listed', () async {
    final server = ProfileServer(
      sessions: [
        sessionInfoJson(id: 's-laptop'),
        sessionInfoJson(id: 's-current', current: true),
        sessionInfoJson(id: 's-phone'),
      ],
    );
    final c = signedIn(server);

    expect(await ids(c), ['s-current', 's-laptop', 's-phone']);
  });

  test('revoke drops one; revokeOthers keeps this one', () async {
    final server = ProfileServer(
      sessions: [
        sessionInfoJson(id: 's-current', current: true),
        sessionInfoJson(id: 's-laptop'),
        sessionInfoJson(id: 's-phone'),
      ],
    );
    final c = signedIn(server);
    await ids(c);
    final notifier = c.read(sessionsControllerProvider.notifier);

    await notifier.revoke('s-laptop');
    expect(await ids(c), ['s-current', 's-phone']);
    await notifier.revokeOthers();
    expect(await ids(c), ['s-current']);
    expect(server.adapter.count('GET', '/api/v1/me/sessions'), 1);
  });

  test('a refusal is thrown and leaves the list as it was', () async {
    final server = ProfileServer();
    final c = signedIn(server);
    await ids(c);
    server.fail(
      '/api/v1/me/sessions',
      Reply.problem(503, 'service_unavailable'),
    );

    await expectLater(
      c.read(sessionsControllerProvider.notifier).revokeOthers(),
      throwsA(isA<ApiProblemException>()),
    );
    expect(await ids(c), ['s-current', 's-phone']);
  });

  test('a failed read is an error, not retried by the provider', () async {
    final server = ProfileServer()
      ..fail('/api/v1/me/sessions', Reply.problem(404, 'not_found'));
    final c = signedIn(server);

    await expectLater(
      c.read(sessionsControllerProvider.future),
      throwsA(anything),
    );
    expect(
      c.read(sessionsControllerProvider).error,
      isA<ApiProblemException>(),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
    expect(server.adapter.count('GET', '/api/v1/me/sessions'), 1);

    c.invalidate(sessionsControllerProvider);
    expect(await ids(c), [
      's-current',
      's-phone',
    ], reason: 'a retry asks again');
  });

  test('loads again for another person, and asks nothing signed out', () async {
    final server = ProfileServer();
    final c = signedIn(server);
    await ids(c);

    c.read(authControllerProvider.notifier).state = SignedIn(
      Me.fromJson(meJson(id: 'u2')),
    );
    await ids(c);
    expect(server.adapter.count('GET', '/api/v1/me/sessions'), 2);

    c.read(authControllerProvider.notifier).state = const SignedOut();
    expect(await c.read(sessionsControllerProvider.future), isEmpty);
    expect(server.adapter.count('GET', '/api/v1/me/sessions'), 2);
  });

  test('SessionInfo keeps the address out of its text', () {
    final s = SessionInfo.fromJson(sessionInfoJson(id: 's1'));
    expect(s.toString(), 'SessionInfo(id: s1, current: false)');
  });
}
