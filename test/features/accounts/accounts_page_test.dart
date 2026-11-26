import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/presentation/accounts_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/profile_server.dart';
import 'accounts_test_helpers.dart';

Finder typeSelect() => find.byType(ShadSelect<AccountType>);
Finder daySelect(int i) => find.byType(ShadSelect<int>).at(i);

void main() {
  group('the list', () {
    testWidgets('groups the open accounts by currency with their totals', (
      tester,
    ) async {
      final server = await pumpAccounts(tester);
      expect(find.byType(AccountsPage), findsOneWidget);
      expect(find.text(pt.accountsTitle), findsWidgets);
      expect(
        server.adapter.sent
            .firstWhere((r) => r.path == '/api/v1/accounts')
            .query,
        {'includeArchived': 'true', 'asOf': '2026-11-23'},
      );

      // Reais first (the profile's currency), then dollars.
      final reais = tester.getTopLeft(find.text('Real brasileiro (BRL)'));
      final dollars = tester.getTopLeft(find.text('Dólar americano (USD)'));
      expect(reais.dy, lessThan(dollars.dy));
      expect(find.text(pt.accountsGroupTotal('BRL')), findsOneWidget);
      expect(findAmount(brl(demoNetWorth)), findsOneWidget);
      expect(findAmount(brl(118000, Currency.usd)), findsNWidgets(2));

      // The card shows its due day and the limit left.
      expect(find.text('Cartão Roxo'), findsOneWidget);
      expect(
        findAmount(
          '${pt.accountTypeCreditCard} · ${pt.accountsCardDue(10)} · '
          '${pt.accountsCardAvailable(brl(demoCardLimit + demoCardProjected))}',
        ),
        findsOneWidget,
      );

      // The archived account waits for a tap.
      expect(find.text('Carteira antiga'), findsNothing);
      await tester.tapLabel(pt.accountsShowArchived(1));
      expect(find.text('Carteira antiga'), findsOneWidget);
      expect(find.text(pt.accountsArchived), findsOneWidget);
      await tester.tapLabel(pt.accountsHideArchived);
      expect(find.text('Carteira antiga'), findsNothing);
    });

    testWidgets('a row opens the account', (tester) async {
      await pumpAccounts(tester);
      await tester.tap(find.text('Banco Azul'));
      await tester.settle();
      expect(tester.appLocation.path, '/accounts/acc-checking');
    });

    testWidgets('a row opens with the keyboard too', (tester) async {
      await pumpAccounts(tester);
      Focus.of(tester.element(find.text('Banco Azul'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.settle();
      expect(tester.appLocation.path, '/accounts/acc-checking');
    });

    testWidgets('without accounts it offers to create one', (tester) async {
      await pumpAccounts(tester, server: ProfileServer(accounts: []));
      expect(find.text(pt.accountsEmptyTitle), findsOneWidget);
      expect(find.text(pt.accountsNew), findsNothing);
      await tester.tapLabel(pt.accountsCreateFirst);
      expect(find.text(pt.accountFormNewDescription), findsOneWidget);
    });

    testWidgets('a failed read offers to try again', (tester) async {
      final server = ProfileServer()
        ..fail('/api/v1/accounts', Reply.problem(500, 'internal_error'));
      await pumpAccounts(tester, server: server);
      expect(find.text(pt.accountsLoadError), findsOneWidget);
      await tester.tapLabel(pt.appRetry);
      expect(find.text('Banco Azul'), findsOneWidget);
    });
  });

  group('the form', () {
    Future<ProfileServer> openNew(
      WidgetTester tester, {
      ProfileServer? server,
    }) async {
      final api = await pumpAccounts(tester, server: server);
      await tester.tapLabel(pt.accountsNew);
      expect(find.text(pt.accountFormNewDescription), findsOneWidget);
      return api;
    }

    Map<String, Object?> created(ProfileServer server) =>
        server.adapter.sent
                .lastWhere(
                  (r) => r.method == 'POST' && r.path == '/api/v1/accounts',
                )
                .data!
            as Map<String, Object?>;

    testWidgets('creates an account in the profile currency and opens it', (
      tester,
    ) async {
      final server = await openNew(tester);
      final reads = calls(server, 'GET', '/api/v1/accounts');
      await tester.type(pt.accountFormName, '  Conta conjunta ');
      await tester.type(pt.accountFormInitialBalance, '150000');
      expect(find.text('1.500,00'), findsOneWidget);
      await tester.tap(find.text(pt.accountFormNegative));
      await tester.pump();
      await tester.tapLabel(pt.accountFormCreate);

      expect(created(server), {
        'name': 'Conta conjunta',
        'type': 'checking',
        'currency': 'BRL',
        'initialBalance': -150000,
      });
      expect(tester.appLocation.path, '/accounts/acc-new-1');
      expect(find.text(pt.accountFormCreated), findsOneWidget);
      // The list reads again.
      expect(calls(server, 'GET', '/api/v1/accounts'), greaterThan(reads));
    });

    testWidgets('a card asks its days and limit and owes its debt', (
      tester,
    ) async {
      final server = await openNew(tester);
      await tester.pick(typeSelect(), pt.accountTypeCreditCard);
      expect(find.text(pt.accountFormCardDebt), findsOneWidget);
      expect(find.text(pt.accountFormCardCredit), findsOneWidget);

      await tester.type(pt.accountFormName, 'Cartão Verde');
      await tester.pick(find.byType(ShadSelect<Currency>), 'Euro (EUR)');
      await tester.type(pt.accountFormCardDebt, '25000');
      await tester.pick(daySelect(0), pt.accountFormDay(3));
      await tester.pick(daySelect(1), pt.accountFormDay(10));
      // Bought on the 23rd of November: the December invoice.
      expect(
        find.text(
          pt.accountFormCyclePreview('3 de dez. de 2026', '10 de dez. de 2026'),
        ),
        findsOneWidget,
      );
      await tester.type(pt.accountFormLimit, '800000');
      await tester.tapLabel(pt.accountFormCreate);

      expect(created(server), {
        'name': 'Cartão Verde',
        'type': 'credit_card',
        'currency': 'EUR',
        'initialBalance': -25000,
        'card': {'closingDay': 3, 'dueDay': 10, 'limit': 800000},
      });
    });

    testWidgets('checks the fields before sending', (tester) async {
      final server = await openNew(tester);
      await tester.pick(typeSelect(), pt.accountTypeCreditCard);
      await tester.tapLabel(pt.accountFormCreate);
      expect(find.text(pt.errorFieldRequired), findsNWidgets(3));
      expect(server.adapter.count('POST', '/api/v1/accounts'), 0);
    });

    testWidgets("shows the server's word under its field", (tester) async {
      final server = await openNew(tester);
      server.fail(
        '/api/v1/accounts',
        Reply.problem(
          422,
          'validation_failed',
          errors: [
            {'field': 'name', 'code': 'invalid'},
          ],
        ),
      );
      await tester.type(pt.accountFormName, 'Conta');
      await tester.tapLabel(pt.accountFormCreate);
      expect(find.text(pt.errorFieldInvalid), findsOneWidget);
      expect(find.text(pt.errorCheckFields), findsNothing);

      // Editing the name clears the server's word.
      await tester.type(pt.accountFormName, 'Conta 2');
      expect(find.text(pt.errorFieldInvalid), findsNothing);
    });

    testWidgets('past the cap it says so', (tester) async {
      final server = await openNew(
        tester,
        server: ProfileServer()..maxAccounts = 5,
      );
      await tester.type(pt.accountFormName, 'Mais uma');
      await tester.tapLabel(pt.accountFormCreate);
      expect(find.text(pt.accountFormLimitReached), findsOneWidget);
      expect(server.accounts, hasLength(5));
    });

    testWidgets('asks before throwing a change away', (tester) async {
      final server = await openNew(tester);
      await tester.type(pt.accountFormName, 'Rascunho');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text(pt.formDiscardTitle), findsOneWidget);
      await tester.tap(find.text(pt.formKeepEditing));
      await tester.pumpAndSettle();
      expect(find.text('Rascunho'), findsOneWidget);

      await tester.tap(find.text(pt.appCancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(pt.formDiscard));
      await tester.pumpAndSettle();
      expect(find.text(pt.accountFormNewDescription), findsNothing);
      expect(server.adapter.count('POST', '/api/v1/accounts'), 0);
    });

    testWidgets('Esc asks after a tap on the switch too', (tester) async {
      await openNew(tester);
      await tester.type(pt.accountFormName, 'Rascunho');
      await tester.tap(find.byType(ShadSwitch));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text(pt.formDiscardTitle), findsOneWidget);
    });

    testWidgets('an untouched form closes without asking', (tester) async {
      await openNew(tester);
      await tester.tap(find.text(pt.appCancel));
      await tester.pumpAndSettle();
      expect(find.text(pt.formDiscardTitle), findsNothing);
      expect(find.text(pt.accountFormNewDescription), findsNothing);
    });

    testWidgets('is a bottom sheet over the bar on a phone', (tester) async {
      await pumpAccounts(tester, size: phone);
      await tester.tapLabel(pt.accountsNew);
      expect(find.byType(ShadSheet), findsOneWidget);
      expect(tester.getRect(find.byType(ShadSheet)).bottom, phone.height);
    });
  });

  testWidgets('the menu lists the accounts after the dashboard', (
    tester,
  ) async {
    await pumpAccounts(tester, location: '/');
    final dashboard = tester.getTopLeft(find.text(pt.navDashboard).first);
    final accounts = tester.getTopLeft(find.text(pt.navAccounts).first);
    expect(accounts.dy, greaterThan(dashboard.dy));
    await tester.tap(find.text(pt.navAccounts).first);
    await tester.settle();
    expect(tester.appLocation.path, '/accounts');
    expect(find.byType(AccountsPage), findsOneWidget);
  });
}
