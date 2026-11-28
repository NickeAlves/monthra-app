import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../helpers/frame.dart';

void main() {
  Future<List<String>> pumpButtons(WidgetTester tester, Size size) async {
    final taps = <String>[];
    await tester.pumpFrame(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthraTapTarget(
            child: ShadButton(
              onPressed: () => taps.add('save'),
              child: const Text('Salvar'),
            ),
          ),
          MonthraTapTarget(
            child: ShadIconButton.ghost(
              onPressed: () => taps.add('next'),
              icon: const Icon(LucideIcons.chevronRight300, size: 16),
            ),
          ),
        ],
      ),
      size: size,
    );
    return taps;
  }

  // ShadIconButton draws a ShadButton inside: find each by what it shows.
  Finder control(Type type) => type == ShadButton
      ? find.widgetWithText(ShadButton, 'Salvar')
      : find.byType(ShadIconButton);

  Rect drawn(WidgetTester tester, Type type) => tester.getRect(control(type));

  Rect target(WidgetTester tester, Type type) => tester.getRect(
    find
        .ancestor(of: control(type), matching: find.byType(MonthraTapTarget))
        .first,
  );

  testWidgets('draws 34 px controls inside a 44 px target on a phone', (
    tester,
  ) async {
    final taps = await pumpButtons(tester, const Size(390, 844));
    expect(drawn(tester, ShadButton).height, MonthraLayout.controlHeight);
    expect(target(tester, ShadButton).height, MonthraLayout.minTouchTarget);
    expect(drawn(tester, ShadIconButton).size, const Size.square(34));
    expect(target(tester, ShadIconButton).size, const Size.square(44));

    // The margin above the drawn button and beside the icon button.
    final save = drawn(tester, ShadButton);
    await tester.tapAt(Offset(save.left + 4, save.top - 4));
    final next = drawn(tester, ShadIconButton);
    await tester.tapAt(Offset(next.right + 4, next.center.dy));
    await tester.pump();
    expect(taps, ['save', 'next']);

    // Beside the button, outside its target, nothing happens.
    await tester.tapAt(Offset(save.right + 8, save.center.dy));
    await tester.pump();
    expect(taps, ['save', 'next']);
  });

  testWidgets('assistive technologies read one 44 px button', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpButtons(tester, const Size(390, 844));
    final node = tester.getSemantics(find.text('Salvar'));
    expect(node.rect.size.height, MonthraLayout.minTouchTarget);
    // The merged data: the button's flags and actions, on the 44 px node.
    final data = node.getSemanticsData();
    expect(data.label, 'Salvar');
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('keeps the drawn size on a desktop', (tester) async {
    await pumpButtons(tester, const Size(1280, 800));
    expect(target(tester, ShadButton), drawn(tester, ShadButton));
    expect(target(tester, ShadIconButton).size, const Size.square(34));
  });

  testWidgets('the focus ring still shows around the drawn button', (
    tester,
  ) async {
    await pumpButtons(tester, const Size(390, 844));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final focused = FocusManager.instance.primaryFocus?.context;
    expect(focused, isNotNull);
    expect(
      find.ancestor(
        of: find.byWidget(focused!.widget),
        matching: control(ShadButton),
      ),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  });
}
