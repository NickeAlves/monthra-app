import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/core/security/token_store.dart';

import '../../helpers/fake_api.dart';

void main() {
  const refreshPath = '/api/v1/auth/refresh';
  const accounts = '/api/v1/accounts';
  const csrfPath = '/api/v1/auth/csrf';
  final csrf = Reply.json({'csrfToken': 'c'});
  const first = AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1');

  Map<String, Object?> session(int n) => {
    'tokenType': 'Bearer',
    'accessToken': 'access-$n',
    'refreshToken': 'refresh-$n',
    'expiresIn': 900,
    'refreshExpiresIn': 2592000,
  };

  /// A server where `access-<valid>` is the only access token accepted.
  FutureOr<Reply> Function(SentRequest) server({
    required String Function() valid,
    FutureOr<Reply> Function(SentRequest)? refresh,
  }) => (r) {
    if (r.path == refreshPath) return refresh!(r);
    return r.headers['authorization'] == 'Bearer ${valid()}'
        ? Reply.json({'ok': true})
        : Reply.problem(401, 'unauthorized');
  };

  group('on a device', () {
    test('sends the saved access token and never an Origin', () async {
      final adapter = FakeAdapter((_) => Reply.json({'ok': true}));
      final api = fakeApi(adapter, tokens: MemoryTokenStore(first)).api;

      await api.get<Object?>('/me');

      final sent = adapter.sent.single;
      expect(sent.headers['authorization'], 'Bearer access-1');
      expect(
        sent.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('origin')),
      );
    });

    test('public routes go without the token', () async {
      final adapter = FakeAdapter((_) => const Reply(204));
      final api = fakeApi(adapter, tokens: MemoryTokenStore(first)).api;

      await api.post<void>(
        '/auth/login',
        data: {'email': 'e', 'password': 'p'},
      );

      expect(adapter.sent.single.headers, isNot(contains('authorization')));
    });

    test('concurrent 401s run one refresh, save the new pair and go '
        'again', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(
          valid: () => 'access-2',
          refresh: (r) async {
            expect(r.data, {'refreshToken': 'refresh-1'});
            expect(r.headers, isNot(contains('authorization')));
            await Future<void>.delayed(const Duration(milliseconds: 10));
            return Reply.json(session(2));
          },
        ),
      );
      final client = fakeApi(adapter, tokens: tokens);

      final responses = await Future.wait([
        for (var i = 0; i < 5; i++) client.api.get<Object?>('/accounts'),
      ]);

      expect(responses.map((r) => r.statusCode), everyElement(200));
      expect(adapter.count('POST', refreshPath), 1);
      expect(adapter.count('GET', accounts), 10);
      expect(await tokens.read(), session2Tokens);
      expect(client.events, isEmpty);
    });

    test('a 401 that arrives after a renewal goes again without another '
        'refresh', () async {
      final tokens = MemoryTokenStore(first);
      final slow = Completer<void>();
      final adapter = FakeAdapter((r) async {
        if (r.path == refreshPath) return Reply.json(session(2));
        if (r.path == '/api/v1/slow' &&
            r.headers['authorization'] == 'Bearer access-1') {
          await slow.future;
          return Reply.problem(401, 'unauthorized');
        }
        return r.headers['authorization'] == 'Bearer access-2'
            ? Reply.json({'ok': true})
            : Reply.problem(401, 'unauthorized');
      });
      final api = fakeApi(adapter, tokens: tokens).api;

      final pending = api.get<Object?>('/slow');
      await api.get<Object?>('/accounts');
      slow.complete();
      await pending;

      expect(adapter.count('POST', refreshPath), 1);
      expect(adapter.sent.last.headers['authorization'], 'Bearer access-2');
    });

    test('a refused refresh clears the tokens and reports the expired '
        'session', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(
          valid: () => 'none',
          refresh: (_) => Reply.problem(401, 'unauthorized'),
        ),
      );
      final client = fakeApi(adapter, tokens: tokens);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.unauthorized,
          ),
        ),
      );
      expect(await tokens.read(), isNull);
      expect(client.events, [SessionEvent.expired]);
      expect(adapter.count('GET', accounts), 1);
    });

    test('a refresh conflict on a device is a lost session', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(
          valid: () => 'none',
          refresh: (_) => Reply.problem(409, 'refresh_conflict'),
        ),
      );
      final client = fakeApi(adapter, tokens: tokens);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(await tokens.read(), isNull);
      expect(client.events, [SessionEvent.expired]);
    });

    test('a refresh that cannot reach the server keeps the tokens and says '
        'why', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(valid: () => 'none', refresh: (_) => Reply.unreachable),
      );
      final client = fakeApi(adapter, tokens: tokens);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(isA<NetworkException>()),
      );
      expect(await tokens.read(), first);
      expect(client.events, isEmpty);
    });

    test('a refresh answer without tokens is a lost session', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(
          valid: () => 'none',
          refresh: (_) =>
              Reply.json({'expiresIn': 900, 'refreshExpiresIn': 60}),
        ),
      );
      final client = fakeApi(adapter, tokens: tokens);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(await tokens.read(), isNull);
      expect(client.events, [SessionEvent.expired]);
    });

    test('signed out: a 401 runs no refresh and reports nothing', () async {
      final adapter = FakeAdapter((_) => Reply.problem(401, 'unauthorized'));
      final client = fakeApi(adapter);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(adapter.paths, ['GET $accounts']);
      expect(client.events, isEmpty);
    });

    test('a 401 again after the renewal is the answer (no loop)', () async {
      final adapter = FakeAdapter(
        server(valid: () => 'none', refresh: (_) => Reply.json(session(2))),
      );
      final api = fakeApi(adapter, tokens: MemoryTokenStore(first)).api;

      await expectLater(
        api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(adapter.count('POST', refreshPath), 1);
      expect(adapter.count('GET', accounts), 2);
    });

    test('a 401 on a public route is the answer', () async {
      final adapter = FakeAdapter(
        (_) => Reply.problem(401, 'invalid_credentials'),
      );
      final api = fakeApi(adapter, tokens: MemoryTokenStore(first)).api;

      await expectLater(
        api.post<void>('/auth/login', data: {'email': 'e', 'password': 'p'}),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.invalidCredentials,
          ),
        ),
      );
      expect(adapter.paths, ['POST /api/v1/auth/login']);
    });

    test('logout renews an expired token first (it needs a session)', () async {
      final tokens = MemoryTokenStore(first);
      final adapter = FakeAdapter(
        server(valid: () => 'access-2', refresh: (_) => Reply.json(session(2))),
      );
      final api = fakeApi(adapter, tokens: tokens).api;

      await api.post<Object?>('/auth/logout');

      expect(adapter.paths, [
        'POST /api/v1/auth/logout',
        'POST $refreshPath',
        'POST /api/v1/auth/logout',
      ]);
    });
  });

  group('in the browser', () {
    test('refreshes with the cookie (no body, no token header)', () async {
      var renewed = false;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) return csrf;
        if (r.path == refreshPath) {
          expect(r.data, isNull);
          expect(r.headers['x-csrf-token'], 'c');
          renewed = true;
          return Reply.json({'expiresIn': 900, 'refreshExpiresIn': 60});
        }
        return renewed
            ? Reply.json({'ok': true})
            : Reply.problem(401, 'unauthorized');
      });
      final client = fakeApi(adapter, mode: SessionMode.cookie);

      await client.api.get<Object?>('/accounts');

      for (final r in adapter.sent) {
        expect(r.headers, isNot(contains('authorization')));
      }
      expect(adapter.count('GET', accounts), 2);
      expect(client.events, isEmpty);
    });

    test('a refresh conflict means another tab renewed: go again', () async {
      var conflicted = false;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) return csrf;
        if (r.path == refreshPath) {
          conflicted = true;
          return Reply.problem(409, 'refresh_conflict');
        }
        return conflicted
            ? Reply.json({'ok': true})
            : Reply.problem(401, 'unauthorized');
      });
      final client = fakeApi(adapter, mode: SessionMode.cookie);

      final response = await client.api.get<Object?>('/accounts');

      expect(response.statusCode, 200);
      expect(client.events, isEmpty);
    });

    test('a refused refresh reports the expired session', () async {
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) return csrf;
        return Reply.problem(401, 'unauthorized');
      });
      final client = fakeApi(adapter, mode: SessionMode.cookie);

      await expectLater(
        client.api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(client.events, [SessionEvent.expired]);
    });
  });
}

const session2Tokens = AuthTokens(
  accessToken: 'access-2',
  refreshToken: 'refresh-2',
);
