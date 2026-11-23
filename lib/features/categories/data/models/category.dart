import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Whether a category sorts expenses or income; it never changes.
enum CategoryKind {
  expense,
  income,

  /// A kind this build does not know yet.
  unknown,
}

/// A category of the caller (`GET /categories`, `Category` in the
/// OpenAPI), the fields the app reads so far.
@freezed
abstract class Category with _$Category {
  const factory({
    required String id,

    /// The owner's name, or the default's name in the caller's language
    /// until renamed.
    required String name,
    @JsonKey(unknownEnumValue: CategoryKind.unknown) required CategoryKind kind,

    /// A Lucide name in kebab case (`shopping-cart`).
    required String icon,

    /// `#RRGGBB`.
    required String color,

    /// The default category this one was created from, or null for the
    /// owner's own.
    required String? defaultKey,
  }) = _Category;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$CategoryFromJson(json);

  // The name may be personal data: never in a log (§6.6).
  @override
  String toString() => 'Category(id: $id, kind: ${kind.name})';
}
