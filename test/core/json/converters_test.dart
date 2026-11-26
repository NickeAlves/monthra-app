import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/json/converters.dart';
import 'package:monthra/core/money/currency.dart';

void main() {
  test('currencies travel as ISO codes', () {
    const converter = CurrencyConverter();
    expect(converter.fromJson('USD'), Currency.usd);
    expect(converter.toJson(Currency.eur), 'EUR');
    expect(() => converter.fromJson('GBP'), throwsFormatException);
  });

  test('months travel as YYYY-MM', () {
    const converter = YearMonthConverter();
    expect(converter.fromJson('2026-11'), const YearMonth(2026, 11));
    expect(converter.toJson(const YearMonth(2026, 1)), '2026-01');
    expect(() => converter.fromJson('2026-1'), throwsFormatException);
  });

  test('dates travel as YYYY-MM-DD', () {
    const converter = CivilDateConverter();
    expect(converter.fromJson('2026-11-23'), DateTime(2026, 11, 23));
    expect(converter.toJson(DateTime(2026, 11, 23, 10)), '2026-11-23');
  });
}
