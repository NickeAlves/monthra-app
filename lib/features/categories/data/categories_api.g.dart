// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoriesApi)
final categoriesApiProvider = CategoriesApiProvider._();

final class CategoriesApiProvider
    extends $FunctionalProvider<CategoriesApi, CategoriesApi, CategoriesApi>
    with $Provider<CategoriesApi> {
  CategoriesApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesApiHash();

  @$internal
  @override
  $ProviderElement<CategoriesApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoriesApi create(Ref ref) {
    return categoriesApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesApi>(value),
    );
  }
}

String _$categoriesApiHash() => r'eb9cc0ce10a0775151c06e1eec65baf6a44e4c16';
