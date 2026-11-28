import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/contrast.dart';
import '../../../helpers/frame.dart';

void main() {
  Widget trigger({bool destructive = false}) => Builder(
    builder: (context) => ShadButton(
      onPressed: () => showMonthraToast(
        context,
        title: 'Não foi salvo',
        description: 'Tente de novo.',
        destructive: destructive,
        closeLabel: 'Fechar',
      ),
      child: const Text('Mostrar'),
    ),
  );

  Future<void> show(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    Brightness brightness = Brightness.light,
    bool destructive = false,
  }) async {
    tester.reduceMotion();
    await tester.pumpFrame(
      trigger(destructive: destructive),
      size: size,
      brightness: brightness,
    );
    await tester.tap(find.text('Mostrar'));
    await tester.pumpAndSettle();
  }

  testWidgets('is read out once, both lines together', (tester) async {
    final semantics = tester.ensureSemantics();
    await show(tester);
    expect(
      find.semantics.byPredicate(
        (node) =>
            node.flagsCollection.isLiveRegion &&
            node.label == 'Não foi salvo\nTente de novo.',
      ),
      findsOne,
    );
    semantics.dispose();
  });

  testWidgets('closes with a labeled 44 px button', (tester) async {
    await show(tester);
    final close = find.bySemanticsLabel('Fechar');
    expect(close, findsOneWidget);
    final button = find.ancestor(
      of: find.byIcon(LucideIcons.x300),
      matching: find.byType(ShadIconButton),
    );
    expect(tester.getSize(button), const Size(44, 44));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Não foi salvo'), findsNothing);
  });

  testWidgets('goes away by itself', (tester) async {
    await show(tester);
    await tester.pump(MonthraToastDuration.info);
    await tester.pumpAndSettle();
    expect(find.text('Não foi salvo'), findsNothing);
  });

  testWidgets('shows on top on a phone, at the bottom elsewhere', (
    tester,
  ) async {
    await show(tester, size: const Size(390, 844));
    expect(tester.getTopLeft(find.text('Não foi salvo')).dy, lessThan(200));
    await tester.pump(MonthraToastDuration.info);
    await tester.pumpAndSettle();

    await show(tester);
    expect(tester.getTopLeft(find.text('Não foi salvo')).dy, greaterThan(600));
  });

  for (final brightness in Brightness.values) {
    for (final destructive in [false, true]) {
      testWidgets('reads at AA contrast: ${brightness.name}'
          '${destructive ? ', destructive' : ''}', (tester) async {
        await show(tester, brightness: brightness, destructive: destructive);
        expect(contrastIssues(tester), isEmpty);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      });
    }
  }
}
