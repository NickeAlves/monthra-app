import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  testWidgets('a category icon is decorative without a label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(const CategoryIcon(icon: 'shopping-cart'));
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, LucideIcons.shoppingCart);
    expect(icon.size, CategoryIconSize.md.glyph);
    expect(find.bySemanticsLabel('Mercado'), findsNothing);

    await tester.pumpFrame(
      const CategoryIcon(icon: 'shopping-cart', semanticLabel: 'Mercado'),
    );
    expect(find.bySemanticsLabel('Mercado'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('sizes the tile', (tester) async {
    await tester.pumpFrame(
      const CategoryIcon(icon: 'car', size: CategoryIconSize.lg),
    );
    expect(tester.getSize(find.byType(CategoryIcon)), const Size.square(44));
  });

  testWidgets('an unknown icon still draws', (tester) async {
    await tester.pumpFrame(const CategoryIcon(icon: 'nope'));
    expect(tester.takeException(), isNull);
    expect(tester.widget<Icon>(find.byType(Icon)).icon, CategoryIcons.fallback);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the badge label reads on its pill (${brightness.name})', (
      tester,
    ) async {
      await tester.pumpFrame(
        const CategoryBadge(color: '#EAB308', label: 'Contas da casa'),
        brightness: brightness,
      );
      final text = tester.widget<Text>(find.text('Contas da casa'));
      final pill =
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
        contrastRatio(text.style!.color!, pill),
        greaterThanOrEqualTo(4.5),
      );
    });

    testWidgets('a dot moves a pale color to 3:1 (${brightness.name})', (
      tester,
    ) async {
      await tester.pumpFrame(
        const CategoryDot('#EAB308'),
        brightness: brightness,
      );
      final theme = tester.themeAt(find.byType(CategoryDot));
      final dot = CategoryDot.colorOf(theme, '#EAB308');
      expect(
        contrastRatio(dot, theme.colorScheme.background),
        greaterThanOrEqualTo(3),
      );
      final painted =
          (tester
                      .widget<DecoratedBox>(
                        find.descendant(
                          of: find.byType(CategoryDot),
                          matching: find.byType(DecoratedBox),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color;
      expect(painted, dot);
    });
  }

  testWidgets('a dot of an invalid color paints muted', (tester) async {
    await tester.pumpFrame(const CategoryDot('not a color'));
    final theme = tester.themeAt(find.byType(CategoryDot));
    expect(
      CategoryDot.colorOf(theme, 'not a color'),
      theme.colorScheme.mutedForeground,
    );
  });
}
