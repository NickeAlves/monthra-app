import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/dashboard/data/dashboard_api.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';

void main() {
  test('summary asks for the month with the device today', () async {
    final server = ProfileServer();
    final api = DashboardApi(fakeApi(server.adapter).api);

    final summary = await api.summary(
      const YearMonth(2026, 10),
      today: DateTime(2026, 11, 23, 23, 30),
    );

    final sent = server.adapter.sent.single;
    expect('${sent.method} ${sent.path}', 'GET /api/v1/dashboard/summary');
    expect(sent.query, {'month': '2026-10', 'asOf': '2026-11-23'});
    expect(summary.month, const YearMonth(2026, 10));
    expect(summary.asOf, DateTime(2026, 10, 31));
  });

  test('summary reads every currency, the history and the balances', () async {
    final server = ProfileServer();
    final summary = await DashboardApi(fakeApi(server.adapter).api)
        .summary(testMonth, today: testNow);

    expect(summary.currencies.map((c) => c.currency), [
      Currency.brl,
      Currency.usd,
    ]);
    final brl = summary.currencies.first;
    expect(brl.income, 850000);
    expect(brl.expense, 412345);
    expect(brl.net, 850000 - 412345);
    expect(brl.scheduled.expense, 15990);
    expect(brl.balance, demoNetWorth);
    expect(brl.expensesByCategory, hasLength(7));
    expect(
      brl.expensesByCategory.fold(0, (sum, c) => sum + c.amount),
      brl.expense,
    );
    expect(brl.history, hasLength(12));
    expect(brl.history.first.month, const YearMonth(2025, 12));
    expect(brl.history.last.netWorth, demoNetWorth);
    expect(summary.accounts.first.accountId, 'acc-checking');

    final later = await DashboardApi(fakeApi(server.adapter).api)
        .summary(const YearMonth(2027, 2), today: testNow);
    expect(later.currencies.first.history.last.netWorth, isNull);
  });

  test('an unreadable summary is an unexpected answer', () async {
    final server = ProfileServer(
      summaryFor: (month) => {...demoSummary(month), 'month': 'soon'},
    );
    final api = DashboardApi(fakeApi(server.adapter).api);
    await expectLater(
      api.summary(testMonth, today: testNow),
      throwsA(isA<UnexpectedApiException>()),
    );
  });
}
