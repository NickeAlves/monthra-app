import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_routes.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';

/// Signs requests and renews the session when the access token expires.
///
/// - On a device it sends `Authorization: Bearer` with the saved access
///   token. The web sends nothing: the browser attaches the cookies.
/// - A `401` on a route that needs a session ([ApiRoutes.isPublic] is
///   false) means the access token expired or was revoked (the server
///   answers 403, never 401, for a wrong password in a step-up). The
///   interceptor renews the session through [SessionRefresher], which runs
///   one refresh for every request waiting on it, then sends the request
///   once more. A request sent before the latest renewal just goes again.
/// - A `401` on a public route is the answer itself (wrong credentials,
///   expired MFA challenge) and passes through.
class AuthInterceptor extends Interceptor {
  new({
    required this._dio,
    required this._refresher,
    required this._mode,
    required this._tokens,
  });

  static const _generation = 'monthra.sessionGeneration';
  static const _retried = 'monthra.authRetried';

  final Dio _dio;
  final SessionRefresher _refresher;
  final SessionMode _mode;
  final TokenStore _tokens;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (ApiRoutes.isPublic(options.path)) {
      options.headers.remove('authorization');
      return handler.next(options);
    }
    options.extra[_generation] = _refresher.generation;
    if (_mode == SessionMode.bearer) {
      final tokens = await _tokens.read();
      if (tokens == null) {
        options.headers.remove('authorization');
      } else {
        options.headers['authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        ApiRoutes.isPublic(options.path) ||
        options.extra[_retried] == true) {
      return handler.next(err);
    }

    final sentWith = options.extra[_generation] as int?;
    if (sentWith == null || sentWith == _refresher.generation) {
      try {
        await _refresher.refresh();
      } on RefreshFailure catch (failure) {
        // A lost session keeps the request's own 401; a refresh that could
        // not run (offline, rate limited) reports why.
        final cause = failure.cause;
        return handler.reject(
          failure.sessionLost || cause == null ? err : cause,
        );
      }
    }

    options.extra[_retried] = true;
    try {
      handler.resolve(await _dio.fetch<Object?>(options));
    } on DioException catch (e) {
      // The second attempt went through every interceptor already.
      handler.reject(e);
    }
  }
}
