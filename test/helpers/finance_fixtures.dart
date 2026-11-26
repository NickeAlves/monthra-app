import 'package:monthra/core/dates/year_month.dart';

/// The day tests run on (`clockProvider` in `pumpMonthraApp`): Monday 23
/// November 2026, 10:00 on the device.
final DateTime testNow = DateTime(2026, 11, 23, 10);

/// What the dashboard reads as it opens, on top of a flow's own calls.
const Set<String> dashboardReads = {
  'GET /api/v1/dashboard/summary',
  'GET /api/v1/accounts',
  'GET /api/v1/categories',
};

/// [paths] without the dashboard's reads ([dashboardReads]).
List<String> withoutDashboardReads(Iterable<String> paths) => [
  for (final p in paths)
    if (!dashboardReads.contains(p)) p,
];

/// The month of [testNow].
const YearMonth testMonth = YearMonth(2026, 11);

/// An account as `GET /accounts` lists it. A credit card closes on the
/// 3rd and falls due on the 10th unless [card] says otherwise.
Map<String, Object?> accountJson({
  required String id,
  required String name,
  String type = 'checking',
  String currency = 'BRL',
  int initialBalance = 0,
  int balance = 0,
  int? projectedBalance,
  Map<String, Object?>? card,
  String source = 'manual',
  bool archived = false,
}) => {
  'id': id,
  'name': name,
  'type': type,
  'currency': currency,
  'initialBalance': initialBalance,
  'balance': balance,
  'projectedBalance': projectedBalance ?? balance,
  'card': type == 'credit_card'
      ? card ?? {'closingDay': 3, 'dueDay': 10, 'limit': null}
      : null,
  'source': source,
  'archived': archived,
  'createdAt': '2026-01-05T12:00:00Z',
  'updatedAt': '2026-01-05T12:00:00Z',
};

/// A category as `GET /categories` lists it.
Map<String, Object?> categoryJson({
  required String id,
  required String name,
  String kind = 'expense',
  String icon = 'tag',
  String color = '#78716C',
  String? defaultKey,
}) => {
  'id': id,
  'name': name,
  'kind': kind,
  'icon': icon,
  'color': color,
  'defaultKey': defaultKey,
  'createdAt': '2026-01-05T12:00:00Z',
  'updatedAt': '2026-01-05T12:00:00Z',
};

/// Four open accounts (three in reais, one in dollars) and an archived one
/// that holds nothing, oldest first.
List<Map<String, Object?>> demoAccounts() => [
  accountJson(id: 'acc-checking', name: 'Banco Azul', balance: 523410),
  accountJson(
    id: 'acc-savings',
    name: 'Reserva',
    type: 'savings',
    balance: 1500000,
  ),
  accountJson(
    id: 'acc-card',
    name: 'Cartão Roxo',
    type: 'credit_card',
    balance: -85089,
    projectedBalance: demoCardProjected,
    card: {'closingDay': 3, 'dueDay': 10, 'limit': demoCardLimit},
  ),
  accountJson(
    id: 'acc-usd',
    name: 'Conta em dólar',
    currency: 'USD',
    balance: 118000,
  ),
  accountJson(id: 'acc-old', name: 'Carteira antiga', archived: true),
];

/// The demo card's limit and what it owes counting the three installments
/// of R$ 120,00 still to come (January to March 2027).
const int demoCardLimit = 500000;
const int demoCardProjected = -85089 - 3 * 12000;

/// The invoice the demo card ([demoAccounts]) has open on [testNow].
const YearMonth demoOpenInvoice = YearMonth(2026, 12);

/// An invoice as `GET /accounts/{id}/invoices` lists it, of a card that
/// closes on the 3rd and falls due on the 10th.
Map<String, Object?> invoiceJson({
  required YearMonth month,
  required String status,
  String currency = 'BRL',
  int previousBalance = 0,
  int charges = 0,
  int credits = 0,
  int paid = 0,
}) {
  final total = previousBalance + charges - credits;
  return {
    'month': month.toString(),
    'closingDate': civilDate(month.day(3)),
    'dueDate': civilDate(month.day(10)),
    'status': status,
    'currency': currency,
    'previousBalance': previousBalance,
    'charges': charges,
    'credits': credits,
    'total': total,
    'paid': paid,
    'remaining': total - paid,
  };
}

/// The demo card's invoices from [from] to [to] as read on [testNow]:
/// every one before [demoOpenInvoice] paid in full, the open one holding
/// R$ 850,89, then the installments of R$ 120,00 until March 2027 and
/// nothing after, each one carrying what the one before left.
List<Map<String, Object?>> demoInvoices(YearMonth from, YearMonth to) {
  int chargesOf(YearMonth m) {
    if (m < demoOpenInvoice) return 60000 + (m.month % 3) * 5000;
    if (m == demoOpenInvoice) return 85089;
    return m <= const YearMonth(2027, 3) ? 12000 : 0;
  }

  final invoices = <Map<String, Object?>>[];
  var carry = 0;
  for (var m = from.addMonths(-1); m <= to; m = m.addMonths(1)) {
    final charges = chargesOf(m);
    final paid = m < demoOpenInvoice ? carry + charges : 0;
    final invoice = invoiceJson(
      month: m,
      status: m < demoOpenInvoice
          ? 'paid'
          : m == demoOpenInvoice
          ? 'open'
          : 'upcoming',
      previousBalance: carry,
      charges: charges,
      paid: paid,
    );
    carry = invoice['remaining']! as int;
    if (m >= from) invoices.add(invoice);
  }
  return invoices;
}

/// Some of the default categories, named in pt-BR as the server does.
List<Map<String, Object?>> demoCategories() => [
  for (final (key, name, kind, icon, color) in const [
    ('housing', 'Moradia', 'expense', 'house', '#8B5CF6'),
    ('groceries', 'Mercado', 'expense', 'shopping-cart', '#22C55E'),
    ('dining', 'Restaurantes', 'expense', 'utensils', '#F97316'),
    ('transport', 'Transporte', 'expense', 'car', '#3B82F6'),
    ('health', 'Saúde', 'expense', 'heart-pulse', '#EF4444'),
    ('leisure', 'Lazer', 'expense', 'party-popper', '#EC4899'),
    ('subscriptions', 'Assinaturas', 'expense', 'repeat', '#14B8A6'),
    ('salary', 'Salário', 'income', 'briefcase', '#1E6B52'),
    ('side_income', 'Renda extra', 'income', 'laptop', '#10B981'),
  ])
    categoryJson(
      id: 'cat-$key',
      name: name,
      kind: kind,
      icon: icon,
      color: color,
      defaultKey: key,
    ),
];

/// The balance in reais on [testNow]: the open accounts' in [demoAccounts].
const int demoNetWorth = 523410 + 1500000 - 85089;

/// [month]'s summary for [demoAccounts] and [demoCategories], read on
/// [testNow]: [testMonth] spends R$ 4.123,45 of R$ 8.500,00 over seven
/// categories (the last two fold into "Others"), with R$ 159,90 still
/// scheduled; the dollar account pays one subscription. The months around
/// it vary a little; months after [testMonth] have no net worth.
Map<String, Object?> demoSummary(YearMonth month) {
  int incomeOf(YearMonth m) =>
      m == testMonth ? 850000 : 800000 + (m.month % 3) * 25000;
  int expenseOf(YearMonth m) =>
      m == testMonth ? 412345 : 350000 + (m.month % 4) * 30000;
  int? worthOf(YearMonth m) {
    if (m > testMonth) return null;
    final monthsBefore =
        (testMonth.year - m.year) * 12 + testMonth.month - m.month;
    return demoNetWorth - monthsBefore * 45000;
  }

  final lastDay = DateTime(month.year, month.month + 1, 0);
  final asOf = month < testMonth ? lastDay : testNow;
  final income = incomeOf(month);
  final expense = expenseOf(month);
  final history = [for (var i = 11; i >= 0; i--) month.addMonths(-i)];

  // Shares of [total] (they add up to 1); the last part takes the rounding.
  List<Map<String, Object?>> split(
    int total,
    List<(String, double, int)> parts,
  ) {
    final amounts = [
      for (final (_, share, _) in parts) (total * share).round(),
    ];
    amounts.last += total - amounts.fold(0, (sum, a) => sum + a);
    return [
      for (final (i, (id, _, count)) in parts.indexed)
        {'categoryId': id, 'amount': amounts[i], 'count': count},
    ];
  }

  return {
    'month': month.toString(),
    'asOf': civilDate(asOf),
    'currencies': [
      {
        'currency': 'BRL',
        'income': income,
        'expense': expense,
        'net': income - expense,
        'scheduled': {'income': 0, 'expense': month < testMonth ? 0 : 15990},
        'balance': worthOf(month) ?? demoNetWorth,
        'expensesByCategory': split(expense, const [
          ('cat-housing', 0.40, 1),
          ('cat-groceries', 0.18, 9),
          ('cat-dining', 0.12, 6),
          ('cat-transport', 0.10, 12),
          ('cat-health', 0.08, 2),
          ('cat-leisure', 0.07, 3),
          ('cat-subscriptions', 0.05, 4),
        ]),
        'incomeByCategory': split(income, const [
          ('cat-salary', 0.88, 1),
          ('cat-side_income', 0.12, 2),
        ]),
        'history': [
          for (final m in history)
            {
              'month': m.toString(),
              'income': incomeOf(m),
              'expense': expenseOf(m),
              'netWorth': worthOf(m),
            },
        ],
      },
      {
        'currency': 'USD',
        'income': 0,
        'expense': 2500,
        'net': -2500,
        'scheduled': {'income': 0, 'expense': 0},
        'balance': 118000,
        'expensesByCategory': [
          {'categoryId': 'cat-subscriptions', 'amount': 2500, 'count': 1},
        ],
        'incomeByCategory': <Object?>[],
        'history': [
          for (final m in history)
            {
              'month': m.toString(),
              'income': 0,
              'expense': 2500,
              'netWorth': m > testMonth ? null : 118000,
            },
        ],
      },
    ],
    'accounts': [
      for (final a in demoAccounts())
        {
          'accountId': a['id'],
          'currency': a['currency'],
          'balance': a['balance'],
        },
    ],
  };
}

/// A summary with no account: no currency at all.
Map<String, Object?> emptySummary(YearMonth month) => {
  'month': month.toString(),
  'asOf': civilDate(testNow),
  'currencies': <Object?>[],
  'accounts': <Object?>[],
};
