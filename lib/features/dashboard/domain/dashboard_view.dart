import 'package:flutter/foundation.dart' show immutable;
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/categories/data/models/category.dart';
import 'package:monthra/features/dashboard/data/models/summary.dart';

/// The dashboard of one month, ready to draw: the summary joined with the
/// names, icons and colors of its accounts and categories.
@immutable
final class DashboardView {
  const new({
    required this.month,
    required this.asOf,
    required this.currencies,
  });

  /// Joins [summary] with [accounts] and [categories]. The [preferred]
  /// currency (the profile's) comes first when the summary has it, the
  /// others follow in the API's order (alphabetical). Amounts are never
  /// converted or added across currencies.
  factory build({
    required DashboardSummary summary,
    required List<Account> accounts,
    required List<Category> categories,
    required Currency? preferred,
  }) {
    final accountsById = {for (final a in accounts) a.id: a};
    final categoriesById = {for (final c in categories) c.id: c};
    final views = [
      for (final s in summary.currencies)
        CurrencyView(
          summary: s,
          expenses: CategorySlice.fold(s.expensesByCategory, categoriesById),
          income: CategorySlice.fold(s.incomeByCategory, categoriesById),
          accounts: [
            for (final b in summary.accounts)
              if (b.currency == s.currency)
                ?AccountLine.of(b, accountsById[b.accountId]),
          ],
        ),
    ];
    final primary = views.indexWhere((v) => v.currency == preferred);
    if (primary > 0) views.insert(0, views.removeAt(primary));
    return DashboardView(
      month: summary.month,
      asOf: summary.asOf,
      currencies: List.unmodifiable(views),
    );
  }

  final YearMonth month;

  /// The day the balances count up to.
  final DateTime asOf;

  /// The primary currency first (the full dashboard), then the others
  /// (compact). Empty when the person has no account yet.
  final List<CurrencyView> currencies;

  bool get hasAccounts => currencies.isNotEmpty;
}

/// The month in one currency.
@immutable
final class CurrencyView {
  const new({
    required this.summary,
    required this.expenses,
    required this.income,
    required this.accounts,
  });

  final CurrencySummary summary;

  /// The largest first, the smallest past [CategorySlice.maxSlices] folded
  /// into one [CategorySliceKind.others] slice.
  final List<CategorySlice> expenses;
  final List<CategorySlice> income;

  /// The accounts in this currency: every open one, and an archived one only
  /// while it holds money (it still counts in the balance).
  final List<AccountLine> accounts;

  Currency get currency => summary.currency;
}

/// What a [CategorySlice] stands for.
enum CategorySliceKind {
  /// One of the person's categories.
  category,

  /// A category the list did not hold (created or deleted in between).
  unknown,

  /// The smallest categories together.
  others,
}

/// A category's part of the month's expenses or income.
@immutable
final class CategorySlice {
  const new({
    required this.kind,
    required this.amount,
    required this.count,
    this.category,
  });

  /// At most this many slices: past it, the smallest fold into "Others"
  /// with the last kept one's place.
  static const maxSlices = 6;

  /// [totals] (largest first) with their categories, folded to
  /// [maxSlices].
  static List<CategorySlice> fold(
    List<CategoryTotal> totals,
    Map<String, Category> categories,
  ) {
    CategorySlice slice(CategoryTotal t) {
      final category = categories[t.categoryId];
      return CategorySlice(
        kind: category == null
            ? CategorySliceKind.unknown
            : CategorySliceKind.category,
        category: category,
        amount: t.amount,
        count: t.count,
      );
    }

    final positive = [
      for (final t in totals)
        if (t.amount > 0) t,
    ];
    if (positive.length <= maxSlices) {
      return List.unmodifiable(positive.map(slice));
    }
    final kept = positive.take(maxSlices - 1);
    final rest = positive.skip(maxSlices - 1);
    return List.unmodifiable([
      ...kept.map(slice),
      CategorySlice(
        kind: CategorySliceKind.others,
        amount: rest.fold(0, (sum, t) => sum + t.amount),
        count: rest.fold(0, (sum, t) => sum + t.count),
      ),
    ]);
  }

  final CategorySliceKind kind;

  /// Null for [CategorySliceKind.unknown] and [CategorySliceKind.others].
  final Category? category;
  final int amount;

  /// How many transactions.
  final int count;
}

/// An account and its balance on `asOf`.
@immutable
final class AccountLine {
  const new({required this.balance, this.account});

  /// The line for [balance], or null for an archived account that holds no
  /// money. [account] is null when the list did not hold it.
  static AccountLine? of(AccountBalance balance, Account? account) {
    if (account != null && account.archived && balance.balance == 0) {
      return null;
    }
    return AccountLine(balance: balance, account: account);
  }

  final AccountBalance balance;
  final Account? account;
}
