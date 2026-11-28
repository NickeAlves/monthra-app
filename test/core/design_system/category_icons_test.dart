import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  test('the default categories are the 22 the server seeds', () {
    expect(sampleCategories, hasLength(22));
    expect(sampleCategories.map((c) => c.key).toSet(), hasLength(22));
    expect(sampleCategories.where((c) => c.income), hasLength(6));
  });

  test('every default category icon resolves to its own glyph', () {
    for (final category in sampleCategories) {
      expect(
        CategoryIcons.byName,
        contains(category.icon),
        reason: category.key,
      );
    }
    expect(CategoryIcons.resolve('shopping-cart'), LucideIcons.shoppingCart300);
    expect(CategoryIcons.resolve('hand-heart'), LucideIcons.handHeart300);
  });

  test('an unknown name falls back to the tag icon', () {
    expect(CategoryIcons.resolve('not-an-icon'), CategoryIcons.fallback);
    expect(CategoryIcons.resolve(''), LucideIcons.tag300);
  });

  test('every default color parses', () {
    for (final category in sampleCategories) {
      expect(parseHexColor(category.color), isNotNull, reason: category.key);
    }
  });
}
