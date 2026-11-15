import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';

import '../../../helpers/frame.dart';

const ptBR = Locale('pt', 'BR');

/// The text shown, with intl's no-break spaces as plain spaces.
String shown(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(of: find.byType(AmountText), matching: find.byType(Text)),
    )
    .data!
    .replaceAll(' ', ' ');

Color shownColor(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(of: find.byType(AmountText), matching: find.byType(Text)),
    )
    .style!
    .color!;

void main() {
  testWidgets('formats in the given locale', (tester) async {
    await tester.pumpFrame(
      const AmountText(123456, currency: Currency.brl, locale: ptBR),
    );
    expect(shown(tester), r'R$ 1.234,56');
  });

  testWidgets("follows the app's locale by default", (tester) async {
    // No supported locales yet (i18n comes next): the app runs in en-US.
    await tester.pumpFrame(const AmountText(123456, currency: Currency.usd));
    expect(shown(tester), r'$1,234.56');
  });

  testWidgets('colors and signs by kind', (tester) async {
    await tester.pumpFrame(
      const AmountText(
        4500,
        currency: Currency.brl,
        kind: AmountKind.income,
        locale: ptBR,
      ),
    );
    final scheme = tester.themeAt(find.byType(AmountText)).colorScheme;
    expect(shown(tester), r'+R$ 45,00');
    expect(shownColor(tester), scheme.income);

    await tester.pumpFrame(
      const AmountText(
        4500,
        currency: Currency.brl,
        kind: AmountKind.expense,
        locale: ptBR,
      ),
    );
    expect(
      shown(tester),
      '−'
      r'R$ 45,00',
    );
    expect(shownColor(tester), scheme.expense);

    await tester.pumpFrame(
      const AmountText(-4500, currency: Currency.brl, locale: ptBR),
    );
    expect(
      shown(tester),
      '−'
      r'R$ 45,00',
    );
    expect(shownColor(tester), scheme.foreground);
  });

  testWidgets('a sign override wins over the kind', (tester) async {
    await tester.pumpFrame(
      const AmountText(
        4500,
        currency: Currency.brl,
        kind: AmountKind.expense,
        sign: MoneySign.never,
        locale: ptBR,
      ),
    );
    expect(shown(tester), r'R$ 45,00');
  });

  testWidgets('uses the tabular style of its size', (tester) async {
    await tester.pumpFrame(
      const AmountText(100, currency: Currency.brl, size: AmountSize.display),
    );
    final style = tester
        .widget<Text>(
          find.descendant(
            of: find.byType(AmountText),
            matching: find.byType(Text),
          ),
        )
        .style!;
    expect(style.fontSize, 40);
    expect(style.fontFeatures, MonthraTypography.tabularFigures);
  });

  group('animated', () {
    Widget amount(int minor) =>
        AmountText(minor, currency: Currency.brl, locale: ptBR, animate: true);

    testWidgets('counts to a new value and reads only the final one', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpFrame(amount(10000));
      expect(shown(tester), r'R$ 100,00');

      await tester.pumpFrame(amount(20000));
      await tester.pump(const Duration(milliseconds: 100));
      final midway = shown(tester);
      expect(midway, isNot(r'R$ 100,00'));
      expect(midway, isNot(r'R$ 200,00'));
      expect(find.bySemanticsLabel(RegExp(r'R\$\s200,00')), findsOneWidget);

      await tester.pump(MonthraMotion.number);
      expect(shown(tester), r'R$ 200,00');
      semantics.dispose();
    });

    testWidgets('jumps when the platform asks for less motion', (tester) async {
      tester.reduceMotion();
      await tester.pumpFrame(amount(10000));
      await tester.pumpFrame(amount(20000));
      await tester.pump();
      expect(shown(tester), r'R$ 200,00');
    });

    testWidgets('does not count on first show', (tester) async {
      await tester.pumpFrame(amount(20000));
      expect(shown(tester), r'R$ 200,00');
    });
  });

  testWidgets('scales down instead of cutting digits', (tester) async {
    await tester.pumpFrame(
      const SizedBox(
        width: 80,
        child: AmountText(
          MoneyFormat.maxMinor,
          currency: Currency.brl,
          size: AmountSize.display,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(FittedBox), findsOneWidget);
    expect(
      tester.getSize(find.byType(AmountText)).width,
      lessThanOrEqualTo(80),
    );
  });
}
