import 'package:flutter/foundation.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';

/// The accounts of one currency: what they hold together on `asOf` (a
/// card's debt counts below zero) and each one, in the API's order.
@immutable
final class CurrencyAccounts {
  const new({
    required this.currency,
    required this.total,
    required this.accounts,
  });

  final Currency currency;
  final int total;
  final List<Account> accounts;
}

/// The accounts page's content: the open accounts by currency (the
/// preferred one first, then alphabetical; never converted or added across
/// currencies) and the archived ones apart, oldest first as the API lists
/// them.
@immutable
final class AccountsView {
  const new({required this.groups, required this.archived});

  factory build(List<Account> accounts, {Currency? preferred}) {
    final open = <Currency, List<Account>>{};
    final archived = <Account>[];
    for (final account in accounts) {
      if (account.archived) {
        archived.add(account);
      } else {
        (open[account.currency] ??= []).add(account);
      }
    }
    final currencies = open.keys.toList()
      ..sort((a, b) {
        if (a == preferred) return -1;
        if (b == preferred) return 1;
        return a.code.compareTo(b.code);
      });
    return AccountsView(
      groups: [
        for (final currency in currencies)
          CurrencyAccounts(
            currency: currency,
            total: open[currency]!.fold(0, (sum, a) => sum + a.balance),
            accounts: List.unmodifiable(open[currency]!),
          ),
      ],
      archived: List.unmodifiable(archived),
    );
  }

  final List<CurrencyAccounts> groups;
  final List<Account> archived;

  /// No account at all, archived ones included.
  bool get isEmpty => groups.isEmpty && archived.isEmpty;
}
