import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/domain/accounts_view.dart';

import '../../helpers/finance_fixtures.dart';

List<Account> demo() => [for (final a in demoAccounts()) Account.fromJson(a)];

void main() {
  test('groups the open accounts by currency, the preferred one first', () {
    final view = AccountsView.build(demo(), preferred: Currency.usd);
    expect(view.groups.map((g) => g.currency), [Currency.usd, Currency.brl]);
    expect(view.groups.last.accounts.map((a) => a.id), [
      'acc-checking',
      'acc-savings',
      'acc-card',
    ]);
    // A card's debt counts below zero.
    expect(view.groups.last.total, demoNetWorth);
    expect(view.groups.first.total, 118000);
    expect(view.archived.map((a) => a.id), ['acc-old']);
    expect(view.isEmpty, isFalse);
  });

  test('without a preference the currencies go alphabetically', () {
    final view = AccountsView.build(demo());
    expect(view.groups.map((g) => g.currency), [Currency.brl, Currency.usd]);
  });

  test('a preferred currency without accounts changes nothing', () {
    final view = AccountsView.build(demo(), preferred: Currency.eur);
    expect(view.groups.map((g) => g.currency), [Currency.brl, Currency.usd]);
  });

  test('only archived accounts leave no group, but the view is not empty', () {
    final view = AccountsView.build([
      Account.fromJson(accountJson(id: 'a', name: 'A', archived: true)),
    ]);
    expect(view.groups, isEmpty);
    expect(view.isEmpty, isFalse);
    expect(AccountsView.build(const []).isEmpty, isTrue);
  });

  test('a card owes what is to come and has its limit left', () {
    final card = demo().firstWhere((a) => a.isCard);
    expect(card.cardDebt, -demoCardProjected);
    expect(card.availableLimit, demoCardLimit + demoCardProjected);

    final inCredit = card.copyWith(projectedBalance: 5000);
    expect(inCredit.cardDebt, 0);
    expect(inCredit.availableLimit, demoCardLimit);

    final noLimit = card.copyWith(card: card.card!.copyWith(limit: null));
    expect(noLimit.availableLimit, isNull);
  });
}
