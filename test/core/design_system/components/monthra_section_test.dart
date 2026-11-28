import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

import '../../../helpers/frame.dart';

void main() {
  BoxDecoration? decorationOf(WidgetTester tester) {
    final boxes = find.descendant(
      of: find.byType(MonthraSection),
      matching: find.byType(DecoratedBox),
    );
    if (boxes.evaluate().isEmpty) return null;
    return tester.widget<DecoratedBox>(boxes.first).decoration as BoxDecoration;
  }

  testWidgets('sits on the page under a hairline, its title a heading', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(
      const MonthraSection(
        title: Text('Contas'),
        description: Text('Saldo de hoje'),
        trailing: Text('Ver todas'),
        child: Text(r'R$ 10,00'),
      ),
    );
    for (final text in ['Contas', 'Saldo de hoje', 'Ver todas', r'R$ 10,00']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(
      tester.getSemantics(find.text('Contas')),
      matchesSemantics(label: 'Contas', isHeader: true),
    );

    final theme = tester.themeAt(find.byType(MonthraSection));
    final decoration = decorationOf(tester)!;
    expect(decoration.color, isNull);
    expect(decoration.boxShadow, isNull);
    expect(
      decoration.border,
      Border(top: BorderSide(color: theme.colorScheme.border)),
    );
    semantics.dispose();
  });

  testWidgets('drops the hairline when asked', (tester) async {
    await tester.pumpFrame(
      const MonthraSection(divider: false, child: Text('x')),
    );
    expect(decorationOf(tester), isNull);
    expect(find.text('x'), findsOneWidget);
  });
}
