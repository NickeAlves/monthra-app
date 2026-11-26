import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/data/data_revision.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/accounts/data/accounts_api.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_provider.g.dart';

/// Every account of the signed-in person, archived ones included, oldest
/// first, with balances up to the device's today. Reset when the
/// signed-in person changes, read again after a write
/// ([dataRevisionProvider]); empty signed out.
@Riverpod(retry: noProviderRetry)
Future<List<Account>> accounts(Ref ref) {
  final userId = ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
  );
  ref.watch(dataRevisionProvider);
  if (userId == null) return Future.value(const []);
  final today = ref.read(clockProvider)();
  return ref
      .watch(accountsApiProvider)
      .list(includeArchived: true, today: today);
}

/// The invoices of card [accountId] from [from] to [to], their statuses
/// as of the device's today. Reset with the signed-in person, read again
/// after a write; empty signed out.
@Riverpod(retry: noProviderRetry)
Future<List<Invoice>> invoices(
  Ref ref,
  String accountId,
  YearMonth from,
  YearMonth to,
) {
  final userId = ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
  );
  ref.watch(dataRevisionProvider);
  if (userId == null) return Future.value(const []);
  final today = ref.read(clockProvider)();
  return ref
      .watch(accountsApiProvider)
      .invoices(accountId, from: from, to: to, today: today);
}

/// The account writes of the screens. Each one tells the readers of sums
/// ([dataRevisionProvider]) once the server answered, so the lists, the
/// invoices and the dashboard read again.
@Riverpod(keepAlive: true)
AccountWrites accountWrites(Ref ref) => AccountWrites(
  api: ref.watch(accountsApiProvider),
  clock: ref.watch(clockProvider),
  written: () => ref.read(dataRevisionProvider.notifier).bump(),
);

final class AccountWrites {
  const new({required this._api, required this._clock, required this._written});

  final AccountsApi _api;
  final DateTime Function() _clock;
  final void Function() _written;

  Future<Account> create(AccountDraft draft) async {
    final account = await _api.create(draft, today: _clock());
    _written();
    return account;
  }

  Future<Account> update(String id, AccountChanges changes) async {
    final account = await _api.update(id, changes, today: _clock());
    _written();
    return account;
  }

  Future<Account> archive(String id, {required bool archived}) =>
      update(id, AccountChanges(archived: archived));

  Future<void> delete(String id) async {
    await _api.delete(id);
    _written();
  }
}
