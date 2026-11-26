import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/domain/card_cycle.dart';

/// The cases of the server's `TestCardInvoiceCycle`
/// (monthra-server `internal/domain/card_test.go`).
void main() {
  final cases =
      <
        String,
        ({
          CardSettings card,
          String invoice,
          String closing,
          String due,
          Map<String, String> purchases,
          Map<String, String> payments,
        })
      >{
        'due the month after closing': (
          card: const CardSettings(closingDay: 25, dueDay: 5),
          invoice: '2026-12',
          closing: '2026-11-25',
          due: '2026-12-05',
          purchases: {
            '2026-10-25': '2026-12',
            '2026-11-01': '2026-12',
            '2026-11-24': '2026-12',
            '2026-11-25': '2027-01',
            '2026-12-31': '2027-02',
          },
          payments: {
            '2026-11-24': '2026-11',
            '2026-11-25': '2026-12',
            '2026-12-05': '2026-12',
            '2026-12-24': '2026-12',
          },
        ),
        'due the month it closes': (
          card: const CardSettings(closingDay: 3, dueDay: 10),
          invoice: '2026-11',
          closing: '2026-11-03',
          due: '2026-11-10',
          purchases: {
            '2026-11-02': '2026-11',
            '2026-11-03': '2026-12',
            '2026-12-31': '2027-01',
          },
          payments: {'2026-11-10': '2026-11', '2026-11-02': '2026-10'},
        ),
        'closing on the 31st of February': (
          card: const CardSettings(closingDay: 31, dueDay: 10),
          invoice: '2027-03',
          closing: '2027-02-28',
          due: '2027-03-10',
          purchases: {
            '2027-02-27': '2027-03',
            '2027-02-28': '2027-04',
            '2028-02-28': '2028-03',
            '2028-02-29': '2028-04',
          },
          payments: {},
        ),
        'closing and due on the same day': (
          card: const CardSettings(closingDay: 10, dueDay: 10),
          invoice: '2026-12',
          closing: '2026-11-10',
          due: '2026-12-10',
          purchases: {'2026-11-09': '2026-12', '2026-11-10': '2027-01'},
          payments: {},
        ),
        'due on the 31st of a short month': (
          card: const CardSettings(closingDay: 20, dueDay: 31),
          invoice: '2026-11',
          closing: '2026-11-20',
          due: '2026-11-30',
          purchases: {},
          payments: {},
        ),
      };

  for (final MapEntry(key: name, value: c) in cases.entries) {
    test(name, () {
      final month = YearMonth.parse(c.invoice);
      expect(civilDate(c.card.closingDate(month)), c.closing);
      expect(civilDate(c.card.dueDate(month)), c.due);
      for (final MapEntry(key: day, value: want) in c.purchases.entries) {
        expect(
          c.card.invoiceFor(parseCivilDate(day)).toString(),
          want,
          reason: 'purchase on $day',
        );
      }
      for (final MapEntry(key: day, value: want) in c.payments.entries) {
        expect(
          c.card.paymentInvoice(parseCivilDate(day)).toString(),
          want,
          reason: 'payment on $day',
        );
      }
    });
  }

  test('a time of day does not move the invoice', () {
    const card = CardSettings(closingDay: 3, dueDay: 10);
    expect(
      card.invoiceFor(DateTime(2026, 11, 2, 23, 59)),
      const YearMonth(2026, 11),
    );
  });
}
