// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mfaApi)
final mfaApiProvider = MfaApiProvider._();

final class MfaApiProvider extends $FunctionalProvider<MfaApi, MfaApi, MfaApi>
    with $Provider<MfaApi> {
  MfaApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mfaApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mfaApiHash();

  @$internal
  @override
  $ProviderElement<MfaApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MfaApi create(Ref ref) {
    return mfaApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MfaApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MfaApi>(value),
    );
  }
}

String _$mfaApiHash() => r'b1a6104b1d6ff112e0722785c3bf72cb359f375b';
