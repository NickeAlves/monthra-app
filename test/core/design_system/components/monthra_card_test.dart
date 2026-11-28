import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  testWidgets('shows its parts on the card surface', (tester) async {
    await tester.pumpFrame(
      const MonthraCard(
        title: Text('Saldo'),
        description: Text('Todas as contas'),
        footer: Text('Atualizado agora'),
        child: Text(r'R$ 10,00'),
      ),
    );
    for (final text in ['Saldo', 'Todas as contas', 'Atualizado agora']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byType(FocusableActionDetector), findsNothing);
    final card = tester.widget<ShadCard>(find.byType(ShadCard));
    expect(card.padding, const EdgeInsets.all(MonthraSpacing.x5));
  });

  testWidgets('pads less on mobile', (tester) async {
    await tester.pumpFrame(
      const MonthraCard(child: Text('x')),
      size: const Size(400, 800),
    );
    final card = tester.widget<ShadCard>(find.byType(ShadCard));
    expect(card.padding, const EdgeInsets.all(MonthraSpacing.x4));
  });

  group('with onTap', () {
    late int taps;
    Widget card() => MonthraCard(
      semanticLabel: 'Nubank',
      onTap: () => taps++,
      title: const Text('Nubank'),
      child: const Text('Cartão'),
    );
    setUp(() => taps = 0);

    testWidgets('is a button for assistive technologies', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpFrame(card());
      expect(
        tester.getSemantics(find.byType(MonthraCard)),
        isSemantics(
          label: 'Nubank',
          isButton: true,
          hasTapAction: true,
          isFocusable: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('activates on tap, Enter and Space', (tester) async {
      await tester.pumpFrame(card());
      await tester.tap(find.byType(MonthraCard));
      expect(taps, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(taps, 2);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 3);
    });

    testWidgets('draws the focus ring when focused from the keyboard', (
      tester,
    ) async {
      await tester.pumpFrame(card());
      Border? ring() =>
          (tester
                          .widget<DecoratedBox>(
                            find
                                .descendant(
                                  of: find.byType(MonthraCard),
                                  matching: find.byType(DecoratedBox),
                                )
                                .first,
                          )
                          .decoration
                      as BoxDecoration)
                  .border
              as Border?;
      expect(ring(), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final scheme = tester.themeAt(find.byType(MonthraCard)).colorScheme;
      expect(ring()!.top.color, scheme.ring);
      expect(ring()!.top.width, 2);
    });

    testWidgets('darkens its border on hover', (tester) async {
      // Hover highlights show with a pointer (desktop and web), as here.
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await tester.pumpFrame(card());
      final scheme = tester.themeAt(find.byType(MonthraCard)).colorScheme;
      Color border() =>
          tester.widget<ShadCard>(find.byType(ShadCard)).border!.top!.color!;
      expect(border(), scheme.border);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(MonthraCard)));
      await tester.pump();
      await tester.pump(MonthraMotion.fast);
      expect(border(), isNot(scheme.border));
    });
  });
}
