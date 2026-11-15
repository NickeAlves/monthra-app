import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';

const ptBR = Locale('pt', 'BR');
const esES = Locale('es', 'ES');
const enUS = Locale('en', 'US');

/// intl separates the symbol with a no-break space; tests write a space.
String show(int minor, Currency c, Locale l, [MoneySign s = MoneySign.auto]) =>
    MoneyFormat.format(minor, c, l, sign: s).replaceAll(' ', ' ');

void main() {
  group('Currency', () {
    test('parses the API codes', () {
      expect(Currency.fromCode('BRL'), Currency.brl);
      expect(Currency.fromCode('USD'), Currency.usd);
      expect(Currency.fromCode('EUR'), Currency.eur);
      expect(Currency.brl.code, 'BRL');
      expect(Currency.eur.minorPerMajor, 100);
    });

    test('refuses an unknown code', () {
      expect(() => Currency.fromCode('brl'), throwsFormatException);
      expect(() => Currency.fromCode('GBP'), throwsFormatException);
    });
  });

  group('MoneyFormat.format', () {
    test('follows the locale, whatever the currency', () {
      expect(show(123456, Currency.brl, ptBR), r'R$ 1.234,56');
      expect(show(123456, Currency.usd, ptBR), r'US$ 1.234,56');
      expect(show(123456, Currency.eur, ptBR), '€ 1.234,56');
      expect(show(123456, Currency.brl, esES), r'1.234,56 R$');
      expect(show(123456, Currency.usd, esES), r'1.234,56 US$');
      expect(show(123456, Currency.eur, esES), '1.234,56 €');
      expect(show(123456, Currency.brl, enUS), r'R$1,234.56');
      expect(show(123456, Currency.usd, enUS), r'$1,234.56');
      expect(show(123456, Currency.eur, enUS), '€1,234.56');
    });

    test('writes cents and zero', () {
      expect(show(5, Currency.brl, ptBR), r'R$ 0,05');
      expect(show(0, Currency.brl, ptBR), r'R$ 0,00');
    });

    test('signs with the typographic minus', () {
      expect(
        show(-123456, Currency.brl, ptBR),
        '\u2212'
        r'R$ 1.234,56',
      );
      expect(show(-123456, Currency.eur, esES), '\u22121.234,56 €');
      expect(MoneyFormat.minus, '\u2212');
    });

    test('applies the sign modes', () {
      expect(show(100, Currency.brl, enUS), r'R$1.00');
      expect(show(100, Currency.brl, enUS, MoneySign.always), r'+R$1.00');
      expect(
        show(-100, Currency.brl, enUS, MoneySign.always),
        '\u2212'
        r'R$1.00',
      );
      expect(show(0, Currency.brl, enUS, MoneySign.always), r'R$0.00');
      expect(show(-100, Currency.brl, enUS, MoneySign.never), r'R$1.00');
    });

    test('stays exact up to the largest amount the API stores', () {
      const max = MoneyFormat.maxMinor;
      expect(show(max, Currency.brl, ptBR), r'R$ 100.000.000.000,00');
      expect(show(max - 1, Currency.brl, ptBR), r'R$ 99.999.999.999,99');
      expect(
        show(-max + 1, Currency.usd, enUS),
        '\u2212'
        r'$99,999,999,999.99',
      );
      expect(show(max - 99, Currency.eur, enUS), '€99,999,999,999.01');
    });

    test('falls back to pt-BR for a locale intl lacks', () {
      expect(show(123456, Currency.brl, const Locale('xx')), r'R$ 1.234,56');
    });
  });
}
