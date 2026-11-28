import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  Widget page() => MonthraPage(
    title: 'Configurações',
    description: 'Perfil e preferências.',
    actions: [ShadButton(onPressed: () {}, child: const Text('Ação'))],
    child: const SizedBox(height: 40, child: Text('Conteúdo')),
  );

  testWidgets('the title is a heading', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(page());
    expect(
      tester.getSemantics(find.text('Configurações')),
      isSemantics(label: 'Configurações', isHeader: true),
    );
    semantics.dispose();
  });

  for (final (size, gutter, below) in [
    (const Size(390, 844), MonthraSpacing.x4, true),
    (const Size(800, 1024), MonthraSpacing.x6, false),
    (const Size(1280, 800), MonthraSpacing.x8, false),
  ]) {
    testWidgets('at ${size.width.toInt()} px: gutter $gutter, actions '
        '${below ? 'below' : 'beside'} the title', (tester) async {
      await tester.pumpFrame(page(), size: size);
      final origin = tester.getTopLeft(find.byType(MonthraPage));
      final title = tester.getTopLeft(find.text('Configurações'));
      expect(title.dx - origin.dx, gutter);
      final action = tester.getTopLeft(find.text('Ação'));
      expect(
        action.dy >
            tester.getBottomLeft(find.text('Perfil e preferências.')).dy,
        below,
      );
    });
  }

  testWidgets('a page under another has its way back above the title', (
    tester,
  ) async {
    var back = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpFrame(
      MonthraPage(
        title: 'Alterar senha',
        back: MonthraPageBack(label: 'Configurações', onPressed: () => back++),
        child: const SizedBox(height: 40),
      ),
      size: const Size(390, 844),
    );
    final link = find.widgetWithText(ShadButton, 'Configurações');
    expect(
      tester.getBottomLeft(link).dy,
      lessThan(tester.getTopLeft(find.text('Alterar senha')).dy),
    );
    // Drawn at 34 px, inside a 44 px touch target.
    final target = find.ancestor(
      of: link,
      matching: find.byType(MonthraTapTarget),
    );
    expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
    expect(
      tester.getTopLeft(link).dx,
      tester.getTopLeft(find.text('Alterar senha')).dx,
      reason: 'the arrow lines up with the title',
    );
    await tester.tap(link);
    expect(back, 1);
    semantics.dispose();
  });

  testWidgets('holds its width on a wide window', (tester) async {
    await tester.pumpFrame(
      const MonthraPage(
        title: 'Painel',
        maxWidth: 600,
        child: SizedBox(key: Key('content'), height: 40),
      ),
      size: const Size(1600, 900),
    );
    expect(tester.getSize(find.byKey(const Key('content'))).width, 600);
  });
}
