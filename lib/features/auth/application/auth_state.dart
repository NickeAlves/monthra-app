import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';
import 'package:monthra/features/auth/data/models/me.dart';

/// Where the app stands with the session; the router guards follow it.
sealed class AuthState {
  const new();

  bool get isSignedIn => this is SignedIn;
}

/// Starting up: finding out whether a session from an earlier visit still
/// holds (`GET /me`). Nothing but the boot screen shows meanwhile.
final class AuthBooting extends AuthState {
  const new();
}

/// The start-up check could not reach the API (offline, the server down),
/// so the app cannot tell yet whether the session holds.
final class AuthUnavailable extends AuthState {
  const new(this.error);

  final ApiException error;
}

final class SignedIn extends AuthState {
  const new(this.me);

  final Me me;
}

/// No session. [notice] says why, when the person should know (shown on the
/// sign-in page until the next attempt).
final class SignedOut extends AuthState {
  const new({this.notice});

  final AuthNotice? notice;
}

/// The password was right and the second step is pending: still signed
/// out. The challenge lives only in memory, never in a route or storage.
final class AwaitingMfa extends AuthState {
  const new(this.challenge);

  final MfaChallenge challenge;
}

/// Why the session ended, for the sign-in page.
enum AuthNotice {
  /// The session ran out or was revoked (another device, a reset).
  sessionExpired,

  /// The password changed through a reset link: every session ended.
  passwordReset,

  /// The two-step challenge expired or ran out of attempts.
  mfaExpired,

  /// The account was deleted (Settings): every session ended with it.
  accountDeleted,
}
