import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/forms/money_field.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/frame.dart';

const ptBR = Locale('pt', 'BR');
const esES = Locale('es', 'ES');
const enUS = Locale('en', 'US');

TextEditingValue at(String text) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: text.length),
);

void main() {
  group('MoneyFormat.number', () {
    test('writes the bare amount in the locale', () {
      expect(MoneyFormat.number(123456, Currency.brl, ptBR), '1.234,56');
      expect(MoneyFormat.number(123456, Currency.usd, esES), '1.234,56');
      expect(MoneyFormat.number(123456, Currency.brl, enUS), '1,234.56');
      expect(MoneyFormat.number(5, Currency.brl, ptBR), '0,05');
      expect(MoneyFormat.number(0, Currency.eur, enUS), '0.00');
      expect(MoneyFormat.number(-990, Currency.brl, ptBR), '9,90');
      expect(
        MoneyFormat.number(MoneyFormat.maxMinor, Currency.brl, ptBR),
        '100.000.000.000,00',
      );
    });

    test('names the symbol in the locale', () {
      expect(MoneyFormat.symbolIn(Currency.usd, ptBR), r'US$');
      expect(MoneyFormat.symbolIn(Currency.usd, enUS), r'$');
      expect(MoneyFormat.symbolIn(Currency.eur, esES), '€');
    });
  });

  group('MoneyInputFormatter', () {
    final pt = MoneyInputFormatter(currency: Currency.brl, locale: ptBR);
    final en = MoneyInputFormatter(currency: Currency.usd, locale: enUS);

    /// Types [keys] one by one into an empty field.
    String type(MoneyInputFormatter f, String keys) {
      var value = TextEditingValue.empty;
      for (final key in keys.split('')) {
        value = f.formatEditUpdate(value, at(value.text + key));
      }
      return value.text;
    }

    test('fills the amount from the right', () {
      expect(type(pt, '1'), '0,01');
      expect(type(pt, '12'), '0,12');
      expect(type(pt, '123'), '1,23');
      expect(type(pt, '123456'), '1.234,56');
      expect(type(en, '123456'), '1,234.56');
      expect(type(pt, '007'), '0,07');
    });

    test('keeps only digits, also from a paste', () {
      expect(type(pt, '1a2-3'), '1,23');
      expect(
        pt.formatEditUpdate(TextEditingValue.empty, at('1.234,56')).text,
        '1.234,56',
      );
      expect(
        pt.formatEditUpdate(TextEditingValue.empty, at(r'R$ 99')).text,
        '0,99',
      );
      expect(pt.formatEditUpdate(at('0,12'), at('0,12x')).text, '0,12');
    });

    test('backspace drops the last digit, separators included', () {
      expect(pt.formatEditUpdate(at('1.234,56'), at('1.234,5')).text, '123,45');
      // Deleting the comma takes the digit before it with it.
      expect(pt.formatEditUpdate(at('1,23'), at('123')).text, '0,12');
      expect(pt.formatEditUpdate(at('0,01'), at('0,0')).text, '');
      expect(pt.formatEditUpdate(at('0,01'), at('')).text, '');
    });

    test('refuses more than the API stores', () {
      final max = MoneyFormat.number(MoneyFormat.maxMinor, Currency.brl, ptBR);
      expect(pt.formatEditUpdate(at(max), at('${max}1')).text, max);
      final huge = '9' * 30;
      expect(pt.formatEditUpdate(at('0,12'), at(huge)).text, '0,12');
    });

    test('puts the caret at the end', () {
      final value = pt.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 0),
        ),
      );
      expect(value.selection, const TextSelection.collapsed(offset: 4));
    });
  });

  group('MoneyField', () {
    Future<MoneyController> pumpField(
      WidgetTester tester, {
      int? minor,
      AppLocale locale = AppLocale.ptBr,
      Currency currency = Currency.brl,
    }) async {
      final controller = MoneyController(minor: minor);
      addTearDown(controller.dispose);
      await tester.pumpFrame(
        SizedBox(
          width: 320,
          child: ShadForm(
            child: MoneyField(
              id: 'amount',
              controller: controller,
              currency: currency,
              label: 'Valor',
            ),
          ),
        ),
        locale: locale,
      );
      return controller;
    }

    testWidgets('writes the initial amount once it knows the locale', (
      tester,
    ) async {
      final controller = await pumpField(tester, minor: 523410);
      expect(controller.text, '5.234,10');
      expect(controller.minor, 523410);
      expect(find.text(r'R$'), findsOneWidget);
    });

    testWidgets('reads what is typed as minor units', (tester) async {
      final controller = await pumpField(tester, currency: Currency.usd);
      expect(find.text(r'US$'), findsOneWidget);
      expect(controller.minor, isNull);
      await tester.enterText(find.byType(EditableText), '15990');
      await tester.pump();
      expect(controller.text, '159,90');
      expect(controller.minor, 15990);

      controller.minor = 7;
      expect(controller.text, '0,07');
      controller.minor = null;
      expect(controller.text, isEmpty);
      expect(controller.minor, isNull);
    });

    testWidgets('writes again when the language changes', (tester) async {
      final controller = await pumpField(
        tester,
        minor: 123456,
        locale: AppLocale.enUs,
      );
      expect(controller.text, '1,234.56');
      await tester.pumpFrame(
        SizedBox(
          width: 320,
          child: ShadForm(
            child: MoneyField(
              id: 'amount',
              controller: controller,
              currency: Currency.brl,
              label: 'Valor',
            ),
          ),
        ),
      );
      expect(controller.text, '1.234,56');
      expect(controller.minor, 123456);
    });

    testWidgets('opens the digit keypad', (tester) async {
      await pumpField(tester);
      final field = tester.widget<EditableText>(find.byType(EditableText));
      expect(field.keyboardType, TextInputType.number);
    });
  });
}
