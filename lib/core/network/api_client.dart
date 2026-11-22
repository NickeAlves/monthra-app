import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/interceptors/auth_interceptor.dart';
import 'package:monthra/core/network/interceptors/csrf_interceptor.dart';
import 'package:monthra/core/network/interceptors/locale_interceptor.dart';
import 'package:monthra/core/network/interceptors/log_interceptor.dart';
import 'package:monthra/core/network/interceptors/request_id_interceptor.dart';
import 'package:monthra/core/network/interceptors/retry_interceptor.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';

/// The API's `Dio`, with its interceptors in this order:
///
/// 1. [RequestIdInterceptor]: `X-Request-ID`.
/// 2. [ApiLogInterceptor] (only with [log]): one line per attempt.
/// 3. [LocaleInterceptor]: `Accept-Language`.
/// 4. [CsrfInterceptor] (cookie mode only): `X-CSRF-Token`, and one new
///    attempt after `csrf_invalid`.
/// 5. [AuthInterceptor]: the Bearer token, and the renewal on `401`.
/// 6. [RetryInterceptor]: reads sent again on transient failures.
///
/// Errors go through them in the same order. The client never sends an
/// `Origin` header: the server would take a native call for a browser's.
/// Native clients name themselves ([nativeUserAgent]); a browser sends its
/// own `User-Agent` (scripts cannot set it).
Dio createApiDio({
  required Uri apiRoot,
  required SessionMode mode,
  required TokenStore tokens,
  required String Function() languageTag,
  required void Function(SessionEvent) onSessionEvent,
  required HttpClientAdapter adapter,
  void Function(String)? log,
  RetryInterceptor Function(Dio)? retry,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiRoot.toString(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      headers: {
        'accept': 'application/json, application/problem+json',
        if (mode == SessionMode.bearer) 'user-agent': nativeUserAgent(),
      },
    ),
  )..httpClientAdapter = adapter;
  final refresher = SessionRefresher(
    dio: dio,
    mode: mode,
    tokens: tokens,
    onEvent: onSessionEvent,
  );
  dio.interceptors.addAll([
    RequestIdInterceptor(),
    if (log != null) ApiLogInterceptor(log),
    LocaleInterceptor(languageTag),
    if (mode == SessionMode.cookie) CsrfInterceptor(dio),
    AuthInterceptor(dio: dio, refresher: refresher, mode: mode, tokens: tokens),
    retry?.call(dio) ?? RetryInterceptor(dio),
  ]);
  return dio;
}

/// The `User-Agent` of the native apps (`Monthra (iOS)`), which the server
/// keeps with each session, so the session list can say which device it is.
/// dart:io's own (`Dart/3.x (dart:io)`) says nothing of it. No version or
/// device model: nothing to fingerprint beyond the platform.
String nativeUserAgent([TargetPlatform? platform]) =>
    'Monthra (${switch (platform ?? defaultTargetPlatform) {
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.android => 'Android',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.windows => 'Windows',
      TargetPlatform.linux => 'Linux',
      TargetPlatform.fuchsia => 'Fuchsia',
    }})';

/// The calls features make to the API, under `/api/v1` (paths start with
/// `/`, as in the OpenAPI). Every failure is an [ApiException].
class ApiClient {
  const new(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? query,
    ResponseType? responseType,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.get<T>(
      path,
      queryParameters: query,
      options: _options(responseType),
      cancelToken: cancelToken,
    ),
  );

  /// [accept] replaces the JSON `Accept` (a download), and
  /// [receiveTimeout] the client's 30 s for an answer that takes longer to
  /// come. In a browser dio waits for the whole answer within the connect
  /// and receive timeouts together; on a device the receive timeout is the
  /// longest pause between two chunks.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    ResponseType? responseType,
    String? accept,
    Duration? receiveTimeout,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.post<T>(
      path,
      data: data,
      queryParameters: query,
      options: _options(
        responseType,
        accept: accept,
        receiveTimeout: receiveTimeout,
      ),
      cancelToken: cancelToken,
    ),
  );

  /// POSTs [data] and answers the body as bytes, whatever its type: a
  /// download (the data export), which may take [receiveTimeout] to come.
  /// Its refusals are problems like any call's ([accept] names the
  /// download's type before `application/problem+json`).
  Future<Uint8List> postBytes(
    String path, {
    required String accept,
    Object? data,
    Duration? receiveTimeout,
    CancelToken? cancelToken,
  }) async {
    final response = await post<List<int>>(
      path,
      data: data,
      responseType: ResponseType.bytes,
      accept: '$accept, application/problem+json',
      receiveTimeout: receiveTimeout,
      cancelToken: cancelToken,
    );
    final bytes = response.data ?? const <int>[];
    return bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.patch<T>(
      path,
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
    ),
  );

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? query,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.delete<T>(
      path,
      data: data,
      queryParameters: query,
      cancelToken: cancelToken,
    ),
  );

  static Options? _options(
    ResponseType? responseType, {
    String? accept,
    Duration? receiveTimeout,
  }) => responseType == null && accept == null && receiveTimeout == null
      ? null
      : Options(
          responseType: responseType,
          receiveTimeout: receiveTimeout,
          headers: {'accept': ?accept},
        );

  static Future<Response<T>> _send<T>(
    Future<Response<T>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e, stack) {
      Error.throwWithStackTrace(ApiException.from(e), stack);
    }
  }
}
