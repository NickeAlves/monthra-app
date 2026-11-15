import 'dart:async';

import 'package:dio/dio.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_routes.dart';
import 'package:monthra/core/network/models/session.dart';
import 'package:monthra/core/security/token_store.dart';

/// How the session travels (§6.2).
enum SessionMode {
  /// The web: `HttpOnly` cookies the browser sends by itself.
  cookie,

  /// Android and iOS: `Authorization: Bearer`, tokens in [TokenStore].
  bearer,
}

/// What the client tells the rest of the app about the session.
enum SessionEvent {
  /// The session cannot be renewed (revoked, expired, reused): sign in
  /// again. The saved tokens are already gone.
  expired,
}

/// The refresh could not renew the session.
final class RefreshFailure implements Exception {
  const new({required this.sessionLost, this.cause});

  /// True when the session is gone for good (the server refused it, or
  /// there was none); false for a failure worth trying again later (no
  /// network, rate limited), which keeps the tokens.
  final bool sessionLost;

  /// The failed refresh call, when there was one.
  final DioException? cause;

  @override
  String toString() =>
      'RefreshFailure(sessionLost: $sessionLost, '
      'status: ${cause?.response?.statusCode})';
}

/// Renews the session with `POST /auth/refresh`, one call at a time: every
/// request that finds the access token expired while a refresh runs waits
/// for that same refresh (the refresh token rotates on each use, and the
/// server revokes the whole session when a rotated one comes back).
///
/// [generation] counts the renewals, so a request sent before the latest
/// one knows its `401` is stale and just goes again.
class SessionRefresher {
  new({
    required this._dio,
    required this._mode,
    required this._tokens,
    required this._onEvent,
  });

  final Dio _dio;
  final SessionMode _mode;
  final TokenStore _tokens;
  final void Function(SessionEvent) _onEvent;

  int _generation = 0;
  Future<void>? _running;

  int get generation => _generation;

  /// Renews the session; joins the refresh already running, if any.
  /// Throws [RefreshFailure].
  Future<void> refresh() =>
      _running ??= _refresh().whenComplete(() => _running = null);

  Future<void> _refresh() async {
    final Map<String, Object?>? body;
    switch (_mode) {
      case SessionMode.cookie:
        // The browser sends the refresh cookie (Path=/api/v1/auth/refresh).
        body = null;
      case SessionMode.bearer:
        final saved = await _tokens.read();
        if (saved == null) {
          throw const RefreshFailure(sessionLost: true);
        }
        body = {'refreshToken': saved.refreshToken};
    }

    final Response<Map<String, Object?>> response;
    try {
      response = await _dio.post<Map<String, Object?>>(
        ApiRoutes.refresh,
        data: body,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final conflict =
          status == 409 && problemCodeOf(e) == ProblemCode.refreshConflict.wire;
      if (conflict && _mode == SessionMode.cookie) {
        // Another tab renewed the session a moment ago, and its answer set
        // the new cookies, which this tab shares.
        _generation++;
        return;
      }
      if (status == 401 || conflict) {
        // On a device a conflict means a renewal whose answer never
        // arrived: that new pair is lost, and sending the old token again
        // after the grace window would revoke the session anyway.
        await _expire();
        throw RefreshFailure(sessionLost: true, cause: e);
      }
      throw RefreshFailure(sessionLost: false, cause: e);
    }

    if (_mode == SessionMode.bearer) {
      final tokens = _sessionOf(response)?.tokens;
      if (tokens == null) {
        await _expire();
        throw const RefreshFailure(sessionLost: true);
      }
      // Saved before anything else: the old refresh token is spent.
      await _tokens.write(tokens);
    }
    _generation++;
  }

  Future<void> _expire() async {
    await _tokens.clear();
    _onEvent(SessionEvent.expired);
  }

  static Session? _sessionOf(Response<Map<String, Object?>> response) {
    final data = response.data;
    if (data == null) return null;
    try {
      return Session.fromJson(data);
    } on Object {
      return null;
    }
  }
}
