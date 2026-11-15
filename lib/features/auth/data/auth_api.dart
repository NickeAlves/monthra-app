import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/models/session.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_api.g.dart';

@Riverpod(keepAlive: true)
AuthApi authApi(Ref ref) => AuthApi(
  api: ref.watch(apiClientProvider),
  mode: ref.watch(sessionModeProvider),
  tokens: ref.watch(tokenStoreProvider),
);

/// The sign-in routes of the API (`/auth/*`) and `GET /me`. Every failure
/// is an [ApiException].
///
/// A session opened on a device is saved in [TokenStore] before the call
/// returns, the same rule as the refresh: the app never holds tokens it
/// could lose. A browser gets `HttpOnly` cookies and nothing to save.
class AuthApi {
  const new({required this._api, required this._mode, required this._tokens});

  final ApiClient _api;
  final SessionMode _mode;
  final TokenStore _tokens;

  /// Checks the password: a session, or the MFA step.
  Future<LoginResult> login({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    final response = await _api.post<Map<String, Object?>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'captchaToken': ?captchaToken,
      },
    );
    final result = _read(response.data, LoginResult.fromJson);
    if (result is LoginSignedIn) await _open(result.session);
    return result;
  }

  /// Completes a sign-in with a 6-digit code or a recovery code.
  Future<void> verifyMfa({
    required String mfaToken,
    required String code,
  }) async {
    final response = await _api.post<Map<String, Object?>>(
      '/auth/mfa/verify',
      data: {'mfaToken': mfaToken, 'code': code},
    );
    await _open(_read(response.data, Session.fromJson));
  }

  /// Signs up; the answer is the same whether or not the address is taken.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? captchaToken,
  }) => _api.post<void>(
    '/auth/register',
    data: {
      'name': name,
      'email': email,
      'password': password,
      'captchaToken': ?captchaToken,
    },
  );

  Future<void> verifyEmail(String token) =>
      _api.post<void>('/auth/verify-email', data: {'token': token});

  Future<void> resendVerification(String email) =>
      _api.post<void>('/auth/verify-email/resend', data: {'email': email});

  Future<void> forgotPassword(String email) =>
      _api.post<void>('/auth/forgot-password', data: {'email': email});

  /// Sets a new password; the server signs out every session.
  Future<void> resetPassword({
    required String token,
    required String password,
  }) => _api.post<void>(
    '/auth/reset-password',
    data: {'token': token, 'password': password},
  );

  /// Ends this session on the server (and clears the browser's cookies).
  Future<void> logout() => _api.post<void>('/auth/logout');

  Future<Me> me() async {
    final response = await _api.get<Map<String, Object?>>('/me');
    return _read<Me>(response.data, Me.fromJson);
  }

  Future<void> _open(Session session) async {
    if (_mode == SessionMode.cookie) return;
    final tokens = session.tokens;
    if (tokens == null) {
      throw const UnexpectedApiException(
        status: 200,
        cause: 'a native sign-in without tokens',
      );
    }
    await _tokens.write(tokens);
  }

  /// [body] read by [fromJson]; a body the app cannot read is an
  /// [UnexpectedApiException], like any other surprise from the API.
  static T _read<T>(
    Map<String, Object?>? body,
    T Function(Map<String, Object?>) fromJson,
  ) {
    if (body == null) {
      throw const UnexpectedApiException(status: 200, cause: 'an empty body');
    }
    try {
      return fromJson(body);
    } on Object catch (e) {
      throw UnexpectedApiException(status: 200, cause: e);
    }
  }
}
