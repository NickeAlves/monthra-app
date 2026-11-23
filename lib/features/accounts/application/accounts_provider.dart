import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/accounts/data/accounts_api.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accounts_provider.g.dart';

/// Every account of the signed-in person, archived ones included, oldest
/// first. Reset when the signed-in person changes; empty signed out.
@Riverpod(retry: noProviderRetry)
Future<List<Account>> accounts(Ref ref) {
  final userId = ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
  );
  if (userId == null) return Future.value(const []);
  return ref.watch(accountsApiProvider).list(includeArchived: true);
}
