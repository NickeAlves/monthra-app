import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/accounts/data/accounts_api.dart';
import 'package:monthra/features/accounts/data/models/account.dart';

import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';

void main() {
  test('list reads every account, archived ones when asked', () async {
    final server = ProfileServer();
    final api = AccountsApi(fakeApi(server.adapter).api);

    final open = await api.list();
    final all = await api.list(includeArchived: true);

    expect(server.adapter.sent.map((r) => r.query), [
      isEmpty,
      {'includeArchived': 'true'},
    ]);
    expect(open.map((a) => a.id), isNot(contains('acc-old')));
    expect(all, hasLength(5));
    final card = all[2];
    expect(card.type, AccountType.creditCard);
    expect(card.currency, Currency.brl);
    expect(card.balance, -85089);
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
}
