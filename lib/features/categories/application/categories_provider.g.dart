// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every category of the signed-in person. Reset when the signed-in person
/// changes, and read again when the UI language does: the server names the
/// default categories in the `Accept-Language`. Empty signed out.

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

/// Every category of the signed-in person. Reset when the signed-in person
/// changes, and read again when the UI language does: the server names the
/// default categories in the `Accept-Language`. Empty signed out.

final class CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// Every category of the signed-in person. Reset when the signed-in person
  /// changes, and read again when the UI language does: the server names the
  /// default categories in the `Accept-Language`. Empty signed out.
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: noProviderRetry,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    return categories(ref);
  }
}

String _$categoriesHash() => r'63fae1ea4d8fc8141e7b3e3fa0a5c5065d6d5598';
