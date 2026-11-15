import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_routes.dart';
import 'package:monthra/core/network/models/csrf_token.dart';

/// The browser's half of the double-submit CSRF check (§6.3): every
/// POST/PATCH/PUT/DELETE carries `X-CSRF-Token`, sign-in and refresh
/// included, since the server checks any request with an `Origin`.
///
/// The token comes from `GET /auth/csrf` before the first mutating call and
/// stays in memory: the server does not bind it to the session, so a
/// sign-in keeps it. It is fetched again only after a `403 csrf_invalid`
/// (the session cookie went away with a browser restart, or the server's
/// secret rotated), and the refused call is sent again once.
///
/// Web only: native calls send no `Origin` and no cookie, so the server
/// does not ask them for the token.
class CsrfInterceptor extends Interceptor {
  new(this._dio);

  static const header = 'x-csrf-token';
  static const _retried = 'monthra.csrfRetried';

  final Dio _dio;
  String? _token;
  Future<String>? _fetching;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!isMutating(options.method)) return handler.next(options);
    try {
      options.headers[header] = await _current();
      handler.next(options);
    } on DioException catch (e) {
      handler.reject(e);
    } on Object catch (e, stack) {
      // A token answer the app cannot read.
      handler.reject(
        DioException(requestOptions: options, error: e, stackTrace: stack),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final refused =
        err.response?.statusCode == 403 &&
        problemCodeOf(err) == ProblemCode.csrfInvalid.wire;
    if (!refused || options.extra[_retried] == true) {
      return handler.next(err);
    }
    // Drop the token the request used, unless a newer one already came.
    if (_token == options.headers[header]) _token = null;
    options.extra[_retried] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      // The second attempt went through every interceptor already.
      handler.reject(e);
    }
  }

  Future<String> _current() {
    final token = _token;
    if (token != null) return Future.value(token);
    return _fetching ??= _fetch().whenComplete(() => _fetching = null);
  }

  Future<String> _fetch() async {
    final response = await _dio.get<Map<String, Object?>>(ApiRoutes.csrf);
    final token = CsrfToken.fromJson(response.data ?? const {}).csrfToken;
    _token = token;
    return token;
  }
}
