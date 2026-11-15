// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This build's configuration, read in `main` ([Env.fromEnvironment]) and
/// passed in with `envProvider.overrideWithValue` (see `appOverrides`).

@ProviderFor(env)
final envProvider = EnvProvider._();

/// This build's configuration, read in `main` ([Env.fromEnvironment]) and
/// passed in with `envProvider.overrideWithValue` (see `appOverrides`).

final class EnvProvider extends $FunctionalProvider<Env, Env, Env>
    with $Provider<Env> {
  /// This build's configuration, read in `main` ([Env.fromEnvironment]) and
  /// passed in with `envProvider.overrideWithValue` (see `appOverrides`).
  EnvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envHash();

  @$internal
  @override
  $ProviderElement<Env> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Env create(Ref ref) {
    return env(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Env value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Env>(value),
    );
  }
}

String _$envHash() => r'9c7c706816f5c4caaf40d6988f4e7f496d2d7c45';
