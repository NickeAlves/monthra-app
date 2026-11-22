// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unsaved_recovery_codes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// New recovery codes are on screen and not saved yet (their checkbox is
/// unticked): leaving their page asks first. Reset when the signed-in
/// person changes, so a sign-out never waits on it.

@ProviderFor(UnsavedRecoveryCodes)
final unsavedRecoveryCodesProvider = UnsavedRecoveryCodesProvider._();

/// New recovery codes are on screen and not saved yet (their checkbox is
/// unticked): leaving their page asks first. Reset when the signed-in
/// person changes, so a sign-out never waits on it.
final class UnsavedRecoveryCodesProvider
    extends $NotifierProvider<UnsavedRecoveryCodes, bool> {
  /// New recovery codes are on screen and not saved yet (their checkbox is
  /// unticked): leaving their page asks first. Reset when the signed-in
  /// person changes, so a sign-out never waits on it.
  UnsavedRecoveryCodesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unsavedRecoveryCodesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unsavedRecoveryCodesHash();

  @$internal
  @override
  UnsavedRecoveryCodes create() => UnsavedRecoveryCodes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$unsavedRecoveryCodesHash() =>
    r'd78e43a432d7beba6451010c8bc72920022977ca';

/// New recovery codes are on screen and not saved yet (their checkbox is
/// unticked): leaving their page asks first. Reset when the signed-in
/// person changes, so a sign-out never waits on it.

abstract class _$UnsavedRecoveryCodes extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
