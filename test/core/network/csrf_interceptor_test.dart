import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/session_refresher.dart';

import '../../helpers/fake_api.dart';

void main() {
  const csrfPath = '/api/v1/auth/csrf';

  group('in the browser', () {
    test('fetches the token once for concurrent writes and sends it', () async {
      var issued = 0;
      final adapter = FakeAdapter((r) async {
        if (r.path == csrfPath) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return Reply.json({'csrfToken': 'token-${++issued}'});
        }
        return const Reply(204);
      });
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await Future.wait([
        api.post<void>('/accounts', data: {'name': 'a'}),
        api.patch<void>('/me', data: {'name': 'b'}),
        api.delete<void>('/me/sessions/x'),
        api.post<void>('/auth/login', data: {'email': 'e', 'password': 'p'}),
      ]);

      expect(adapter.count('GET', csrfPath), 1);
      final writes = adapter.sent.where((r) => r.method != 'GET');
      expect(writes, hasLength(4));
      for (final w in writes) {
        expect(w.headers['x-csrf-token'], 'token-1');
      }
    });

    test('reads go without the token and without fetching it', () async {
      final adapter = FakeAdapter((_) => Reply.json({'ok': true}));
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await api.get<Object?>('/accounts');

      expect(adapter.paths, ['GET /api/v1/accounts']);
      expect(adapter.sent.single.headers, isNot(contains('x-csrf-token')));
    });

    test('after csrf_invalid, fetches a new token and sends the call '
        'once more', () async {
      var issued = 0;
      var writes = 0;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) {
          return Reply.json({'csrfToken': 'token-${++issued}'});
        }
        return ++writes == 1
            ? Reply.problem(403, 'csrf_invalid')
            : const Reply(204);
      });
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      final response = await api.post<void>('/accounts', data: {'name': 'a'});

      expect(response.statusCode, 204);
      expect(adapter.paths, [
        'GET $csrfPath',
        'POST /api/v1/accounts',
        'GET $csrfPath',
        'POST /api/v1/accounts',
      ]);
      expect(adapter.sent.last.headers['x-csrf-token'], 'token-2');
    });

    test('a download refused for csrf_invalid is sent again too', () async {
      var issued = 0;
      var writes = 0;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) {
          return Reply.json({'csrfToken': 'token-${++issued}'});
        }
        return ++writes == 1
            ? Reply.problem(403, 'csrf_invalid')
            : Reply.bytes([80, 75, 5, 6]);
      });
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      final response = await api.post<List<int>>(
        '/me/export',
        data: {'password': 'p'},
        responseType: ResponseType.bytes,
      );

      expect(response.data, [80, 75, 5, 6]);
      expect(adapter.count('POST', '/api/v1/me/export'), 2);
      expect(adapter.sent.last.responseType, ResponseType.bytes);
      expect(adapter.sent.last.headers['x-csrf-token'], 'token-2');
    });

    test('a second csrf_invalid is the answer (no loop)', () async {
      final adapter = FakeAdapter(
        (r) => r.path == csrfPath
            ? Reply.json({'csrfToken': 't'})
            : Reply.problem(403, 'csrf_invalid'),
      );
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await expectLater(
        api.post<void>('/accounts', data: {'name': 'a'}),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.csrfInvalid,
          ),
        ),
      );
      expect(adapter.count('POST', '/api/v1/accounts'), 2);
    });

    test('another 403 keeps the token', () async {
      var calls = 0;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) return Reply.json({'csrfToken': 't'});
        return ++calls == 1
            ? Reply.problem(403, 'password_incorrect')
            : const Reply(204);
      });
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await expectLater(
        api.post<void>('/me/password', data: {'password': 'x'}),
        throwsA(isA<ApiProblemException>()),
      );
      await api.post<void>('/me/password', data: {'password': 'y'});

      expect(adapter.count('GET', csrfPath), 1);
    });

    test('a token fetch that fails fails the write, and the next write '
        'tries again', () async {
      var csrfCalls = 0;
      final adapter = FakeAdapter((r) {
        if (r.path == csrfPath) {
          return ++csrfCalls == 1
              ? Reply.problem(500, 'internal_error')
              : Reply.json({'csrfToken': 't'});
        }
        return const Reply(204);
      });
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await expectLater(
        api.post<void>('/accounts', data: {}),
        throwsA(isA<ApiProblemException>()),
      );
      expect(adapter.count('POST', '/api/v1/accounts'), 0);

      await api.post<void>('/accounts', data: {});
      expect(adapter.count('POST', '/api/v1/accounts'), 1);
    });

    test('an unreadable token answer fails the write', () async {
      final adapter = FakeAdapter(
        (r) => r.path == csrfPath ? Reply.json({'nope': 1}) : const Reply(204),
      );
      final api = fakeApi(adapter, mode: SessionMode.cookie).api;

      await expectLater(
        api.post<void>('/accounts', data: {}),
        throwsA(isA<UnexpectedApiException>()),
      );
      expect(adapter.count('POST', '/api/v1/accounts'), 0);
    });
  });

  test('on a device no token is fetched or sent', () async {
    final adapter = FakeAdapter((_) => const Reply(204));
    final api = fakeApi(adapter).api;

    await api.post<void>('/auth/login', data: {'email': 'e', 'password': 'p'});

    expect(adapter.paths, ['POST /api/v1/auth/login']);
    expect(adapter.sent.single.headers, isNot(contains('x-csrf-token')));
  });
}
