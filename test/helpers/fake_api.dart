import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/interceptors/retry_interceptor.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';

/// One request as it left the client (after every interceptor).
typedef SentRequest = ({
  String method,
  String path,
  Map<String, Object?> headers,
  Object? data,
});

/// What the fake server answers.
final class Reply {
  const new(
    this.status, {
    this.body,
    this.headers = const {},
    this.offline = false,
  });

  factory json(Object? body, {int status = 200}) => Reply(status, body: body);

  /// A problem+json answer, as the server writes it.
  factory problem(
    int status,
    String code, {
    Map<String, String> headers = const {},
    List<Map<String, String>> errors = const [],
  }) => Reply(
    status,
    body: {
      'type': 'urn:monthra:problem:$code',
      'title': 'Title of $code',
      'status': status,
      'code': code,
      'requestId': 'server-request-id',
      if (errors.isNotEmpty) 'errors': errors,
    },
    headers: {'content-type': 'application/problem+json', ...headers},
  );

  /// No answer: the connection failed.
  static const Reply unreachable = Reply(0, offline: true);

  final int status;
  final Object? body;
  final Map<String, String> headers;
  final bool offline;
}

/// An [HttpClientAdapter] that answers from [handler] and records what it
/// was sent.
final class FakeAdapter implements HttpClientAdapter {
  new(this.handler);

  FutureOr<Reply> Function(SentRequest request) handler;

  final List<SentRequest> sent = [];

  Iterable<String> get paths => sent.map((r) => '${r.method} ${r.path}');

  int count(String method, String path) =>
      sent.where((r) => r.method == method && r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final request = (
      method: options.method,
      path: options.uri.path,
      headers: Map<String, Object?>.of(options.headers),
      data: options.data,
    );
    sent.add(request);
    final reply = await handler(request);
    if (reply.offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline (fake)',
      );
    }
    final body = reply.body;
    return ResponseBody.fromString(
      body == null ? '' : (body is String ? body : jsonEncode(body)),
      reply.status,
      headers: {
        if (body != null && body is! String)
          'content-type': ['application/json'],
        for (final h in reply.headers.entries) h.key: [h.value],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

final Uri testApiRoot = Uri.parse('http://localhost:8080/api/v1');

/// A client on [adapter], as the app builds it, with instant retry waits.
({Dio dio, ApiClient api, List<SessionEvent> events}) fakeApi(
  FakeAdapter adapter, {
  SessionMode mode = SessionMode.bearer,
  TokenStore? tokens,
  String Function()? languageTag,
  List<String>? log,
  List<Duration>? waits,
  Future<void> Function(Duration)? sleep,
}) {
  final events = <SessionEvent>[];
  final dio = createApiDio(
    apiRoot: testApiRoot,
    mode: mode,
    tokens: tokens ?? MemoryTokenStore(),
    languageTag: languageTag ?? () => 'pt-BR',
    onSessionEvent: events.add,
    adapter: adapter,
    log: log?.add,
    retry: (dio) =>
        RetryInterceptor(dio, sleep: sleep ?? (d) async => waits?.add(d)),
  );
  return (dio: dio, api: ApiClient(dio), events: events);
}
