import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';

void main() {
  group('YearMonth', () {
    test('parses and writes YYYY-MM', () {
      final month = YearMonth.parse('2026-11');
      expect(month, const YearMonth(2026, 11));
      expect(month.toString(), '2026-11');
      expect(const YearMonth(1999, 1).toString(), '1999-01');
    });

    test('refuses malformed and out-of-range months', () {
      for (final text in [
        '',
        '2026-1',
        '2026-13',
        '2026-00',
        '26-11',
        '2026-11-01',
        ' 2026-11',
        '1899-12',
        '2101-01',
      ]) {
        expect(YearMonth.tryParse(text), isNull, reason: text);
      }
      expect(YearMonth.tryParse(null), isNull);
      expect(() => YearMonth.parse('2026/11'), throwsFormatException);
      expect(YearMonth.tryParse('1900-01'), YearMonth.min);
      expect(YearMonth.tryParse('2100-12'), YearMonth.max);
    });

    test('adds months across years', () {
      const nov = YearMonth(2026, 11);
      expect(nov.addMonths(1), const YearMonth(2026, 12));
      expect(nov.addMonths(2), const YearMonth(2027, 1));
      expect(nov.addMonths(-11), const YearMonth(2025, 12));
      expect(nov.addMonths(-23), const YearMonth(2024, 12));
      expect(nov.addMonths(0), nov);
    });

    test('orders and compares', () {
      const a = YearMonth(2025, 12);
      const b = YearMonth(2026, 1);
      expect(a < b, isTrue);
      expect(b > a, isTrue);
      expect(a.compareTo(b), lessThan(0));
      expect(a == const YearMonth(2025, 12), isTrue);
      expect(a.hashCode, const YearMonth(2025, 12).hashCode);
      expect({a, YearMonth.parse('2025-12')}, hasLength(1));
    });

    test('takes the month of a day and starts on its first day', () {
      expect(
        YearMonth.of(DateTime(2026, 2, 28, 23, 59)),
        const YearMonth(2026, 2),
      );
      expect(const YearMonth(2026, 2).firstDay, DateTime(2026, 2));
    });
  });

  group('civil dates', () {
    test('write the day of the device calendar', () {
      expect(civilDate(DateTime(2026, 11, 3, 23, 59)), '2026-11-03');
      expect(civilDate(DateTime(987, 1, 9)), '0987-01-09');
    });

    test('parse to local midnight', () {
      expect(parseCivilDate('2026-11-03'), DateTime(2026, 11, 3));
    });

    test('refuse days that do not exist', () {
      for (final text in ['2026-02-30', '2026-13-01', '2026-11-3', 'x']) {
        expect(() => parseCivilDate(text), throwsFormatException, reason: text);
      }
    });
  });
}
