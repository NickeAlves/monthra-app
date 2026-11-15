import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

/// The token pair of a native session, kept in the platform's secure
/// storage (one entry, so both change together).
@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory({required String accessToken, required String refreshToken}) =
      _AuthTokens;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$AuthTokensFromJson(json);

  // Never print the tokens (§6.8), not even in a debug log.
  @override
  String toString() => 'AuthTokens(<redacted>)';
}
