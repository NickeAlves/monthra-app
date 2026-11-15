import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  testWidgets('a category icon is decorative without a label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(
      const CategoryIcon(icon: 'shopping-cart', color: '#22C55E'),
    );
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, LucideIcons.shoppingCart);
    expect(icon.size, CategoryIconSize.md.glyph);
    expect(find.bySemanticsLabel('Mercado'), findsNothing);

    await tester.pumpFrame(
      const CategoryIcon(
        icon: 'shopping-cart',
        color: '#22C55E',
        semanticLabel: 'Mercado',
      ),
    );
    expect(find.bySemanticsLabel('Mercado'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('sizes the tile', (tester) async {
    await tester.pumpFrame(
      const CategoryIcon(
        icon: 'car',
        color: '#3B82F6',
        size: CategoryIconSize.lg,
      ),
    );
    expect(tester.getSize(find.byType(CategoryIcon)), const Size.square(44));
  });

  testWidgets('an unknown icon or color still draws', (tester) async {
    await tester.pumpFrame(
      const CategoryIcon(icon: 'nope', color: 'not a color'),
    );
    expect(tester.takeException(), isNull);
    expect(tester.widget<Icon>(find.byType(Icon)).icon, CategoryIcons.fallback);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the badge label reads on its tint (${brightness.name})', (
      tester,
    ) async {
      await tester.pumpFrame(
        const CategoryBadge(
          icon: 'zap',
          color: '#EAB308',
          label: 'Contas da casa',
        ),
        brightness: brightness,
      );
      final text = tester.widget<Text>(find.text('Contas da casa'));
      final tint =
          (tester
                      .widget<DecoratedBox>(
                        find
                            .descendant(
                              of: find.byType(CategoryBadge),
                              matching: find.byType(DecoratedBox),
                            )
                            .first,
                      )
                      .decoration
                  as BoxDecoration)
              .color!;
      expect(
        contrastRatio(text.style!.color!, tint),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
