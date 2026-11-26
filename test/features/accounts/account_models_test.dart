import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';

import '../../helpers/finance_fixtures.dart';

void main() {
  final card = Account.fromJson(
    accountJson(
      id: 'c',
      name: 'Cartão',
      type: 'credit_card',
      initialBalance: -10000,
      balance: -10000,
      card: {'closingDay': 3, 'dueDay': 10, 'limit': 500000},
    ),
  );

  group('AccountDraft', () {
    test('sends the API names, the card only when there is one', () {
      expect(
        const AccountDraft(
          name: 'Banco',
          type: AccountType.checking,
          currency: Currency.brl,
          initialBalance: -2500,
        ).toJson(),
        {
          'name': 'Banco',
          'type': 'checking',
          'currency': 'BRL',
          'initialBalance': -2500,
        },
      );
      expect(
        const AccountDraft(
          name: 'Cartão',
          type: AccountType.creditCard,
          currency: Currency.usd,
          card: CardSettings(closingDay: 25, dueDay: 5),
        ).toJson(),
        {
          'name': 'Cartão',
          'type': 'credit_card',
          'currency': 'USD',
          'initialBalance': 0,
          'card': {'closingDay': 25, 'dueDay': 5, 'limit': null},
        },
      );
    });

    test('keeps the name out of its text', () {
      expect(
        const AccountDraft(
          name: 'Secret',
          type: AccountType.cash,
          currency: Currency.eur,
        ).toString(),
        isNot(contains('Secret')),
      );
    });
  });

  group('AccountChanges', () {
    test('send only what changed', () {
      final none = AccountChanges.between(
        before: card,
        name: 'Cartão',
        initialBalance: -10000,
        card: card.card,
      );
      expect(none.isEmpty, isTrue);
      expect(none.toJson(), isEmpty);

      final renamed = AccountChanges.between(
        before: card,
        name: 'Roxo',
        initialBalance: -10000,
        card: card.card,
      );
      expect(renamed.toJson(), {'name': 'Roxo'});
    });

    test('send the whole cycle when any of it changed', () {
      final changes = AccountChanges.between(
        before: card,
        name: 'Cartão',
        initialBalance: -20000,
        card: const CardSettings(closingDay: 3, dueDay: 10),
      );
      expect(changes.toJson(), {
        'initialBalance': -20000,
        'card': {'closingDay': 3, 'dueDay': 10, 'limit': null},
      });
    });

    test('archive alone', () {
      expect(const AccountChanges(archived: true).toJson(), {'archived': true});
    });
  });

  test('reads an invoice', () {
    final invoice = Invoice.fromJson(
      invoiceJson(
        month: const YearMonth(2026, 12),
        status: 'carried_over',
        previousBalance: 1000,
        charges: 5000,
        credits: 500,
        paid: 2000,
      ),
    );
    expect(invoice.month, const YearMonth(2026, 12));
    expect(invoice.closingDate, DateTime(2026, 12, 3));
    expect(invoice.dueDate, DateTime(2026, 12, 10));
    expect(invoice.status, InvoiceStatus.carriedOver);
    expect(invoice.total, 5500);
    expect(invoice.remaining, 3500);
    expect(
      Invoice.fromJson({
        ...invoiceJson(month: const YearMonth(2026, 12), status: 'frozen'),
      }).status,
      InvoiceStatus.unknown,
    );
  });
}
