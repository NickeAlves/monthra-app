@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/http_adapter.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';

/// The client against the real local API, as a device (Bearer mode):
/// `make test-live` with the server up and seeded (monthra-server:
/// `make up && make seed`; MONTHRA_DEMO_PASSWORD is the seed's password).
/// Skipped by `flutter test` (dart_test.yaml). It makes three sign-in
/// calls: the server allows 5 auth calls a minute per address.
void main() {
  final api = Uri.parse(
    Platform.environment['MONTHRA_API'] ?? 'http://localhost:8080',
  );
  final password = Platform.environment['MONTHRA_DEMO_PASSWORD'] ?? '';
  const email = 'demo@monthra.local';

  // flutter_test answers every HTTP call with 400 unless the real client
  // is put back.
  setUpAll(() => HttpOverrides.global = null);

  ({ApiClient api, List<SessionEvent> events, List<String> log}) client(
    TokenStore tokens, {
    String language = 'en-US',
  }) {
    final events = <SessionEvent>[];
    final log = <String>[];
    final dio = createApiDio(
      apiRoot: api.replace(path: '/api/v1'),
      mode: SessionMode.bearer,
      tokens: tokens,
      languageTag: () => language,
      onSessionEvent: events.add,
      adapter: createHttpAdapter(),
      log: log.add,
    );
    return (api: ApiClient(dio), events: events, log: log);
  }

  test('wrong credentials: a problem in the asked language', () async {
    // Unknown addresses, so the demo account never nears its lockout.
    Future<ApiProblemException> attempt(String language) async {
      final c = client(MemoryTokenStore(), language: language);
      final error = await _failure(
        c.api.post<void>(
          '/auth/login',
          data: {
            'email':
                'nobody-${DateTime.now().microsecondsSinceEpoch}'
                '@monthra.local',
            'password': 'not-the-password-1',
          },
        ),
      );
      expect(c.log.single, contains('POST /api/v1/auth/login -> 401'));
      return error as ApiProblemException;
    }

    final pt = await attempt('pt-BR');
    final en = await attempt('en-US');

    for (final e in [pt, en]) {
      expect(e.code, ProblemCode.invalidCredentials);
      expect(e.status, 401);
      expect(e.requestId, matches(RegExp(r'^[0-9a-f]{32}$')));
    }
    expect(pt.problem.title, isNot(en.problem.title));
  });

  test(
    'a session: sign in, renew once for concurrent calls, sign out',
    () async {
      expect(password, isNotEmpty, reason: 'set MONTHRA_DEMO_PASSWORD');
      final tokens = MemoryTokenStore();
      final c = client(tokens);
      final auth = AuthApi(
        api: c.api,
        mode: SessionMode.bearer,
        tokens: tokens,
      );

      final login = await auth.login(email: email, password: password);
      expect(login, isA<LoginSignedIn>());
      // A native client gets the tokens, saved before login returns.
      final signedIn = (await tokens.read())!;

      final me = await auth.me();
      expect(me.email, email);

      // An access token the server refuses: five calls, one refresh.
      await tokens.write(
        AuthTokens(accessToken: 'expired', refreshToken: signedIn.refreshToken),
      );
      final answers = await Future.wait([
        for (var i = 0; i < 5; i++) c.api.get<Object?>('/me'),
      ]);
      expect(answers.map((r) => r.statusCode), everyElement(200));
      expect(c.log.where((l) => l.contains('/auth/refresh')), hasLength(1));
      final renewed = (await tokens.read())!;
      expect(renewed.refreshToken, isNot(signedIn.refreshToken));

      await auth.logout();

      // The session is revoked: the refresh fails and the app hears of it.
      await expectLater(
        c.api.get<Object?>('/me'),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.unauthorized,
          ),
        ),
      );
      expect(c.events, [SessionEvent.expired]);
      expect(await tokens.read(), isNull);
    },
  );
}

Future<ApiException> _failure(Future<Object?> call) async {
  try {
    await call;
  } on ApiException catch (e) {
    return e;
  }
  fail('the call succeeded');
}
