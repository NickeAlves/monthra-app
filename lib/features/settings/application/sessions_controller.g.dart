// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in devices of the account, this one first, then the most
/// recently used. Loaded while the sessions card shows; reset when the
/// signed-in person changes. Refusals of [revoke] and [revokeOthers] are
/// thrown for the card to show; the list stays as it was.

@ProviderFor(SessionsController)
final sessionsControllerProvider = SessionsControllerProvider._();

/// The signed-in devices of the account, this one first, then the most
/// recently used. Loaded while the sessions card shows; reset when the
/// signed-in person changes. Refusals of [revoke] and [revokeOthers] are
/// thrown for the card to show; the list stays as it was.
final class SessionsControllerProvider
    extends $AsyncNotifierProvider<SessionsController, List<SessionInfo>> {
  /// The signed-in devices of the account, this one first, then the most
  /// recently used. Loaded while the sessions card shows; reset when the
  /// signed-in person changes. Refusals of [revoke] and [revokeOthers] are
  /// thrown for the card to show; the list stays as it was.
  SessionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'sessionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionsControllerHash();

  @$internal
  @override
  SessionsController create() => SessionsController();
}

String _$sessionsControllerHash() =>
    r'05ea4b8c443a42aebb3f60de90fedd83fdf4c03b';

/// The signed-in devices of the account, this one first, then the most
/// recently used. Loaded while the sessions card shows; reset when the
/// signed-in person changes. Refusals of [revoke] and [revokeOthers] are
/// thrown for the card to show; the list stays as it was.

abstract class _$SessionsController extends $AsyncNotifier<List<SessionInfo>> {
  FutureOr<List<SessionInfo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SessionInfo>>, List<SessionInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SessionInfo>>, List<SessionInfo>>,
              AsyncValue<List<SessionInfo>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
