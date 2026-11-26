import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/json/converters.dart';
import 'package:monthra/core/money/currency.dart';

part 'summary.freezed.dart';
part 'summary.g.dart';

/// One month of the caller's money (`GET /dashboard/summary`, `Summary` in
/// the OpenAPI): a summary per currency, never converted, and every
/// account's balance on [asOf].
@freezed
abstract class DashboardSummary with _$DashboardSummary {
  const factory({
    @YearMonthConverter() required YearMonth month,

    /// The day the balances count up to: the month's last day, or the
    /// reader's today when that comes first.
    @CivilDateConverter() required DateTime asOf,

    /// One per currency of the caller's accounts, alphabetically.
    required List<CurrencySummary> currencies,

    /// Every account, archived ones included, oldest first.
    required List<AccountBalance> accounts,
  }) = _DashboardSummary;

  const new _();

  factory fromJson(Map<String, Object?> json) =>
      _$DashboardSummaryFromJson(json);
}

/// The month in one currency, amounts in its minor units.
@freezed
abstract class CurrencySummary with _$CurrencySummary {
  const factory({
    @CurrencyConverter() required Currency currency,

    /// The whole month, the days still to come included; transfers are
    /// neither income nor expense.
    required int income,
    required int expense,

    /// `income - expense`.
    required int net,

    /// What the recurrences are still to create in the month.
    required ScheduledFlows scheduled,

    /// The net worth on `asOf` (a card's debt counts against it).
    required int balance,

    /// The largest first.
    required List<CategoryTotal> expensesByCategory,
    required List<CategoryTotal> incomeByCategory,

    /// The 12 months up to the month, oldest first.
    required List<SummaryPoint> history,
  }) = _CurrencySummary;

  const new _();

  factory fromJson(Map<String, Object?> json) =>
      _$CurrencySummaryFromJson(json);
}

/// Income and expense the recurrences are still to create.
@freezed
abstract class ScheduledFlows with _$ScheduledFlows {
  const factory({required int income, required int expense}) = _ScheduledFlows;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$ScheduledFlowsFromJson(json);
}

/// A category's share of the month: its id (names, icons and colors come
/// from `/categories`), the amount and how many transactions.
@freezed
abstract class CategoryTotal with _$CategoryTotal {
  const factory({
    required String categoryId,
    required int amount,
    required int count,
  }) = _CategoryTotal;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$CategoryTotalFromJson(json);
}

/// One month of the history.
@freezed
abstract class SummaryPoint with _$SummaryPoint {
  const factory({
    @YearMonthConverter() required YearMonth month,
    required int income,
    required int expense,

    /// The balance at the end of the month (on `asOf` in its month); null
    /// for a month after `asOf`.
    required int? netWorth,
  }) = _SummaryPoint;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$SummaryPointFromJson(json);
}

/// An account's balance on `asOf` (its name and type come from
/// `/accounts`).
@freezed
abstract class AccountBalance with _$AccountBalance {
  const factory({
    required String accountId,
    @CurrencyConverter() required Currency currency,
    required int balance,
  }) = _AccountBalance;

  const new _();

  factory fromJson(Map<String, Object?> json) => _$AccountBalanceFromJson(json);
}
