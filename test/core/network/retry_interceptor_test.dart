import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';

import '../../helpers/fake_api.dart';

void main() {
  const accounts = '/api/v1/accounts';

  /// Fails [failures] times with [reply], then answers 200.
  FakeAdapter flaky(Reply reply, {int failures = 1}) {
    var calls = 0;
    return FakeAdapter(
      (_) => ++calls <= failures ? reply : Reply.json({'ok': true}),
    );
  }

  for (final (name, reply) in [
    ('a connection error', Reply.unreachable),
    ('a 502', const Reply(502, body: '<html>bad gateway</html>')),
    ('a 503', Reply.problem(503, 'service_unavailable')),
    ('a 504', const Reply(504)),
  ]) {
    test('a read goes again after $name', () async {
      final adapter = flaky(reply);
      final waits = <Duration>[];
      final api = fakeApi(adapter, waits: waits).api;

      final response = await api.get<Object?>('/accounts');

      expect(response.statusCode, 200);
      expect(adapter.count('GET', accounts), 2);
      expect(waits, hasLength(1));
    });
  }

  test('waits grow and stop after two retries', () async {
    final adapter = flaky(Reply.unreachable, failures: 5);
    final waits = <Duration>[];
    final api = fakeApi(adapter, waits: waits).api;

    await expectLater(
      api.get<Object?>('/accounts'),
      throwsA(isA<NetworkException>()),
    );
    expect(adapter.count('GET', accounts), 3);
    expect(waits, hasLength(2));
    // 300 ms then 1.2 s, each within ±20%.
    expect(waits[0].inMilliseconds, inInclusiveRange(240, 360));
    expect(waits[1].inMilliseconds, inInclusiveRange(960, 1440));
  });

  test('a retry keeps the request id', () async {
    final adapter = flaky(Reply.unreachable);
    final api = fakeApi(adapter).api;

    await api.get<Object?>('/accounts');

    final ids = adapter.sent.map((r) => r.headers[requestIdHeader]).toSet();
    expect(ids, hasLength(1));
  });

  test('writes never go again (no Idempotency-Key on the server)', () async {
    for (final send in <Future<Object?> Function(FakeAdapter)>[
      (a) => fakeApi(a).api.post<void>('/transactions', data: {}),
      (a) => fakeApi(a).api.patch<void>('/me', data: {}),
      (a) => fakeApi(a).api.delete<void>('/me/sessions/x'),
    ]) {
      final adapter = flaky(const Reply(503));
      await expectLater(send(adapter), throwsA(isA<ApiException>()));
      expect(adapter.sent, hasLength(1));
    }
  });

  test('a 429 with a short Retry-After waits that long', () async {
    final adapter = flaky(
      Reply.problem(429, 'rate_limited', headers: {'retry-after': '3'}),
    );
    final waits = <Duration>[];
    final api = fakeApi(adapter, waits: waits).api;

    await api.get<Object?>('/accounts');

    expect(waits, [const Duration(seconds: 3)]);
  });

  test('a 429 with a long or no Retry-After is the answer', () async {
    for (final headers in [
      {'retry-after': '60'},
      <String, String>{},
    ]) {
      final adapter = flaky(
        Reply.problem(429, 'rate_limited', headers: headers),
      );
      final api = fakeApi(adapter).api;

      await expectLater(
        api.get<Object?>('/accounts'),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            headers.isEmpty ? isNull : const Duration(seconds: 60),
          ),
        ),
      );
      expect(adapter.sent, hasLength(1));
    }
  });

  test('other errors are the answer', () async {
    for (final status in [400, 403, 404, 409, 422, 500]) {
      final adapter = flaky(Reply.problem(status, 'some_code'));
      final api = fakeApi(adapter).api;

      await expectLater(
        api.get<Object?>('/accounts'),
        throwsA(isA<ApiProblemException>()),
      );
      expect(adapter.sent, hasLength(1), reason: '$status');
    }
  });

  test('a cancelled call stops waiting and does not go again', () async {
    final adapter = flaky(Reply.unreachable, failures: 5);
    final cancel = CancelToken();
    final waiting = Completer<void>();
    // A wait that never ends: only the cancel can stop it.
    final api = fakeApi(
      adapter,
      sleep: (_) {
        waiting.complete();
        return Completer<void>().future;
      },
    ).api;

    final call = api.get<Object?>('/accounts', cancelToken: cancel);
    await waiting.future;
    cancel.cancel();

    await expectLater(call, throwsA(isA<CancelledException>()));
    expect(adapter.sent, hasLength(1));
  });
}
