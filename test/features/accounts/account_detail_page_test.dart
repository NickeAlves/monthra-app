import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/features/accounts/presentation/account_detail_page.dart';
import 'package:monthra/features/accounts/presentation/accounts_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';
import 'accounts_test_helpers.dart';

Iterable<Map<String, String>> invoiceQueries(ProfileServer server) => server
    .adapter
    .sent
    .where((r) => r.path.endsWith('/invoices'))
    .map((r) => r.query);

List<Map<String, Object?>> patches(ProfileServer server) => [
  for (final r in server.adapter.sent)
    if (r.method == 'PATCH' && r.path.startsWith('/api/v1/accounts/'))
      r.data! as Map<String, Object?>,
];

void main() {
  testWidgets('an account shows its balance today', (tester) async {
    await pumpAccounts(tester, location: '/accounts/acc-checking');
    expect(find.byType(AccountDetailPage), findsOneWidget);
    expect(find.text('Banco Azul'), findsOneWidget);
    expect(find.text('${pt.accountTypeChecking} · BRL'), findsOneWidget);
    expect(find.text(pt.accountDetailBalance), findsOneWidget);
    expect(findAmount(brl(523410)), findsOneWidget);
    expect(find.textContaining(pt.accountDetailProjected('')), findsNothing);
    expect(find.text(pt.invoicesTitle), findsNothing);
  });

  testWidgets('the balance with future transactions shows when it differs', (
    tester,
  ) async {
    final server = ProfileServer(
      accounts: [
        accountJson(
          id: 'a1',
          name: 'Conta',
          balance: 1000,
          projectedBalance: 5000,
        ),
      ],
    );
    await pumpAccounts(tester, server: server, location: '/accounts/a1');
    expect(findAmount(pt.accountDetailProjected(brl(5000))), findsOneWidget);
  });

  group('a card', () {
    testWidgets('shows its limit and the open invoice with its months', (
      tester,
    ) async {
      final server = await pumpAccounts(tester, location: '/accounts/acc-card');
      expect(find.text(pt.accountCardLimit), findsOneWidget);
      expect(findAmount(brl(demoCardLimit)), findsOneWidget);
      expect(
        findAmount(pt.accountCardUsed(brl(-demoCardProjected))),
        findsOneWidget,
      );
      expect(
        findAmount(
          pt.accountsCardAvailable(brl(demoCardLimit + demoCardProjected)),
        ),
        findsOneWidget,
      );
      expect(find.text(pt.accountCardCycle(3, 10)), findsOneWidget);

      // The invoice open on the 23rd of November is December's.
      expect(invoiceQueries(server).single, {
        'from': '2026-07',
        'to': '2027-06',
        'asOf': '2026-11-23',
      });
      expect(find.text('Dezembro de 2026'), findsWidgets);
      expect(find.text(pt.invoicesOpen), findsNothing);
      expect(
        find.text(pt.invoiceDates('3 de dez. de 2026', '10 de dez. de 2026')),
        findsOneWidget,
      );
      expect(find.text(pt.invoiceRemaining), findsOneWidget);
      expect(findAmount(brl(85089)), findsWidgets);
      // Twelve months in the list, the open one among them.
      expect(find.text('Julho de 2026'), findsOneWidget);
      expect(find.text('Junho de 2027'), findsOneWidget);
      expect(find.text(pt.invoiceStatusOpen), findsNWidgets(2));
    });

    testWidgets('moves to the next invoice and back', (tester) async {
      final server = await pumpAccounts(tester, location: '/accounts/acc-card');
      await tester.tapLabel(pt.invoicesNext);
      expect(
        tester.appLocation.toString(),
        '/accounts/acc-card?invoice=2027-01',
      );
      expect(invoiceQueries(server).last, {
        'from': '2026-08',
        'to': '2027-07',
        'asOf': '2026-11-23',
      });
      expect(find.text(pt.invoiceStatusUpcoming), findsWidgets);
      // January starts with what December leaves.
      expect(find.text(pt.invoicePreviousBalance), findsOneWidget);
      expect(findAmount(brl(85089 + 12000)), findsWidgets);

      await tester.tapLabel(pt.invoicesOpen);
      expect(tester.appLocation.toString(), '/accounts/acc-card');
    });

    testWidgets('a month of the list comes into focus', (tester) async {
      await pumpAccounts(tester, location: '/accounts/acc-card');
      await tester.ensureVisible(find.text('Outubro de 2026'));
      await tester.tap(find.text('Outubro de 2026'));
      await tester.settle();
      expect(
        tester.appLocation.toString(),
        '/accounts/acc-card?invoice=2026-10',
      );
      expect(find.text('Outubro de 2026'), findsWidgets);
      expect(find.text(pt.invoiceStatusPaid), findsWidgets);
    });

    testWidgets('a link opens the invoice it names', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-card?invoice=2026-03',
      );
      expect(invoiceQueries(server).single['from'], '2025-10');
      expect(find.text('Março de 2026'), findsWidgets);
      expect(find.text(pt.invoicesOpen), findsOneWidget);
    });

    testWidgets('a credit reads as one', (tester) async {
      final server = ProfileServer(
        invoicesFor: (_, from, to) => [
          for (var m = from; m <= to; m = m.addMonths(1))
            invoiceJson(
              month: m,
              status: 'paid',
              charges: 1000,
              paid: m == demoOpenInvoice ? 3000 : 1000,
            ),
        ],
      );
      await pumpAccounts(
        tester,
        server: server,
        location: '/accounts/acc-card',
      );
      expect(find.text(pt.invoiceCredit), findsOneWidget);
      expect(find.text(pt.invoiceRemaining), findsNothing);
    });

    testWidgets('failed invoices offer to try again', (tester) async {
      final server = ProfileServer()
        ..fail(
          '/api/v1/accounts/acc-card/invoices',
          Reply.problem(500, 'internal_error'),
        );
      await pumpAccounts(
        tester,
        server: server,
        location: '/accounts/acc-card',
      );
      expect(find.text(pt.invoicesLoadError), findsOneWidget);
      await tester.tapLabel(pt.appRetry);
      expect(find.text(pt.invoiceRemaining), findsOneWidget);
    });

    testWidgets('over the limit it says by how much', (tester) async {
      final server = ProfileServer(
        accounts: [
          accountJson(
            id: 'c1',
            name: 'Cartão',
            type: 'credit_card',
            balance: -60000,
            card: {'closingDay': 3, 'dueDay': 10, 'limit': 50000},
          ),
        ],
      );
      await pumpAccounts(tester, server: server, location: '/accounts/c1');
      expect(findAmount(pt.accountCardOverLimit(brl(10000))), findsOneWidget);
    });
  });

  group('edits', () {
    testWidgets('a rename goes out alone', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-checking',
      );
      await tester.tapLabel(pt.accountDetailEdit);
      expect(find.text(pt.accountFormEditTitle), findsOneWidget);
      expect(find.text(pt.accountFormFixed), findsOneWidget);
      expect(find.text(pt.accountFormInitialBalanceEditHint), findsOneWidget);
      await tester.type(pt.accountFormName, 'Azul');
      await tester.tapLabel(pt.accountFormSave);
      expect(patches(server), [
        {'name': 'Azul'},
      ]);
      expect(find.text(pt.accountFormEditTitle), findsNothing);
      expect(find.text('Azul'), findsOneWidget);
      expect(find.text(pt.accountFormSaved), findsOneWidget);
    });

    testWidgets("a card's cycle goes whole", (tester) async {
      final server = await pumpAccounts(tester, location: '/accounts/acc-card');
      await tester.tapLabel(pt.accountDetailEdit);
      expect(find.text(pt.accountFormCardDebtEdit), findsOneWidget);
      expect(find.text('5.000,00'), findsOneWidget);
      await tester.pick(
        find.byType(ShadSelect<int>).at(1),
        pt.accountFormDay(15),
      );
      await tester.tapLabel(pt.accountFormSave);
      expect(patches(server), [
        {
          'card': {'closingDay': 3, 'dueDay': 15, 'limit': demoCardLimit},
        },
      ]);
      expect(find.text(pt.accountCardCycle(3, 15)), findsOneWidget);
    });

    testWidgets('nothing changed sends nothing', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-checking',
      );
      await tester.tapLabel(pt.accountDetailEdit);
      await tester.tapLabel(pt.accountFormSave);
      expect(patches(server), isEmpty);
      expect(find.text(pt.accountFormEditTitle), findsNothing);
    });
  });

  group('archive', () {
    testWidgets('archives and brings back', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-checking',
      );
      await tester.tapLabel(pt.accountDetailArchive);
      expect(patches(server), [
        {'archived': true},
      ]);
      expect(find.text(pt.accountDetailArchivedNotice), findsOneWidget);
      expect(find.text(pt.accountDetailArchivedToast), findsOneWidget);

      await tester.tapLabel(pt.accountDetailUnarchive);
      expect(patches(server).last, {'archived': false});
      expect(find.text(pt.accountDetailArchivedNotice), findsNothing);
    });

    testWidgets('an account a recurrence uses stays, and says why', (
      tester,
    ) async {
      final server = ProfileServer()..usedByRecurrence = {'acc-checking'};
      await pumpAccounts(
        tester,
        server: server,
        location: '/accounts/acc-checking',
      );
      await tester.tapLabel(pt.accountDetailArchive);
      expect(find.text(pt.accountUsedByRecurrence), findsOneWidget);
      expect(find.text(pt.accountDetailArchivedNotice), findsNothing);
    });
  });

  group('delete', () {
    testWidgets('asks, deletes and goes back to the list', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-savings',
      );
      await tester.tapLabel(pt.accountDetailDelete);
      expect(find.text(pt.accountDeleteTitle), findsOneWidget);
      await tester.tap(find.text(pt.accountDetailDelete).last);
      await tester.settle();
      expect(server.adapter.count('DELETE', '/api/v1/accounts/acc-savings'), 1);
      expect(tester.appLocation.path, '/accounts');
      expect(find.byType(AccountsPage), findsOneWidget);
      expect(find.text('Reserva'), findsNothing);
      expect(find.text(pt.accountDeletedToast), findsOneWidget);
    });

    testWidgets('cancelled, it sends nothing', (tester) async {
      final server = await pumpAccounts(
        tester,
        location: '/accounts/acc-savings',
      );
      await tester.tapLabel(pt.accountDetailDelete);
      await tester.tap(find.text(pt.appCancel));
      await tester.settle();
      expect(server.adapter.count('DELETE', '/api/v1/accounts/acc-savings'), 0);
      expect(tester.appLocation.path, '/accounts/acc-savings');
    });

    testWidgets('an account with transactions is offered the archive', (
      tester,
    ) async {
      final server = ProfileServer()..accountsInUse = {'acc-checking'};
      await pumpAccounts(
        tester,
        server: server,
        location: '/accounts/acc-checking',
      );
      await tester.tapLabel(pt.accountDetailDelete);
      await tester.tap(find.text(pt.accountDetailDelete).last);
      await tester.settle();
      expect(find.text(pt.accountInUseTitle), findsOneWidget);
      await tester.tap(find.text(pt.accountDetailArchive).last);
      await tester.settle();
      expect(patches(server), [
        {'archived': true},
      ]);
      expect(tester.appLocation.path, '/accounts/acc-checking');
      expect(find.text(pt.accountDetailArchivedNotice), findsOneWidget);
    });
  });

  testWidgets('an unknown account says so, with a way back', (tester) async {
    await pumpAccounts(tester, location: '/accounts/nope');
    expect(find.text(pt.accountNotFoundTitle), findsWidgets);
    await tester.tapLabel(pt.accountBackToAccounts);
    expect(tester.appLocation.path, '/accounts');
  });

  test('the address of an invoice', () {
    const open = YearMonth(2026, 12);
    expect(AccountDetailPage.location('a b', open, open), '/accounts/a%20b');
    expect(
      AccountDetailPage.location('a', const YearMonth(2027, 1), open),
      '/accounts/a?invoice=2027-01',
    );
    expect(
      AccountDetailPage.invoiceOf(Uri.parse('/accounts/a?invoice=2027-13')),
      isNull,
    );
  });
}
