import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  testWidgets('the empty state shows its texts and action', (tester) async {
    var created = 0;
    await tester.pumpFrame(
      EmptyState(
        title: 'Nenhuma transação',
        message: 'Elas aparecem aqui.',
        action: ShadButton(
          onPressed: () => created++,
          child: const Text('Nova'),
        ),
      ),
    );
    expect(find.text('Nenhuma transação'), findsOneWidget);
    expect(find.text('Elas aparecem aqui.'), findsOneWidget);
    await tester.tap(find.text('Nova'));
    expect(created, 1);
  });

  testWidgets('the error state retries and is announced', (tester) async {
    final semantics = tester.ensureSemantics();
    var retries = 0;
    await tester.pumpFrame(
      ErrorState(
        title: 'Falhou',
        retryLabel: 'Tentar de novo',
        onRetry: () => retries++,
      ),
    );
    expect(find.byIcon(LucideIcons.circleAlert300), findsOneWidget);
    await tester.tap(find.text('Tentar de novo'));
    expect(retries, 1);
    expect(
      tester.getSemantics(find.text('Falhou')),
      isSemantics(label: 'Falhou'),
    );
    final live = find.byWidgetPredicate(
      (w) => w is Semantics && (w.properties.liveRegion ?? false),
    );
    expect(live, findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the error state needs both onRetry and retryLabel', (
    tester,
  ) async {
    expect(() => ErrorState(title: 'x', onRetry: () {}), throwsAssertionError);
    await tester.pumpFrame(const ErrorState(title: 'Sem ação'));
    expect(find.byType(ShadButton), findsNothing);
  });

  testWidgets('copes with twice the text size on a phone', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpFrame(
      ErrorState(
        title: 'Não foi possível carregar suas transações',
        message: 'Verifique sua conexão com a internet e tente de novo.',
        retryLabel: 'Tentar de novo',
        onRetry: () {},
      ),
      size: const Size(320, 800),
    );
    expect(tester.takeException(), isNull);
  });
}
