// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authenticator_launcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authenticatorLauncher)
final authenticatorLauncherProvider = AuthenticatorLauncherProvider._();

final class AuthenticatorLauncherProvider
    extends
        $FunctionalProvider<
          AuthenticatorLauncher,
          AuthenticatorLauncher,
          AuthenticatorLauncher
        >
    with $Provider<AuthenticatorLauncher> {
  AuthenticatorLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authenticatorLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authenticatorLauncherHash();

  @$internal
  @override
  $ProviderElement<AuthenticatorLauncher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthenticatorLauncher create(Ref ref) {
    return authenticatorLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthenticatorLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthenticatorLauncher>(value),
    );
  }
}

String _$authenticatorLauncherHash() =>
    r'23597ffb23845f1cdbf5198a85881710d27b2130';
