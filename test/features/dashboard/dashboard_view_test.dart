import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/categories/data/models/category.dart';
import 'package:monthra/features/dashboard/data/models/summary.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';

import '../../helpers/finance_fixtures.dart';

DashboardView build({
  Currency? preferred = Currency.brl,
  List<Map<String, Object?>>? accounts,
  List<Map<String, Object?>>? categories,
  Map<String, Object?>? summary,
}) => DashboardView.build(
  summary: DashboardSummary.fromJson(summary ?? demoSummary(testMonth)),
  accounts: [for (final a in accounts ?? demoAccounts()) Account.fromJson(a)],
  categories: [
    for (final c in categories ?? demoCategories()) Category.fromJson(c),
  ],
  preferred: preferred,
);

void main() {
  test('the preferred currency comes first, the others in API order', () {
    expect(build().currencies.map((c) => c.currency), [
      Currency.brl,
      Currency.usd,
    ]);
    expect(build(preferred: Currency.usd).currencies.map((c) => c.currency), [
      Currency.usd,
      Currency.brl,
    ]);
  });

  test('without the preferred currency the first one leads', () {
    expect(
      build(preferred: Currency.eur).currencies.first.currency,
      Currency.brl,
    );
    expect(build(preferred: null).currencies.first.currency, Currency.brl);
  });

  test('no account means no currency', () {
    final view = build(summary: emptySummary(testMonth));
    expect(view.hasAccounts, isFalse);
    expect(view.currencies, isEmpty);
    expect(view.month, testMonth);
  });

  test('categories past six fold into Others', () {
    final expenses = build().currencies.first.expenses;
    expect(expenses, hasLength(CategorySlice.maxSlices));
    expect(expenses.take(5).map((s) => s.category?.defaultKey), [
      'housing',
      'groceries',
      'dining',
      'transport',
      'health',
    ]);
    final others = expenses.last;
    expect(others.kind, CategorySliceKind.others);
    expect(others.category, isNull);
    // Leisure (7%) and subscriptions (5%) of R$ 4.123,45, 3 + 4 entries.
    expect(others.amount, 412345 - (164938 + 74222 + 49481 + 41235 + 32988));
    expect(others.count, 7);
    expect(expenses.fold(0, (sum, s) => sum + s.amount), 412345);
  });

  test('six categories or fewer stay as they are', () {
    final income = build().currencies.first.income;
    expect(income.map((s) => s.kind), [
      CategorySliceKind.category,
      CategorySliceKind.category,
    ]);
  });

  test('a category missing from the list is unknown', () {
    final view = build(categories: demoCategories().skip(1).toList());
    final first = view.currencies.first.expenses.first;
    expect(first.kind, CategorySliceKind.unknown);
    expect(first.category, isNull);
    expect(first.amount, 164938);
  });

  test('each currency lists its accounts; archived ones only with money', () {
    final view = build();
    expect(view.currencies.first.accounts.map((a) => a.account?.id), [
      'acc-checking',
      'acc-savings',
      'acc-card',
    ]);
    expect(view.currencies.last.accounts.single.balance.balance, 118000);

    final withMoney = build(
      summary: {
        ...demoSummary(testMonth),
        'accounts': [
          {'accountId': 'acc-old', 'currency': 'BRL', 'balance': 500},
          {'accountId': 'acc-new', 'currency': 'BRL', 'balance': 100},
        ],
      },
    );
    final lines = withMoney.currencies.first.accounts;
    expect(lines.first.account?.archived, isTrue);
    expect(lines.last.account, isNull);
  });
}
