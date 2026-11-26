import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_api.g.dart';

@Riverpod(keepAlive: true)
AccountsApi accountsApi(Ref ref) => AccountsApi(ref.watch(apiClientProvider));

/// The account and invoice routes of the API (the OpenAPI's `accounts`
/// and `invoices` tags). Balances read up to `today`: the reader's local
/// day, sent as `asOf`. Every failure is an `ApiException`.
class AccountsApi {
  const new(this._api);

  final ApiClient _api;

  static String _path(String id) => '/accounts/${Uri.encodeComponent(id)}';

  static Map<String, Object?> _asOf(DateTime? today) => {
    if (today != null) 'asOf': civilDate(today),
  };

  static Account _account(Map<String, Object?>? data) =>
      readJson<Account>(data, Account.fromJson);

  /// Every account of the caller (at most 100), archived ones too when
  /// [includeArchived], oldest first.
  Future<List<Account>> list({
    bool includeArchived = false,
    DateTime? today,
  }) async {
    final response = await _api.get<Map<String, Object?>>(
      '/accounts',
      query: {if (includeArchived) 'includeArchived': 'true', ..._asOf(today)},
    );
    return readJson<List<Account>>(
      response.data,
      (json) => [
        for (final a in json['accounts']! as List<Object?>)
          Account.fromJson(a! as Map<String, Object?>),
      ],
    );
  }

  /// Creates [draft]; `409 limit_reached` past the cap of accounts.
  Future<Account> create(AccountDraft draft, {DateTime? today}) async {
    final response = await _api.post<Map<String, Object?>>(
      '/accounts',
      data: draft.toJson(),
      query: _asOf(today),
    );
    return _account(response.data);
  }

  /// Applies [changes]; archiving an account an active recurrence uses is
  /// `409 used_by_recurrence`.
  Future<Account> update(
    String id,
    AccountChanges changes, {
    DateTime? today,
  }) async {
    final response = await _api.patch<Map<String, Object?>>(
      _path(id),
      data: changes.toJson(),
      query: _asOf(today),
    );
    return _account(response.data);
  }

  /// Deletes an account without transactions for good: one with
  /// transactions is `409 account_in_use` (archive it instead), one a
  /// recurrence names is `409 used_by_recurrence`.
  Future<void> delete(String id) => _api.delete<void>(_path(id));

  /// The invoices of credit card [id] from [from] to [to] (both included,
  /// at most 24), oldest first, their statuses as of [today]. An account
  /// that is not a card is a `404`.
  Future<List<Invoice>> invoices(
    String id, {
    required YearMonth from,
    required YearMonth to,
    DateTime? today,
  }) async {
    final response = await _api.get<Map<String, Object?>>(
      '${_path(id)}/invoices',
      query: {'from': from.toString(), 'to': to.toString(), ..._asOf(today)},
    );
    return readJson<List<Invoice>>(
      response.data,
      (json) => [
        for (final i in json['invoices']! as List<Object?>)
          Invoice.fromJson(i! as Map<String, Object?>),
      ],
    );
  }
}
