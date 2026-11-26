import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/accounts/data/accounts_api.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';

void main() {
  test('list reads every account, archived ones when asked', () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);

    final open = await api.list();
    final all = await api.list(includeArchived: true, today: testNow);

    expect(server.adapter.sent.map((r) => r.query), [
      isEmpty,
      {'includeArchived': 'true', 'asOf': '2026-11-23'},
    ]);
    expect(open.map((a) => a.id), isNot(contains('acc-old')));
    expect(all, hasLength(5));
    final card = all[2];
    expect(card.type, AccountType.creditCard);
    expect(card.currency, Currency.brl);
    expect(card.balance, -85089);
    expect(card.projectedBalance, demoCardProjected);
    expect(
      card.card,
      const CardSettings(closingDay: 3, dueDay: 10, limit: demoCardLimit),
    );
    expect(all.first.card, isNull);
    expect(card.source, AccountSource.manual);
    expect(all.last.archived, isTrue);
    expect(all[3].currency, Currency.usd);
  });

  test('a type or source this build does not know still reads', () async {
    final server = ProfileServer(
      accounts: [
        {
          ...accountJson(id: 'a1', name: 'New'),
          'type': 'pension',
          'source': 'import',
        },
      ],
    );
    final account = (await AccountsApi(
      fakeApi(server.adapter).api,
    ).list()).single;
    expect(account.type, AccountType.unknown);
    expect(account.source, AccountSource.unknown);
    expect(account.toString(), isNot(contains('New')));
  });

  test('an unreadable list is an unexpected answer', () async {
    final server = ProfileServer(
      accounts: [
        {...accountJson(id: 'a1', name: 'X'), 'currency': 'GBP'},
      ],
    );
    final api = AccountsApi(fakeApi(server.adapter).api);
    await expectLater(api.list(), throwsA(isA<UnexpectedApiException>()));
  });

  test("create posts the draft with the reader's day", () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);
    final account = await api.create(
      const AccountDraft(
        name: ' Cofre ',
        type: AccountType.cash,
        currency: Currency.eur,
        initialBalance: 1200,
      ),
      today: testNow,
    );
    final sent = server.adapter.sent.single;
    expect(sent.method, 'POST');
    expect(sent.path, '/api/v1/accounts');
    expect(sent.query, {'asOf': '2026-11-23'});
    expect(sent.data, {
      'name': ' Cofre ',
      'type': 'cash',
      'currency': 'EUR',
      'initialBalance': 1200,
    });
    expect(account.name, 'Cofre');
    expect(account.balance, 1200);
    expect(server.accounts.last['id'], account.id);
  });

  test('create past the cap is limit_reached', () async {
    final server = ProfileServer()..maxAccounts = 5;
    final api = AccountsApi(fakeApi(server.adapter).api);
    await expectLater(
      api.create(
        const AccountDraft(
          name: 'X',
          type: AccountType.cash,
          currency: Currency.brl,
        ),
      ),
      throwsA(
        isA<ApiProblemException>().having(
          (e) => e.code,
          'code',
          ProblemCode.limitReached,
        ),
      ),
    );
  });

  test('update patches the changes of one account', () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);
    final account = await api.update(
      'acc-checking',
      const AccountChanges(name: 'Azul', initialBalance: 1000),
      today: testNow,
    );
    final sent = server.adapter.sent.single;
    expect(sent.method, 'PATCH');
    expect(sent.path, '/api/v1/accounts/acc-checking');
    expect(sent.data, {'name': 'Azul', 'initialBalance': 1000});
    expect(sent.query, {'asOf': '2026-11-23'});
    expect(account.name, 'Azul');
    expect(account.balance, 523410 + 1000);
  });

  test('ids go in the path encoded', () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);
    await expectLater(api.delete('a/b'), throwsA(isA<ApiProblemException>()));
    expect(server.adapter.sent.single.path, '/api/v1/accounts/a%2Fb');
  });

  test('delete refuses an account in use', () async {
    final server = ProfileServer()..accountsInUse = {'acc-checking'};
    final api = AccountsApi(fakeApi(server.adapter).api);
    await expectLater(
      api.delete('acc-checking'),
      throwsA(
        isA<ApiProblemException>().having(
          (e) => e.code,
          'code',
          ProblemCode.accountInUse,
        ),
      ),
    );
    await api.delete('acc-old');
    expect(server.accounts.map((a) => a['id']), isNot(contains('acc-old')));
  });

  test('invoices reads a range of a card', () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);
    final invoices = await api.invoices(
      'acc-card',
      from: const YearMonth(2026, 10),
      to: const YearMonth(2027, 1),
      today: testNow,
    );
    final sent = server.adapter.sent.single;
    expect(sent.path, '/api/v1/accounts/acc-card/invoices');
    expect(sent.query, {
      'from': '2026-10',
      'to': '2027-01',
      'asOf': '2026-11-23',
    });
    expect(invoices.map((i) => i.month.toString()), [
      '2026-10',
      '2026-11',
      '2026-12',
      '2027-01',
    ]);
    expect(invoices.map((i) => i.status), [
      InvoiceStatus.paid,
      InvoiceStatus.paid,
      InvoiceStatus.open,
      InvoiceStatus.upcoming,
    ]);
    expect(invoices[2].remaining, 85089);
    expect(invoices[3].previousBalance, 85089);
    expect(invoices[3].total, 85089 + 12000);
  });
}
