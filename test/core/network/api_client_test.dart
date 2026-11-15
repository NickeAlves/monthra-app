import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_routes.dart';
import 'package:monthra/core/network/models/session.dart';
import 'package:monthra/core/security/auth_tokens.dart';
import 'package:monthra/core/security/token_store.dart';

import '../../helpers/fake_api.dart';

void main() {
  group('requests', () {
    test(
      'go under /api/v1 as JSON, with the language and a request id',
      () async {
        final adapter = FakeAdapter((_) => Reply.json({'ok': true}));
        var language = 'pt-BR';
        final api = fakeApi(adapter, languageTag: () => language).api;

        await api.post<Object?>('/accounts', data: {'name': 'Wallet'});
        language = 'es-ES';
        await api.get<Object?>('/accounts', query: {'includeArchived': true});

        final [post, get] = adapter.sent;
        expect(post.path, '/api/v1/accounts');
        expect(post.headers['content-type'], 'application/json');
        expect(
          post.headers['accept'],
          'application/json, application/problem+json',
        );
        expect(post.headers['accept-language'], 'pt-BR');
        expect(get.headers['accept-language'], 'es-ES');
        final ids = [
          post,
          get,
        ].map((r) => r.headers[requestIdHeader]! as String);
        for (final id in ids) {
          expect(id, matches(RegExp(r'^[0-9a-f]{32}$')));
        }
        expect(ids.toSet(), hasLength(2));
      },
    );

    test('bodies come back decoded', () async {
      final adapter = FakeAdapter((_) => Reply.json({'id': 'a1', 'n': 3}));
      final api = fakeApi(adapter).api;

      final response = await api.get<Map<String, Object?>>('/accounts/a1');

      expect(response.data, {'id': 'a1', 'n': 3});
    });
  });

  group('failures become ApiException', () {
    test('a problem with field errors', () async {
      final adapter = FakeAdapter(
        (_) => Reply.problem(
          422,
          'validation_failed',
          errors: [
            {'field': 'name', 'code': 'required'},
            {'field': 'card.closingDay', 'code': 'out_of_range'},
            {'field': 'name', 'code': 'something_new'},
          ],
        ),
      );
      final api = fakeApi(adapter).api;

      final error = await _failure(api.post<void>('/accounts', data: {}));

      final problem = (error as ApiProblemException).problem;
      expect(error.status, 422);
      expect(error.code, ProblemCode.validationFailed);
      expect(error.requestId, 'server-request-id');
      expect(problem.title, 'Title of validation_failed');
      expect(problem.codesOf('name'), ['required', 'something_new']);
      expect(problem.errors[1].knownCode, FieldCode.outOfRange);
      expect(problem.errors[2].knownCode, isNull);
    });

    test('a code newer than the app keeps its wire value', () async {
      final adapter = FakeAdapter((_) => Reply.problem(409, 'brand_new'));
      final error = await _failure(fakeApi(adapter).api.get<void>('/x'));

      expect(error, isA<ApiProblemException>());
      error as ApiProblemException;
      expect(error.code, isNull);
      expect(error.problem.code, 'brand_new');
    });

    test('an error page that is not a problem', () async {
      final adapter = FakeAdapter(
        (_) => const Reply(
          500,
          body: '<html>oops</html>',
          headers: {'content-type': 'text/html', 'x-request-id': 'proxy-id'},
        ),
      );
      final error = await _failure(
        fakeApi(adapter).api.post<void>('/accounts', data: {}),
      );

      expect(
        error,
        isA<UnexpectedApiException>()
            .having((e) => e.status, 'status', 500)
            .having((e) => e.requestId, 'requestId', 'proxy-id'),
      );
    });

    test('a JSON error that is not a problem', () async {
      final adapter = FakeAdapter(
        (_) => Reply.json({'message': 'nope'}, status: 400),
      );
      final error = await _failure(fakeApi(adapter).api.get<void>('/x'));

      expect(
        error,
        isA<UnexpectedApiException>().having((e) => e.status, 'status', 400),
      );
    });

    test('no connection', () async {
      final adapter = FakeAdapter((_) => Reply.unreachable);
      final error = await _failure(
        fakeApi(adapter).api.post<void>('/accounts', data: {}),
      );

      expect(error, isA<NetworkException>());
      expect(error.requestId, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('timeouts', () {
      final options = RequestOptions(path: '/x');
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(
          ApiException.from(DioException(requestOptions: options, type: type)),
          isA<ApiTimeoutException>(),
        );
      }
      expect(
        ApiException.from(
          DioException(requestOptions: options, type: DioExceptionType.cancel),
        ),
        isA<CancelledException>(),
      );
    });
  });

  group('debug log', () {
    test('one line per call, with no tokens, query or body', () async {
      final adapter = FakeAdapter((r) {
        if (r.path == '/api/v1/auth/refresh') {
          return Reply.json({
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'expiresIn': 900,
            'refreshExpiresIn': 60,
          });
        }
        return r.headers['authorization'] == 'Bearer access-2'
            ? Reply.json({'secret': 'data'})
            : Reply.problem(401, 'unauthorized');
      });
      final log = <String>[];
      final api = fakeApi(
        adapter,
        tokens: MemoryTokenStore(
          const AuthTokens(accessToken: 'access-1', refreshToken: 'refresh-1'),
        ),
        log: log,
      ).api;

      await api.get<Object?>('/transactions', query: {'q': 'pharmacy'});

      expect(log, hasLength(3));
      expect(
        log[0],
        startsWith('[api] GET /api/v1/transactions -> 401 unauthorized '),
      );
      expect(log[1], startsWith('[api] POST /api/v1/auth/refresh -> 200 '));
      expect(log[2], startsWith('[api] GET /api/v1/transactions -> 200 '));
      for (final line in log) {
        expect(line, matches(RegExp(r' \d+ ms \([0-9a-f]{32}\)$')));
        for (final secret in ['access', 'refresh-', 'pharmacy', 'data']) {
          expect(line, isNot(contains(secret)));
        }
      }
    });
  });

  group('models', () {
    test('a native session carries the tokens; a browser one does not', () {
      final native = Session.fromJson({
        'tokenType': 'Bearer',
        'accessToken': 'a',
        'refreshToken': 'r',
        'expiresIn': 900,
        'refreshExpiresIn': 60,
      });
      final browser = Session.fromJson({
        'expiresIn': 900,
        'refreshExpiresIn': 60,
      });

      expect(
        native.tokens,
        const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      );
      expect(browser.tokens, isNull);
      // The tokens never reach a log through toString.
      expect(
        '$native',
        'Session(expiresIn: 900, refreshExpiresIn: 60, tokens: <redacted>)',
      );
      expect('${native.tokens}', 'AuthTokens(<redacted>)');
    });

    test('public routes', () {
      expect(ApiRoutes.isPublic('/auth/login'), isTrue);
      expect(ApiRoutes.isPublic('/auth/verify-email?x=1'), isTrue);
      expect(ApiRoutes.isPublic('/auth/logout'), isFalse);
      expect(ApiRoutes.isPublic('/auth/mfa/setup'), isFalse);
      expect(ApiRoutes.isPublic('/me'), isFalse);
    });
  });
}

Future<ApiException> _failure(Future<Object?> call) async {
  try {
    await call;
  } on ApiException catch (e) {
    return e;
  }
  fail('the call succeeded');
}
