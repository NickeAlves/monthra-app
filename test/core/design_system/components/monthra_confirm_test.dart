import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/contrast.dart';
import '../../../helpers/frame.dart';

void main() {
  Future<List<bool>> pumpAsk(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    Size size = const Size(390, 844),
  }) async {
    final answers = <bool>[];
    tester.reduceMotion();
    await tester.pumpFrame(
      Builder(
        builder: (context) => Center(
          child: ShadButton(
            onPressed: () async => answers.add(
              await showMonthraConfirm(
                context,
                title: 'Encerrar as outras sessões?',
                description: 'Os outros dispositivos vão pedir para entrar.',
                confirmLabel: 'Encerrar',
                cancelLabel: 'Cancelar',
                barrierLabel: 'Fechar',
                destructive: true,
              ),
            ),
            child: const Text('Ask'),
          ),
        ),
      ),
      brightness: brightness,
      size: size,
    );
    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    return answers;
  }

  testWidgets('answers true only when confirmed', (tester) async {
    final answers = await pumpAsk(tester);
    expect(find.text('Encerrar as outras sessões?'), findsOneWidget);
    await tester.tap(find.text('Encerrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ask'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(answers, [true, false, false]);
    expect(find.text('Encerrar as outras sessões?'), findsNothing);
  });

  testWidgets('is a named alert dialog', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpAsk(tester);
    expect(
      tester.getSemantics(
        find
            .ancestor(
              of: find.byType(ShadDialog),
              matching: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.scopesRoute == true,
              ),
            )
            .first,
      ),
      isSemantics(label: 'Encerrar as outras sessões?', scopesRoute: true),
    );
    semantics.dispose();
  });

  for (final brightness in Brightness.values) {
    testWidgets('meets the guidelines, ${brightness.name}', (tester) async {
      await pumpAsk(tester, brightness: brightness);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      expect(contrastIssues(tester), isEmpty);
    });
  }
}
