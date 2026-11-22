import 'dart:async';

import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/auth_api.dart';
import 'package:monthra/features/auth/data/models/login_result.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

/// The web's "may be signed in" mark ([SessionHint]).
@Riverpod(keepAlive: true)
SessionHint sessionHint(Ref ref) => SessionHint.platform();

/// The session of the app ([AuthState]) and the ways in and out of it.
///
/// - At start-up a session may exist when the device holds tokens, or, on
///   the web, when [SessionHint] says so; then `GET /me` decides. Without
///   one the app opens signed out at once.
/// - Whenever the profile loads (sign-in and start-up) its language and
///   theme replace the local ones: the server's value wins (§7.6).
/// - A session the API client could not renew ([SessionEvent.expired])
///   signs the app out with [AuthNotice.sessionExpired].
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  Timer? _mfaDeadline;

  AuthApi get _api => ref.read(authApiProvider);
  SessionMode get _mode => ref.read(sessionModeProvider);
  TokenStore get _tokens => ref.read(tokenStoreProvider);
  SessionHint get _hint => ref.read(sessionHintProvider);

  @override
  AuthState build() {
    final events = ref
        .watch(sessionEventsProvider)
        .stream
        .listen(_onSessionEvent);
    ref.onDispose(() {
      unawaited(events.cancel());
      _mfaDeadline?.cancel();
    });
    // A browser that never signed in here has no session to look for.
    final mode = ref.watch(sessionModeProvider);
    if (mode == SessionMode.cookie && !ref.watch(sessionHintProvider).present) {
      return const SignedOut();
    }
    unawaited(Future.microtask(_boot));
    return const AuthBooting();
  }

  /// Checks the start-up session again, after [AuthUnavailable].
  void retry() {
    if (state is! AuthUnavailable) return;
    state = const AuthBooting();
    unawaited(_boot());
  }

  /// Checks the password. Signs in, or moves to [AwaitingMfa]; a refusal
  /// throws its [ApiException] (wrong credentials, unverified address,
  /// rate limited...). [captchaToken] answers a `captcha_required`.
  Future<void> signIn({
    required String email,
    required String password,
    String? captchaToken,
  }) async {
    final result = await _api.login(
      email: email,
      password: password,
      captchaToken: captchaToken,
    );
    if (!ref.mounted) return;
    switch (result) {
      case LoginMfaRequired(:final challenge):
        _awaitMfa(challenge);
      case LoginSignedIn():
        _hint.present = true;
        await _loadProfile();
    }
  }

  /// Completes the sign-in with a 6-digit code or a recovery code. An
  /// expired or spent challenge goes back to the sign-in page
  /// ([AuthNotice.mfaExpired]); a wrong code throws its [ApiException].
  Future<void> verifyMfa(String code) async {
    final pending = state;
    if (pending is! AwaitingMfa) return;
    try {
      await _api.verifyMfa(mfaToken: pending.challenge.mfaToken, code: code);
    } on ApiProblemException catch (e) {
      if (e.code != ProblemCode.mfaChallengeInvalid) rethrow;
      if (ref.mounted && state == pending) {
        _setSignedOut(AuthNotice.mfaExpired);
      }
      return;
    }
    if (!ref.mounted) return;
    _mfaDeadline?.cancel();
    _hint.present = true;
    await _loadProfile();
  }

  /// Leaves the second step for the sign-in page.
  void cancelMfa() {
    if (state is AwaitingMfa) _setSignedOut(null);
  }

  /// Signs out. A device always forgets its tokens, even when the server
  /// cannot be told (that session then just runs out). A browser stays
  /// signed in and throws when the call fails: its `HttpOnly` cookies only
  /// go away through the server, and signing out of a shared computer has
  /// to be real.
  Future<void> signOut() async {
    if (state is! SignedIn) return;
    try {
      await _api.logout();
    } on ApiException catch (e) {
      // A 401 here: the session was already gone (and could not be renewed).
      final gone = e is ApiProblemException && e.status == 401;
      if (_mode == SessionMode.cookie && !gone) rethrow;
    }
    await _end(null);
  }

  /// The session ended outside this controller (a password reset): forget
  /// it and show [notice] on the sign-in page.
  Future<void> sessionEnded(AuthNotice notice) => _end(notice);

  /// A newer copy of the profile from an account call (a rename, saved
  /// preferences), applied only while [userId] is still the one signed in:
  /// a late answer for an earlier session changes nothing. [update] gets
  /// the current profile and changes only what the call answered, so two
  /// answers racing never roll each other back. The local language and
  /// theme stay as they are: only sign-in and start-up replace them.
  void updateMe(String userId, Me Function(Me current) update) {
    final current = state;
    if (current is! SignedIn || current.me.id != userId) return;
    final next = update(current.me);
    if (next.id == userId && next != current.me) state = SignedIn(next);
  }

  /// Reads the profile again (`GET /me`) after the account changed
  /// elsewhere (MFA turned on or off from another device, say) and applies
  /// it like [updateMe]: the local language and theme stay. A failure is
  /// the caller's to show.
  Future<void> refreshProfile() async {
    final current = state;
    if (current is! SignedIn) return;
    final me = await _api.me();
    if (ref.mounted) updateMe(current.me.id, (_) => me);
  }

  Future<void> _boot() async {
    if (_mode == SessionMode.bearer && await _tokens.read() == null) {
      if (ref.mounted) state = const SignedOut();
      return;
    }
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    final Me me;
    try {
      me = await _api.me();
    } on ApiProblemException catch (e) {
      if (!ref.mounted) return;
      if (e.status == 401) {
        // Not renewable: the API client already dropped the tokens.
        await _end(AuthNotice.sessionExpired);
      } else {
        state = AuthUnavailable(e);
      }
      return;
    } on ApiException catch (e) {
      if (ref.mounted) state = AuthUnavailable(e);
      return;
    }
    if (!ref.mounted) return;
    // The language and theme first, so the first signed-in frame has them.
    final saving = ref
        .read(preferencesProvider.notifier)
        .replaceAll(me.preferences.app);
    state = SignedIn(me);
    await saving;
  }

  void _awaitMfa(MfaChallenge challenge) {
    _mfaDeadline?.cancel();
    final pending = AwaitingMfa(challenge);
    state = pending;
    _mfaDeadline = Timer(Duration(seconds: challenge.expiresIn), () {
      if (ref.mounted && state == pending) {
        _setSignedOut(AuthNotice.mfaExpired);
      }
    });
  }

  void _onSessionEvent(SessionEvent event) {
    switch (event) {
      case SessionEvent.expired:
        if (state is SignedIn || state is AuthBooting) {
          _hint.present = false;
          state = const SignedOut(notice: AuthNotice.sessionExpired);
        }
    }
  }

  Future<void> _end(AuthNotice? notice) async {
    _hint.present = false;
    await _tokens.clear();
    if (ref.mounted) _setSignedOut(notice);
  }

  void _setSignedOut(AuthNotice? notice) {
    _mfaDeadline?.cancel();
    state = SignedOut(notice: notice);
  }
}
