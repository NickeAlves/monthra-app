import 'dart:math';

import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_exception.dart';

/// Tags every call with an `X-Request-ID` (32 hex characters, which the
/// server accepts and echoes), so an error the user reports points to the
/// server's logs. A retry keeps the id of its first attempt.
class RequestIdInterceptor extends Interceptor {
  new([Random? random]) : _random = random ?? Random.secure();

  final Random _random;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent(requestIdHeader, _next);
    handler.next(options);
  }

  String _next() {
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
