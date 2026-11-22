import 'package:freezed_annotation/freezed_annotation.dart';

part 'mfa_setup.freezed.dart';
part 'mfa_setup.g.dart';

/// What an authenticator app needs to add the account (`POST
/// /auth/mfa/setup`): the secret to type by hand, or the URI as a QR code.
@freezed
abstract class MfaSetup with _$MfaSetup {
  const factory({
    /// Base32.
    required String secret,

    /// `otpauth://totp/...`.
    required String otpauthUri,

    /// Seconds left to confirm it with a first code (900).
    required int expiresIn,
  }) = _MfaSetup;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$MfaSetupFromJson(json);

  // The secret is the second factor itself: never in a log (§6.8).
  @override
  String toString() => 'MfaSetup(expiresIn: $expiresIn)';
}
