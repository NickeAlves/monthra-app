import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/network/models/session.dart';

part 'login_result.freezed.dart';
part 'login_result.g.dart';

/// What a correct password gets back from `POST /auth/login`: a session, or
/// the second step when two-step verification is on.
sealed class LoginResult {
  const new();

  /// Reads either answer: an `MFAChallenge` says `mfaRequired: true`.
  factory fromJson(Map<String, Object?> json) => json['mfaRequired'] == true
      ? LoginMfaRequired(MfaChallenge.fromJson(json))
      : LoginSignedIn(Session.fromJson(json));
}

/// Signed in: cookies on the web, tokens in [session] on a device.
final class LoginSignedIn extends LoginResult {
  const new(this.session);

  final Session session;
}

/// The password was right; a code from the authenticator app (or a recovery
/// code) completes the sign-in with `POST /auth/mfa/verify`.
final class LoginMfaRequired extends LoginResult {
  const new(this.challenge);

  final MfaChallenge challenge;
}

/// The second step of a sign-in (`MFAChallenge` in the OpenAPI).
@freezed
abstract class MfaChallenge with _$MfaChallenge {
  const factory({
    /// Single use; it takes 5 codes at most.
    required String mfaToken,

    /// Seconds left to answer (300).
    required int expiresIn,
  }) = _MfaChallenge;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$MfaChallengeFromJson(json);

  // The token completes a sign-in: never in a log (§6.8).
  @override
  String toString() => 'MfaChallenge(expiresIn: $expiresIn)';
}
