import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/security/auth_tokens.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// The answer of a sign-in, MFA check or refresh (`Session` in the OpenAPI).
///
/// A native client gets the tokens in the body; a browser (a request with
/// `Origin`) gets them as `HttpOnly` cookies and only the lifetimes here.
@freezed
abstract class Session with _$Session {
  const factory({
    /// Seconds the access token lives.
    required int expiresIn,

    /// Seconds the refresh token lives.
    required int refreshExpiresIn,
    String? tokenType,
    String? accessToken,
    String? refreshToken,
  }) = _Session;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$SessionFromJson(json);

  /// The token pair of a native answer; null for a browser's.
  AuthTokens? get tokens => switch ((accessToken, refreshToken)) {
    (final String access, final String refresh)
        when access.isNotEmpty && refresh.isNotEmpty =>
      AuthTokens(accessToken: access, refreshToken: refresh),
    _ => null,
  };

  // Never print the tokens (§6.8), not even in a debug log.
  @override
  String toString() =>
      'Session(expiresIn: $expiresIn, refreshExpiresIn: $refreshExpiresIn, '
      'tokens: ${tokens == null ? 'none' : '<redacted>'})';
}
