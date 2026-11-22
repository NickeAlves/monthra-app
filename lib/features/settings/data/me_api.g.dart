// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(meApi)
final meApiProvider = MeApiProvider._();

final class MeApiProvider extends $FunctionalProvider<MeApi, MeApi, MeApi>
    with $Provider<MeApi> {
  MeApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meApiHash();

  @$internal
  @override
  $ProviderElement<MeApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MeApi create(Ref ref) {
    return meApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MeApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MeApi>(value),
    );
  }
}

String _$meApiHash() => r'5ab603290e19fecc64335b2a8c0b6d4e3bcf778f';
