import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/accounts/application/accounts_provider.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/categories/application/categories_provider.dart';
import 'package:monthra/features/categories/data/models/category.dart';
import 'package:monthra/features/dashboard/data/dashboard_api.dart';
import 'package:monthra/features/dashboard/data/models/summary.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_providers.g.dart';

/// The summary of [month] for the signed-in person, with balances up to
/// the device's today; null signed out. Reset when the person changes.
/// The writing features invalidate it after each write (the server drops
/// its own cache then).
@Riverpod(retry: noProviderRetry)
Future<DashboardSummary?> dashboardSummary(Ref ref, YearMonth month) {
  final userId = ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
  );
  if (userId == null) return Future.value();
  final today = ref.read(clockProvider)();
  return ref.watch(dashboardApiProvider).summary(month, today: today);
}

/// The dashboard of [month]: its summary joined with the accounts and
/// categories, the profile's currency first; null signed out.
@Riverpod(retry: noProviderRetry)
Future<DashboardView?> dashboardView(Ref ref, YearMonth month) async {
  final preferred = ref.watch(
    authControllerProvider.select(
      (s) => s is SignedIn ? s.me.preferences.currencyValue : null,
    ),
  );
  // Started together, so the three reads go out at once; Future.wait
  // answers the first failure and observes the others.
  final results = await Future.wait<Object?>([
    ref.watch(dashboardSummaryProvider(month).future),
    ref.watch(accountsProvider.future),
    ref.watch(categoriesProvider.future),
  ]);
  final summary = results[0] as DashboardSummary?;
  if (summary == null) return null;
  return DashboardView.build(
    summary: summary,
    accounts: results[1]! as List<Account>,
    categories: results[2]! as List<Category>,
    preferred: preferred,
  );
}
