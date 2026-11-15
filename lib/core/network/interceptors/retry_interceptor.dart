import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_exception.dart';

/// Sends a failed read again after a short wait.
///
/// Only GET and HEAD: the server takes no `Idempotency-Key`, so a POST that
/// timed out may have been applied, and sending it again could, say, record
/// a purchase twice. A retry happens on a connection error or timeout, a
/// `502`/`503`/`504` (a proxy or the server restarting), and a `429` or
/// `503` whose `Retry-After` fits in [maxRetryAfter]. The waits grow from
/// [baseDelay] by 4x with ±20% jitter, at most [maxRetries] times.
class RetryInterceptor extends Interceptor {
  new(
    this._dio, {
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 300),
    this.maxRetryAfter = const Duration(seconds: 10),
    Future<void> Function(Duration)? sleep,
    Random? random,
  }) : _sleep = sleep ?? Future<void>.delayed,
       _random = random ?? Random();

  static const _attempts = 'monthra.retryAttempts';

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxRetryAfter;
  final Future<void> Function(Duration) _sleep;
  final Random _random;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attempts] as int?) ?? 0;
    final wait = attempt < maxRetries ? _waitFor(err, attempt) : null;
    if (wait == null) return handler.next(err);

    options.extra[_attempts] = attempt + 1;
    final cancel = options.cancelToken;
    await Future.any([_sleep(wait), if (cancel != null) cancel.whenCancel]);
    if (cancel?.isCancelled ?? false) {
      return handler.next(cancel!.cancelError!);
    }
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      // The next attempt went through every interceptor already.
      handler.reject(e);
    }
  }

  /// How long to wait before attempt [attempt] + 1, or null for no retry.
  Duration? _waitFor(DioException err, int attempt) {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'GET' && method != 'HEAD') return null;
    switch (err.type) {
      case DioExceptionType.connectionError ||
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout:
        return _backoff(attempt);
      case DioExceptionType.badResponse:
        final response = err.response;
        final retryAfter = retryAfterOf(response);
        switch (response?.statusCode) {
          case 429:
            return retryAfter != null && retryAfter <= maxRetryAfter
                ? retryAfter
                : null;
          case 503:
            if (retryAfter != null) {
              return retryAfter <= maxRetryAfter ? retryAfter : null;
            }
            return _backoff(attempt);
          case 502 || 504:
            return _backoff(attempt);
          default:
            return null;
        }
      case DioExceptionType.sendTimeout ||
          DioExceptionType.badCertificate ||
          DioExceptionType.cancel ||
          DioExceptionType.unknown ||
          DioExceptionType.transformTimeout:
        return null;
    }
  }

  Duration _backoff(int attempt) {
    final base = baseDelay * pow(4, attempt);
    final jitter = 0.8 + _random.nextDouble() * 0.4;
    return base * jitter;
  }
}
