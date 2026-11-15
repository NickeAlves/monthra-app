// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The web's "may be signed in" mark ([SessionHint]).

@ProviderFor(sessionHint)
final sessionHintProvider = SessionHintProvider._();

/// The web's "may be signed in" mark ([SessionHint]).

final class SessionHintProvider
    extends $FunctionalProvider<SessionHint, SessionHint, SessionHint>
    with $Provider<SessionHint> {
  /// The web's "may be signed in" mark ([SessionHint]).
  SessionHintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionHintProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHintHash();

  @$internal
  @override
  $ProviderElement<SessionHint> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SessionHint create(Ref ref) {
    return sessionHint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionHint value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionHint>(value),
    );
  }
}

String _$sessionHintHash() => r'd12ad578bcb4deb73b7d50f1c8b586b6836fd49b';

/// The session of the app ([AuthState]) and the ways in and out of it.
///
/// - At start-up a session may exist when the device holds tokens, or, on
///   the web, when [SessionHint] says so; then `GET /me` decides. Without
///   one the app opens signed out at once.
/// - Whenever the profile loads (sign-in and start-up) its language and
///   theme replace the local ones: the server's value wins (§7.6).
/// - A session the API client could not renew ([SessionEvent.expired])
///   signs the app out with [AuthNotice.sessionExpired].

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// The session of the app ([AuthState]) and the ways in and out of it.
///
/// - At start-up a session may exist when the device holds tokens, or, on
///   the web, when [SessionHint] says so; then `GET /me` decides. Without
///   one the app opens signed out at once.
/// - Whenever the profile loads (sign-in and start-up) its language and
///   theme replace the local ones: the server's value wins (§7.6).
/// - A session the API client could not renew ([SessionEvent.expired])
///   signs the app out with [AuthNotice.sessionExpired].
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthState> {
  /// The session of the app ([AuthState]) and the ways in and out of it.
  ///
  /// - At start-up a session may exist when the device holds tokens, or, on
  ///   the web, when [SessionHint] says so; then `GET /me` decides. Without
  ///   one the app opens signed out at once.
  /// - Whenever the profile loads (sign-in and start-up) its language and
  ///   theme replace the local ones: the server's value wins (§7.6).
  /// - A session the API client could not renew ([SessionEvent.expired])
  ///   signs the app out with [AuthNotice.sessionExpired].
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authControllerHash() => r'3fa91d8683bef061bc944e7f425c061f153c9cf8';

/// The session of the app ([AuthState]) and the ways in and out of it.
///
/// - At start-up a session may exist when the device holds tokens, or, on
///   the web, when [SessionHint] says so; then `GET /me` decides. Without
///   one the app opens signed out at once.
/// - Whenever the profile loads (sign-in and start-up) its language and
///   theme replace the local ones: the server's value wins (§7.6).
/// - A session the API client could not renew ([SessionEvent.expired])
///   signs the app out with [AuthNotice.sessionExpired].

abstract class _$AuthController extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
