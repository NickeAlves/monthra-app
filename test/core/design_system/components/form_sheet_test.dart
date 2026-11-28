import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

const MonthraFormSheetLabels labels = (
  close: 'Fechar',
  discardTitle: 'Descartar as alterações?',
  discard: 'Descartar',
  keepEditing: 'Continuar editando',
);

void main() {
  /// A button that opens a form sheet on a [size] window; [answers] gets
  /// what the route answered.
  Future<List<String?>> pumpOpener(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    bool dirty = false,
    bool busy = false,
  }) async {
    final answers = <String?>[];
    tester.reduceMotion();
    await tester.pumpFrame(
      Builder(
        builder: (context) => ShadButton(
          onPressed: () async => answers.add(
            await showMonthraFormSheet<String>(
              context,
              barrierLabel: 'Fechar',
              builder: (context) => MonthraFormSheet(
                title: 'Nova conta',
                description: 'Onde o dinheiro fica.',
                labels: labels,
                dirty: dirty,
                busy: busy,
                actions: [
                  MonthraTapTarget(
                    child: ShadButton(
                      onPressed: () => Navigator.of(context).pop('saved'),
                      child: const Text('Salvar'),
                    ),
                  ),
                ],
                child: const Text('Campos'),
              ),
            ),
          ),
          child: const Text('Abrir'),
        ),
      ),
      size: size,
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    return answers;
  }

  Future<void> close(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Fechar').last);
    await tester.pumpAndSettle();
  }

  testWidgets('is a dialog on a desktop', (tester) async {
    await pumpOpener(tester);
    expect(find.byType(ShadDialog), findsOneWidget);
    expect(find.byType(ShadSheet), findsNothing);
    expect(find.text('Campos'), findsOneWidget);
    // Centered, no wider than the dialog's width.
    expect(
      tester.getRect(find.text('Nova conta')).left,
      greaterThanOrEqualTo((1280 - MonthraFormSheet.dialogWidth) / 2),
    );
  });

  testWidgets('is a bottom sheet on a phone', (tester) async {
    await pumpOpener(tester, size: const Size(390, 844));
    // (a ShadSheet draws a ShadDialog inside)
    expect(find.byType(ShadSheet), findsOneWidget);
    final rect = tester.getRect(find.byType(ShadSheet));
    expect(rect.bottom, 844);
    expect(rect.width, 390);
  });

  testWidgets('answers what the form saved', (tester) async {
    final answers = await pumpOpener(tester);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(answers, ['saved']);
    expect(find.text('Campos'), findsNothing);
  });

  testWidgets('closes without asking while unchanged', (tester) async {
    final answers = await pumpOpener(tester);
    await close(tester);
    expect(answers, [null]);
    expect(find.text(labels.discardTitle), findsNothing);
  });

  testWidgets('asks before throwing changes away', (tester) async {
    final answers = await pumpOpener(tester, dirty: true);
    await close(tester);
    expect(find.text(labels.discardTitle), findsOneWidget);

    await tester.tap(find.text(labels.keepEditing));
    await tester.pumpAndSettle();
    expect(find.text('Campos'), findsOneWidget);
    expect(answers, isEmpty);

    // Esc asks too.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(labels.discardTitle), findsOneWidget);
    await tester.tap(find.text(labels.discard));
    await tester.pumpAndSettle();
    expect(find.text('Campos'), findsNothing);
    expect(answers, [null]);
  });

  testWidgets('Esc still asks after a tap that leaves no focus', (
    tester,
  ) async {
    await pumpOpener(tester, dirty: true);
    // Focus falls above the route, as a text field's tap outside does.
    FocusManager.instance.rootScope.requestFocus();
    await tester.pump();
    await tester.tap(find.text('Campos'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text(labels.discardTitle), findsOneWidget);
  });

  testWidgets('a tap on the barrier asks too', (tester) async {
    await pumpOpener(tester, dirty: true);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text(labels.discardTitle), findsOneWidget);
  });

  testWidgets('stays while a save is in flight', (tester) async {
    final answers = await pumpOpener(tester, dirty: true, busy: true);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('Campos'), findsOneWidget);
    expect(find.text(labels.discardTitle), findsNothing);
    expect(answers, isEmpty);
  });

  testWidgets('names itself as a dialog', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpOpener(tester, size: const Size(390, 844));
    expect(
      tester.getSemantics(find.byType(MonthraFormSheet)),
      isSemantics(label: 'Nova conta', scopesRoute: true, namesRoute: true),
    );
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
