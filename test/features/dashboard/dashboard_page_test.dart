import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/dashboard/presentation/dashboard_page.dart';
import 'package:monthra/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/l10n/generated/app_localizations_pt.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/finance_fixtures.dart';
import '../../helpers/frame.dart';
import '../../helpers/profile_server.dart';

final pt = AppLocalizationsPt();
const ptBR = Locale('pt', 'BR');

String brl(int minor, [MoneySign sign = MoneySign.auto]) =>
    MoneyFormat.format(minor, Currency.brl, ptBR, sign: sign);

const desktop = Size(1280, 900);
const phone = Size(390, 844);

/// The app signed in at [location] on a [size] window, in pt-BR with motion
/// off, with [server] (the demo data by default) answering.
Future<ProfileServer> pumpDashboard(
  WidgetTester tester, {
  ProfileServer? server,
  String? location,
  Size size = desktop,
  bool settle = true,
}) async {
  final api = server ?? ProfileServer();
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.reduceMotion();
  await tester.pumpMonthraApp(
    api: api.adapter,
    tokens: MemoryTokenStore(savedTokens),
    location: location,
    // The profile's language from the first frame, as a device that signed
    // in before keeps it.
    store: MemoryPreferencesStore(const AppPreferences(locale: AppLocale.ptBr)),
  );
  if (settle) await tester.settle();
  return api;
}

Iterable<Map<String, String>> summaryQueries(ProfileServer server) => server
    .adapter
    .sent
    .where((r) => r.path == '/api/v1/dashboard/summary')
    .map((r) => r.query);

/// The icon button labeled [label] (a ShadIconButton holds a ShadButton).
Finder button(String label) => find
    .ancestor(
      of: find.bySemanticsLabel(label),
      matching: find.byType(ShadIconButton),
    )
    .first;

extension on WidgetTester {
  /// Settles, then lets the calls a last frame started finish: dio runs on
  /// timers, and with motion off no frame follows the build that starts a
  /// month's reads, so `pumpAndSettle` alone stops before they land.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpAndSettle();
      await pump(Duration.zero);
    }
  }

  Future<void> tapLabel(String label) async {
    await ensureVisible(find.bySemanticsLabel(label).first);
    await tap(find.bySemanticsLabel(label).first);
    await settle();
  }
}

void main() {
  testWidgets("opens on the device's month with its figures", (tester) async {
    final server = await pumpDashboard(tester);

    expect(find.byType(DashboardPage), findsOneWidget);
    expect(find.text(pt.dashboardGreeting('Ana')), findsOneWidget);
    expect(find.text('Novembro de 2026'), findsOneWidget);
    expect(summaryQueries(server).single, {
      'month': '2026-11',
      'asOf': '2026-11-23',
    });
    expect(
      server.adapter.sent.firstWhere((r) => r.path == '/api/v1/accounts').query,
      {'includeArchived': 'true', 'asOf': '2026-11-23'},
    );

    // The four figures in reais.
    expect(find.text(brl(demoNetWorth)), findsOneWidget);
    expect(find.text(brl(850000, MoneySign.always)), findsOneWidget);
    expect(find.text(brl(-412345, MoneySign.always)), findsOneWidget);
    expect(find.text(brl(850000 - 412345, MoneySign.always)), findsOneWidget);
    expect(find.text(pt.dashboardScheduled(brl(15990))), findsOneWidget);
    // Income in reais and both flows in dollars.
    expect(find.text(pt.dashboardNothingScheduled), findsNWidgets(3));
    expect(
      find.text(pt.dashboardBalanceOn('23 de nov. de 2026')),
      findsWidgets,
    );

    // The split by category, with the smallest two together.
    expect(find.text('Moradia'), findsOneWidget);
    expect(find.text(pt.dashboardOtherCategories), findsOneWidget);
    expect(find.text('Lazer'), findsNothing);
    expect(find.text(pt.dashboardEntries(9)), findsOneWidget);

    // The open accounts in reais; the empty archived one stays out.
    expect(find.text('Banco Azul'), findsOneWidget);
    expect(find.text('Cartão Roxo'), findsOneWidget);
    expect(find.text(brl(-85089)), findsOneWidget);
    expect(find.text('Carteira antiga'), findsNothing);
    expect(find.byType(MonthraBarChart), findsOneWidget);
    expect(find.byType(MonthraLineChart), findsOneWidget);
  });

  testWidgets('the other currencies follow, compact and without charts', (
    tester,
  ) async {
    await pumpDashboard(tester);

    expect(find.text(pt.currencyUsd), findsOneWidget);
    expect(find.text(pt.currencyBrl), findsNothing);
    expect(find.text('Conta em dólar'), findsOneWidget);
    expect(
      find.text(MoneyFormat.format(118000, Currency.usd, ptBR)),
      findsWidgets,
    );
    expect(find.byType(MonthraDonutChart), findsOneWidget);
    // Above the dollars' block: the reais come first (the preferred).
    expect(
      tester.getTopLeft(find.text(brl(demoNetWorth))).dy,
      lessThan(tester.getTopLeft(find.text(pt.currencyUsd)).dy),
    );
  });

  testWidgets('the preferred currency leads when there is one', (tester) async {
    await pumpDashboard(
      tester,
      server: ProfileServer(me: meJson(currency: 'USD')),
    );
    expect(find.text(pt.currencyBrl), findsOneWidget);
    expect(find.text(pt.currencyUsd), findsNothing);
  });

  testWidgets('a preferred currency with no account leaves the first one', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      server: ProfileServer(me: meJson(currency: 'EUR')),
    );
    expect(find.text(pt.currencyUsd), findsOneWidget);
    expect(find.text(pt.currencyEur), findsNothing);
  });

  testWidgets('the category card switches to income', (tester) async {
    await pumpDashboard(tester);
    expect(find.text('Salário'), findsNothing);

    await tester.tapLabel(pt.dashboardIncome);

    expect(find.text('Salário'), findsOneWidget);
    expect(find.text('Moradia'), findsNothing);
  });

  testWidgets('loads behind a skeleton, read once', (tester) async {
    final server = ProfileServer();
    final gate = server.holdSummary();
    await pumpDashboard(tester, server: server, settle: false);
    await tester.pumpUntilFound(find.byType(DashboardSkeleton));

    expect(find.bySemanticsLabel(pt.dashboardLoading), findsOneWidget);
    expect(find.text(brl(demoNetWorth)), findsNothing);

    gate.complete();
    await tester.settle();
    expect(find.byType(DashboardSkeleton), findsNothing);
    expect(find.text(brl(demoNetWorth)), findsOneWidget);
  });

  testWidgets('a failed load offers to try again', (tester) async {
    final server = ProfileServer()
      ..fail(
        '/api/v1/dashboard/summary',
        Reply.problem(422, 'validation_failed'),
      );
    await pumpDashboard(tester, server: server);

    expect(find.text(pt.dashboardLoadError), findsOneWidget);
    expect(find.text(pt.errorCheckFields), findsOneWidget);

    await tester.tap(find.text(pt.appRetry));
    await tester.settle();
    expect(find.text(pt.dashboardLoadError), findsNothing);
    expect(find.text(brl(demoNetWorth)), findsOneWidget);
  });

  testWidgets('no account yet: a message, no figures', (tester) async {
    await pumpDashboard(
      tester,
      server: ProfileServer(summaryFor: emptySummary, accounts: const []),
    );
    expect(find.text(pt.dashboardEmptyTitle), findsOneWidget);
    expect(find.text(pt.dashboardEmptyMessage), findsOneWidget);
    expect(find.byType(MonthraBarChart), findsNothing);
  });

  testWidgets('no account yet: creating one shows the month', (tester) async {
    final server = ProfileServer(summaryFor: emptySummary, accounts: const []);
    await pumpDashboard(tester, server: server);
    final summaries = summaryQueries(server).length;
    await tester.tapLabel(pt.accountsCreateFirst);
    expect(find.text(pt.accountFormNewDescription), findsOneWidget);

    // The server now has an account and a month to show.
    server.summaryFor = demoSummary;
    final field = find.descendant(
      of: find.ancestor(
        of: find.text(pt.accountFormName),
        matching: find.byType(ShadInputFormField),
      ),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'Banco Azul');
    // The empty state behind the form reads the same.
    await tester.tap(find.text(pt.accountFormCreate).last);
    await tester.settle();

    expect(server.accounts, hasLength(1));
    expect(find.text(pt.accountFormNewDescription), findsNothing);
    expect(find.text(pt.accountFormCreated), findsOneWidget);
    // Still on the dashboard, read again.
    expect(tester.appLocation.path, '/');
    expect(summaryQueries(server).length, greaterThan(summaries));
    expect(find.text(pt.dashboardEmptyTitle), findsNothing);
  });

  testWidgets('an account of the list opens its page', (tester) async {
    await pumpDashboard(tester);
    await tester.ensureVisible(find.text('Reserva'));
    await tester.tap(find.text('Reserva'));
    await tester.settle();
    expect(tester.appLocation.path, '/accounts/acc-savings');
  });

  testWidgets('moves month by month in the address', (tester) async {
    final server = await pumpDashboard(tester);
    expect(find.text(pt.dashboardThisMonth), findsNothing);

    await tester.tapLabel(pt.dashboardPreviousMonth);
    expect(tester.appLocation.toString(), '/?month=2026-10');
    expect(find.text('Outubro de 2026'), findsOneWidget);
    expect(summaryQueries(server).last, {
      'month': '2026-10',
      'asOf': '2026-11-23',
    });

    await tester.tapLabel(pt.dashboardNextMonth);
    await tester.tapLabel(pt.dashboardNextMonth);
    expect(tester.appLocation.toString(), '/?month=2026-12');
    // A month to come: no net worth past today, the balance of today.
    expect(find.text(brl(demoNetWorth)), findsOneWidget);

    await tester.tap(find.text(pt.dashboardThisMonth));
    await tester.settle();
    expect(tester.appLocation.toString(), '/');
    expect(find.text('Novembro de 2026'), findsOneWidget);
  });

  testWidgets('a link opens its month; a wrong one the current month', (
    tester,
  ) async {
    final server = await pumpDashboard(tester, location: '/?month=2026-03');
    expect(find.text('Março de 2026'), findsOneWidget);
    expect(summaryQueries(server).single['month'], '2026-03');
    expect(find.text(pt.dashboardThisMonth), findsOneWidget);
  });

  testWidgets('an address with a month the API refuses shows this month', (
    tester,
  ) async {
    final server = await pumpDashboard(tester, location: '/?month=2026-13');
    expect(find.text('Novembro de 2026'), findsOneWidget);
    expect(summaryQueries(server).single['month'], '2026-11');
  });

  testWidgets('the oldest month the API takes has no month before', (
    tester,
  ) async {
    await pumpDashboard(tester, location: '/?month=1900-01');
    final previous = tester.widget<ShadIconButton>(
      button(pt.dashboardPreviousMonth),
    );
    expect(previous.onPressed, isNull);
  });

  testWidgets('refresh reads the summary, accounts and categories again', (
    tester,
  ) async {
    final server = await pumpDashboard(tester);
    expect(withoutDashboardReads(server.adapter.paths), ['GET /api/v1/me']);

    await tester.tapLabel(pt.dashboardRefresh);

    expect(server.adapter.count('GET', '/api/v1/dashboard/summary'), 2);
    expect(server.adapter.count('GET', '/api/v1/accounts'), 2);
    expect(server.adapter.count('GET', '/api/v1/categories'), 2);
  });

  testWidgets('a refresh that fails keeps the figures and says so', (
    tester,
  ) async {
    final server = await pumpDashboard(tester);
    server.fail(
      '/api/v1/dashboard/summary',
      Reply.problem(422, 'validation_failed'),
    );

    await tester.tapLabel(pt.dashboardRefresh);

    expect(find.text(brl(demoNetWorth)), findsOneWidget);
    expect(find.text(pt.dashboardLoadError), findsOneWidget);
    expect(find.text(pt.appRetry), findsNothing);
  });

  testWidgets('the month shown stays, dimmed, while the next one loads', (
    tester,
  ) async {
    final server = await pumpDashboard(tester);
    final gate = server.holdSummary();

    await tester.tap(button(pt.dashboardPreviousMonth));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(Skeleton), findsNothing);
    expect(find.text(brl(demoNetWorth)), findsOneWidget);
    expect(find.bySemanticsLabel(pt.dashboardLoading), findsOneWidget);

    gate.complete();
    await tester.settle();
    expect(find.bySemanticsLabel(pt.dashboardLoading), findsNothing);
    expect(find.text('Outubro de 2026'), findsOneWidget);
  });

  testWidgets('a phone stacks the cards', (tester) async {
    await pumpDashboard(tester, size: phone);
    expect(tester.takeException(), isNull);
    final category = tester.getTopLeft(find.text(pt.dashboardByCategory));
    final cashFlow = tester.getTopLeft(find.text(pt.dashboardCashFlow));
    expect(category.dx, cashFlow.dx);
    expect(category.dy, lessThan(cashFlow.dy));
  });

  test('the address of a month', () {
    const now = YearMonth(2026, 11);
    expect(DashboardPage.location(now, now), '/');
    expect(
      DashboardPage.location(const YearMonth(2026, 3), now),
      '/?month=2026-03',
    );
    expect(
      DashboardPage.monthOf(Uri.parse('/?month=2026-03')),
      const YearMonth(2026, 3),
    );
    expect(DashboardPage.monthOf(Uri.parse('/')), isNull);
  });
}
