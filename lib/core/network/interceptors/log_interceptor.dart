import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_exception.dart';

/// One line per call in debug builds: method, path, status, time, request
/// id and problem code. Never headers, query strings or bodies, so tokens,
/// the CSRF token, passwords and the user's data stay out of the logs
/// (§6.8). Added only when `kDebugMode`.
class ApiLogInterceptor extends Interceptor {
  new(this._print);

  static const _startedAt = 'monthra.startedAt';

  final void Function(String) _print;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<Object?> response,
    ResponseInterceptorHandler handler,
  ) {
    _print(_line(response.requestOptions, '${response.statusCode}'));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final code = problemCodeOf(err);
    final outcome = status == null
        ? err.type.name
        : code == null
        ? '$status'
        : '$status $code';
    _print(_line(err.requestOptions, outcome));
    handler.next(err);
  }

  static String _line(RequestOptions options, String outcome) {
    final started = options.extra[_startedAt] as DateTime?;
    final took = started == null
        ? ''
        : ' ${DateTime.now().difference(started).inMilliseconds} ms';
    final id = options.headers[requestIdHeader];
    final path = options.uri.path;
    return '[api] ${options.method} $path -> $outcome$took'
        '${id == null ? '' : ' ($id)'}';
  }
}
