import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/categories/data/categories_api.dart';
import 'package:monthra/features/categories/data/models/category.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';

void main() {
  test('list reads the categories', () async {
    final server = ProfileServer();
    final categories = await CategoriesApi(fakeApi(server.adapter).api).list();

    expect(server.adapter.paths, ['GET /api/v1/categories']);
    expect(categories, hasLength(9));
    final groceries = categories[1];
    expect(groceries.name, 'Mercado');
    expect(groceries.kind, CategoryKind.expense);
    expect(groceries.icon, 'shopping-cart');
    expect(groceries.color, '#22C55E');
    expect(groceries.defaultKey, 'groceries');
    expect(categories[7].kind, CategoryKind.income);
    expect(groceries.toString(), isNot(contains('Mercado')));
  });

  test("the owner's own categories have no default key", () async {
    final server = ProfileServer(
      categories: [categoryJson(id: 'c1', name: 'Café', kind: 'savings')],
    );
    final category = (await CategoriesApi(
      fakeApi(server.adapter).api,
    ).list()).single;
    expect(category.defaultKey, isNull);
    expect(category.kind, CategoryKind.unknown);
  });
}
