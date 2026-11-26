import 'dart:async';

import 'package:monthra/core/dates/year_month.dart';

import 'auth_fixtures.dart';
import 'fake_api.dart';
import 'finance_fixtures.dart';

/// The password [ProfileServer] accepts until it changes.
const String testPassword = 'correct horse battery';

/// The only code from the authenticator app [ProfileServer] accepts.
const String testTotp = '123456';

/// The secret of [ProfileServer]'s MFA setup.
const String testMfaSecret = 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';

/// The URI of [ProfileServer]'s MFA setup.
const String testOtpauthUri =
    'otpauth://totp/Monthra:ana%40example.com?algorithm=SHA1&digits=6'
    '&issuer=Monthra&period=30&secret=$testMfaSecret';

/// The archive [ProfileServer] exports: an empty ZIP (its end record).
final List<int> testExportZip = [0x50, 0x4B, 0x05, 0x06, ...List.filled(18, 0)];

/// A session as `GET /me/sessions` lists it.
Map<String, Object?> sessionInfoJson({
  required String id,
  bool current = false,
  String userAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36',
  String ip = '203.0.113.7',
  String lastUsedAt = '2026-11-22T14:30:00Z',
}) => {
  'id': id,
  'createdAt': '2026-11-20T09:00:00Z',
  'lastUsedAt': lastUsedAt,
  'expiresAt': '2026-12-20T09:00:00Z',
  'userAgent': userAgent,
  'ip': ip,
  'current': current,
};

/// This device and an iPhone, as [ProfileServer] starts.
List<Map<String, Object?>> defaultSessions() => [
  sessionInfoJson(id: 's-current', current: true),
  sessionInfoJson(
    id: 's-phone',
    userAgent: 'Monthra (iOS)',
    ip: '198.51.100.20',
    lastUsedAt: '2026-11-21T08:15:00Z',
  ),
];

/// A small API that keeps a profile: `GET /me`, `PATCH /me` (the name,
/// trimmed), `PATCH /me/preferences` (merged), the password ([password],
/// `breached password` is refused as breached), the sessions
/// ([sessions]), two-step verification (setup, enable, disable, new
/// recovery codes; the app's code is [testTotp], the recovery codes are
/// [recoveryCodes]), the data export ([testExportZip], counted in
/// [exports]), the account deletion (then every call is a `401`, as for a
/// session that no longer exists), sign-in without MFA, sign-out and the
/// CSRF token. It also answers the dashboard's reads: the summary of any
/// month from [summaryFor] ([demoSummary] by default), [accounts] and
/// [categories]. The accounts are kept: created (`limit_reached` past
/// [maxAccounts]), changed (the balances follow a new initial balance;
/// archiving one in [usedByRecurrence] is refused), deleted (one in
/// [accountsInUse] or [usedByRecurrence] is refused); a card's invoices
/// come from [invoicesFor] ([demoInvoices] by default). Anything else is a
/// `404`.
///
/// [hold] makes the next `PATCH` wait for a completer, [holdSummary] the
/// next summary; [fail] answers the next request to a path with a given
/// reply.
final class ProfileServer {
  new({
    Map<String, Object?>? me,
    List<Map<String, Object?>>? sessions,
    Map<String, Object?> Function(YearMonth month)? summaryFor,
    List<Map<String, Object?>>? accounts,
    List<Map<String, Object?>>? categories,
    List<Map<String, Object?>> Function(
      String accountId,
      YearMonth from,
      YearMonth to,
    )?
    invoicesFor,
  }) : me = me ?? meJson(),
       invoicesFor = invoicesFor ?? ((_, from, to) => demoInvoices(from, to)),
       sessions = sessions ?? defaultSessions(),
       summaryFor = summaryFor ?? demoSummary,
       accounts = accounts ?? demoAccounts(),
       categories = categories ?? demoCategories() {
    if (mfa['enabled'] == true) recoveryCodes = _newCodes();
  }

  /// The profile as stored now (`GET /me` shape).
  Map<String, Object?> me;

  /// The active sessions, in the order `GET /me/sessions` lists them.
  List<Map<String, Object?>> sessions;

  String password = testPassword;

  /// The summary `GET /dashboard/summary?month=` answers.
  Map<String, Object?> Function(YearMonth month) summaryFor;

  /// What `GET /accounts` and `GET /categories` list.
  List<Map<String, Object?>> accounts;
  List<Map<String, Object?>> categories;

  /// A card's invoices from a month to another.
  List<Map<String, Object?>> Function(
    String accountId,
    YearMonth from,
    YearMonth to,
  )
  invoicesFor;

  /// How many accounts a person may hold (the server's cap is 100).
  int maxAccounts = 100;

  /// Accounts with transactions: deleting one is `409 account_in_use`.
  Set<String> accountsInUse = {};

  /// Accounts a recurrence names: archiving or deleting one is
  /// `409 used_by_recurrence`.
  Set<String> usedByRecurrence = {};

  int _nextAccount = 1;

  /// The recovery codes MFA holds now (empty while off).
  List<String> recoveryCodes = const [];

  /// A setup waits for its first code.
  bool setupPending = false;

  /// How many exports were answered.
  int exports = 0;

  /// `DELETE /me` went through.
  bool deleted = false;

  int _generation = 0;

  late final FakeAdapter adapter = FakeAdapter(_handle);

  final List<Completer<void>> _gates = [];
  final Map<String, List<Reply>> _failures = {};

  /// The next `PATCH` waits until the returned completer completes.
  Completer<void> hold() {
    final gate = Completer<void>();
    _gates.add(gate);
    return gate;
  }

  /// The next `GET /me/sessions` waits until the returned completer
  /// completes.
  Completer<void> holdReads() {
    final gate = Completer<void>();
    _readGates.add(gate);
    return gate;
  }

  final List<Completer<void>> _readGates = [];

  /// The next `GET /dashboard/summary` waits until the returned completer
  /// completes.
  Completer<void> holdSummary() {
    final gate = Completer<void>();
    _summaryGates.add(gate);
    return gate;
  }

  final List<Completer<void>> _summaryGates = [];

  /// The next request to [path] (`/api/v1/...`) gets [reply] instead.
  void fail(String path, Reply reply) => (_failures[path] ??= []).add(reply);

  /// The bodies of the `PATCH /me/preferences` sent so far, in order.
  List<Map<String, Object?>> get preferencePatches => [
    for (final r in adapter.sent)
      if (r.method == 'PATCH' && r.path == '/api/v1/me/preferences')
        Map<String, Object?>.of(r.data! as Map<String, Object?>),
  ];

  Map<String, Object?> get preferences =>
      me['preferences']! as Map<String, Object?>;

  Map<String, Object?> get mfa => me['mfa']! as Map<String, Object?>;

  bool get mfaEnabled => mfa['enabled'] == true;

  List<String> _newCodes() {
    _generation++;
    return [
      for (var i = 0; i < 10; i++)
        'gen$_generation-efgh-ijkl-mn${i.toString().padLeft(2, '0')}',
    ];
  }

  void _setMfa({required bool enabled}) {
    recoveryCodes = enabled ? _newCodes() : const [];
    me = {
      ...me,
      'mfa': {
        'enabled': enabled,
        'recoveryCodesRemaining': recoveryCodes.length,
      },
    };
  }

  /// Checks the password, then the code: null when both pass. A recovery
  /// code is spent.
  Reply? _stepUp(Map<String, Object?> body) {
    if (body['password'] != password) {
      return Reply.problem(403, 'password_incorrect');
    }
    final code = body['code'];
    if (code == testTotp) return null;
    if (code is String && recoveryCodes.contains(code)) {
      recoveryCodes = [...recoveryCodes]..remove(code);
      return null;
    }
    return Reply.problem(403, 'mfa_code_invalid');
  }

  /// The step-up of the account routes (export, deletion): the password,
  /// and a code only while MFA is on (the server ignores one sent without).
  Reply? _accountStepUp(Map<String, Object?> body) {
    if (body['password'] != password) {
      return Reply.problem(403, 'password_incorrect');
    }
    return mfaEnabled ? _stepUp(body) : null;
  }

  int _index(String id) => accounts.indexWhere((a) => a['id'] == id);

  Reply _createAccount(Map<String, Object?> body) {
    if (accounts.length >= maxAccounts) {
      return Reply.problem(409, 'limit_reached');
    }
    final name = (body['name'] as String? ?? '').trim();
    if (name.isEmpty) {
      return Reply.problem(
        422,
        'validation_failed',
        errors: [
          {'field': 'name', 'code': 'required'},
        ],
      );
    }
    final initial = body['initialBalance'] as int? ?? 0;
    final card = body['card'] as Map<String, Object?>?;
    final account = accountJson(
      id: 'acc-new-${_nextAccount++}',
      name: name,
      type: body['type']! as String,
      currency: body['currency']! as String,
      initialBalance: initial,
      balance: initial,
      card: card == null ? null : {'limit': null, ...card},
    );
    accounts = [...accounts, account];
    return Reply.json(account, status: 201);
  }

  Reply _updateAccount(String id, Map<String, Object?> body) {
    final i = _index(id);
    if (i < 0) return Reply.problem(404, 'not_found');
    if (body['archived'] == true && usedByRecurrence.contains(id)) {
      return Reply.problem(409, 'used_by_recurrence');
    }
    var account = accounts[i];
    if (body['name'] case final String name) {
      account = {...account, 'name': name.trim()};
    }
    if (body['initialBalance'] case final int initial) {
      final shift = initial - (account['initialBalance']! as int);
      account = {
        ...account,
        'initialBalance': initial,
        'balance': (account['balance']! as int) + shift,
        'projectedBalance': (account['projectedBalance']! as int) + shift,
      };
    }
    if (body['card'] case final Map<String, Object?> card) {
      account = {
        ...account,
        'card': {'limit': null, ...card},
      };
    }
    if (body['archived'] case final bool archived) {
      account = {...account, 'archived': archived};
    }
    accounts = [...accounts]..[i] = account;
    return Reply.json(account);
  }

  Reply _deleteAccount(String id) {
    if (_index(id) < 0) return Reply.problem(404, 'not_found');
    if (accountsInUse.contains(id)) {
      return Reply.problem(409, 'account_in_use');
    }
    if (usedByRecurrence.contains(id)) {
      return Reply.problem(409, 'used_by_recurrence');
    }
    accounts = [
      for (final a in accounts)
        if (a['id'] != id) a,
    ];
    return const Reply(204);
  }

  Reply _invoices(String id, Map<String, String> query) {
    final i = _index(id);
    if (i < 0 || accounts[i]['type'] != 'credit_card') {
      return Reply.problem(404, 'not_found');
    }
    final from = YearMonth.parse(query['from']!);
    final to = YearMonth.parse(query['to']!);
    return Reply.json({'invoices': invoicesFor(id, from, to)});
  }

  Reply _password(Map<String, Object?> body) {
    final next = body['newPassword']! as String;
    if (next.length < 10) {
      return Reply.problem(
        422,
        'validation_failed',
        errors: [
          {'field': 'newPassword', 'code': 'too_short'},
        ],
      );
    }
    if (body['currentPassword'] != password) {
      return Reply.problem(403, 'password_incorrect');
    }
    if (next == 'breached password') {
      return Reply.problem(
        422,
        'validation_failed',
        errors: [
          {'field': 'newPassword', 'code': 'breached'},
        ],
      );
    }
    password = next;
    sessions = [
      for (final s in sessions)
        if (s['current'] == true) s,
    ];
    return const Reply(204);
  }

  Reply _mfa(String action, Map<String, Object?> body) {
    switch (action) {
      case 'setup':
        if (mfaEnabled) return Reply.problem(409, 'mfa_already_enabled');
        if (body['password'] != password) {
          return Reply.problem(403, 'password_incorrect');
        }
        setupPending = true;
        return Reply.json({
          'secret': testMfaSecret,
          'otpauthUri': testOtpauthUri,
          'expiresIn': 900,
        });
      case 'enable':
        if (mfaEnabled) return Reply.problem(409, 'mfa_already_enabled');
        if (!setupPending) return Reply.problem(409, 'mfa_setup_required');
        if (body['code'] != testTotp) {
          return Reply.problem(403, 'mfa_code_invalid');
        }
        setupPending = false;
        _setMfa(enabled: true);
        return Reply.json({'recoveryCodes': recoveryCodes});
      case 'disable':
        if (!mfaEnabled) return Reply.problem(409, 'mfa_not_enabled');
        final refused = _stepUp(body);
        if (refused != null) return refused;
        _setMfa(enabled: false);
        return const Reply(204);
      case 'recovery-codes':
        if (!mfaEnabled) return Reply.problem(409, 'mfa_not_enabled');
        final refused = _stepUp(body);
        if (refused != null) return refused;
        _setMfa(enabled: true);
        return Reply.json({'recoveryCodes': recoveryCodes});
    }
    return Reply.problem(404, 'not_found');
  }

  Future<Reply> _handle(SentRequest r) async {
    if (r.method == 'PATCH' && _gates.isNotEmpty) {
      await _gates.removeAt(0).future;
    }
    if (r.method == 'GET' &&
        r.path == '/api/v1/me/sessions' &&
        _readGates.isNotEmpty) {
      await _readGates.removeAt(0).future;
    }
    if (r.method == 'GET' &&
        r.path == '/api/v1/dashboard/summary' &&
        _summaryGates.isNotEmpty) {
      await _summaryGates.removeAt(0).future;
    }
    if (deleted) return Reply.problem(401, 'unauthorized');
    final failures = _failures[r.path];
    if (failures != null && failures.isNotEmpty) return failures.removeAt(0);
    final body = r.data is Map
        ? r.data! as Map<String, Object?>
        : const <String, Object?>{};
    switch ((r.method, r.path)) {
      case ('GET', '/api/v1/auth/csrf'):
        return Reply.json({'csrfToken': 'csrf'});
      case ('POST', '/api/v1/auth/login'):
        return Reply.json(sessionJson());
      case ('POST', '/api/v1/auth/logout'):
        return const Reply(204);
      case ('GET', '/api/v1/me'):
        return Reply.json(me);
      case ('PATCH', '/api/v1/me'):
        me = {...me, 'name': (body['name']! as String).trim()};
        return Reply.json(me);
      case ('PATCH', '/api/v1/me/preferences'):
        me = {
          ...me,
          'preferences': {...preferences, ...body},
        };
        return Reply.json(preferences);
      case ('POST', '/api/v1/me/password'):
        return _password(body);
      case ('POST', '/api/v1/me/export'):
        final refused = _accountStepUp(body);
        if (refused != null) return refused;
        exports++;
        return Reply.bytes(testExportZip);
      case ('DELETE', '/api/v1/me'):
        final refused = _accountStepUp(body);
        if (refused != null) return refused;
        deleted = true;
        return const Reply(204);
      case ('GET', '/api/v1/me/sessions'):
        return Reply.json({'sessions': sessions});
      case ('GET', '/api/v1/dashboard/summary'):
        final month = YearMonth.tryParse(r.query['month']) ?? testMonth;
        return Reply.json(summaryFor(month));
      case ('GET', '/api/v1/accounts'):
        final archived = r.query['includeArchived'] == 'true';
        return Reply.json({
          'accounts': [
            for (final a in accounts)
              if (archived || a['archived'] != true) a,
          ],
        });
      case ('POST', '/api/v1/accounts'):
        return _createAccount(body);
      case ('GET', final path)
          when path.startsWith('/api/v1/accounts/') &&
              path.endsWith('/invoices'):
        return _invoices(Uri.decodeComponent(path.split('/')[4]), r.query);
      case ('PATCH', final path) when path.startsWith('/api/v1/accounts/'):
        return _updateAccount(Uri.decodeComponent(path.split('/').last), body);
      case ('DELETE', final path) when path.startsWith('/api/v1/accounts/'):
        return _deleteAccount(Uri.decodeComponent(path.split('/').last));
      case ('GET', '/api/v1/categories'):
        return Reply.json({'categories': categories});
      case ('DELETE', '/api/v1/me/sessions'):
        sessions = [
          for (final s in sessions)
            if (s['current'] == true) s,
        ];
        return const Reply(204);
      case ('POST', final path) when path.startsWith('/api/v1/auth/mfa/'):
        return _mfa(path.substring('/api/v1/auth/mfa/'.length), body);
      case ('DELETE', final path) when path.startsWith('/api/v1/me/sessions/'):
        final id = Uri.decodeComponent(path.split('/').last);
        final before = sessions.length;
        sessions = [
          for (final s in sessions)
            if (s['id'] != id) s,
        ];
        return sessions.length == before
            ? Reply.problem(404, 'not_found')
            : const Reply(204);
    }
    return Reply.problem(404, 'not_found');
  }
}
