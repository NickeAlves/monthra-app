import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/categories/data/models/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_api.g.dart';

@Riverpod(keepAlive: true)
CategoriesApi categoriesApi(Ref ref) =>
    CategoriesApi(ref.watch(apiClientProvider));

/// The category routes of the API (the OpenAPI's `categories` tag): the
/// list so far; the categories PR adds the writes. Every failure is an
/// `ApiException`.
class CategoriesApi {
  const new(this._api);

  final ApiClient _api;

  /// Every category of the caller (at most 200); the first call creates
  /// the default ones. Default names come in the `Accept-Language`.
  Future<List<Category>> list() async {
    final response = await _api.get<Map<String, Object?>>('/categories');
    return readJson<List<Category>>(
      response.data,
      (json) => [
        for (final c in json['categories']! as List<Object?>)
          Category.fromJson(c! as Map<String, Object?>),
      ],
    );
  }
}
