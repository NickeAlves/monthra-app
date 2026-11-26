import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_api.g.dart';

@Riverpod(keepAlive: true)
AccountsApi accountsApi(Ref ref) => AccountsApi(ref.watch(apiClientProvider));

/// The account routes of the API (the OpenAPI's `accounts` tag): the list
/// so far; the accounts PR adds the writes. Every failure is an
/// `ApiException`.
class AccountsApi {
  const new(this._api);

  final ApiClient _api;

  /// Every account of the caller (at most 100), archived ones too when
  /// [includeArchived], oldest first.
  Future<List<Account>> list({bool includeArchived = false}) async {
    final response = await _api.get<Map<String, Object?>>(
      '/accounts',
      query: {if (includeArchived) 'includeArchived': 'true'},
    );
    return readJson<List<Account>>(
      response.data,
      (json) => [
        for (final a in json['accounts']! as List<Object?>)
          Account.fromJson(a! as Map<String, Object?>),
      ],
    );
  }
}
