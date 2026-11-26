import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_client.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/dashboard/data/models/summary.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_api.g.dart';

@Riverpod(keepAlive: true)
DashboardApi dashboardApi(Ref ref) =>
    DashboardApi(ref.watch(apiClientProvider));

/// The dashboard route of the API (the OpenAPI's `dashboard` tag). Every
/// failure is an `ApiException`.
class DashboardApi {
  const new(this._api);

  final ApiClient _api;

  /// The summary of [month] by currency, with balances up to [today] (the
  /// reader's local day, which the server holds within a day of its own).
  /// The server creates the recurrences' occurrences due by then first.
  Future<DashboardSummary> summary(
    YearMonth month, {
    required DateTime today,
  }) async {
    final response = await _api.get<Map<String, Object?>>(
      '/dashboard/summary',
      query: {'month': month.toString(), 'asOf': civilDate(today)},
    );
    return readJson<DashboardSummary>(response.data, DashboardSummary.fromJson);
  }
}
