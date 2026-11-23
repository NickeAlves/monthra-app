// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardSummary _$DashboardSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_DashboardSummary', json, ($checkedConvert) {
      final val = _DashboardSummary(
        month: $checkedConvert(
          'month',
          (v) => const YearMonthConverter().fromJson(v as String),
        ),
        asOf: $checkedConvert(
          'asOf',
          (v) => const CivilDateConverter().fromJson(v as String),
        ),
        currencies: $checkedConvert(
          'currencies',
          (v) => (v as List<dynamic>)
              .map((e) => CurrencySummary.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        accounts: $checkedConvert(
          'accounts',
          (v) => (v as List<dynamic>)
              .map((e) => AccountBalance.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardSummaryToJson(_DashboardSummary instance) =>
    <String, dynamic>{
      'month': const YearMonthConverter().toJson(instance.month),
      'asOf': const CivilDateConverter().toJson(instance.asOf),
      'currencies': instance.currencies.map((e) => e.toJson()).toList(),
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
    };

_CurrencySummary _$CurrencySummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CurrencySummary', json, ($checkedConvert) {
      final val = _CurrencySummary(
        currency: $checkedConvert(
          'currency',
          (v) => const CurrencyConverter().fromJson(v as String),
        ),
        income: $checkedConvert('income', (v) => (v as num).toInt()),
        expense: $checkedConvert('expense', (v) => (v as num).toInt()),
        net: $checkedConvert('net', (v) => (v as num).toInt()),
        scheduled: $checkedConvert(
          'scheduled',
          (v) => ScheduledFlows.fromJson(v as Map<String, dynamic>),
        ),
        balance: $checkedConvert('balance', (v) => (v as num).toInt()),
        expensesByCategory: $checkedConvert(
          'expensesByCategory',
          (v) => (v as List<dynamic>)
              .map((e) => CategoryTotal.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        incomeByCategory: $checkedConvert(
          'incomeByCategory',
          (v) => (v as List<dynamic>)
              .map((e) => CategoryTotal.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        history: $checkedConvert(
          'history',
          (v) => (v as List<dynamic>)
              .map((e) => SummaryPoint.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CurrencySummaryToJson(
  _CurrencySummary instance,
) => <String, dynamic>{
  'currency': const CurrencyConverter().toJson(instance.currency),
  'income': instance.income,
  'expense': instance.expense,
  'net': instance.net,
  'scheduled': instance.scheduled.toJson(),
  'balance': instance.balance,
  'expensesByCategory': instance.expensesByCategory
      .map((e) => e.toJson())
      .toList(),
  'incomeByCategory': instance.incomeByCategory.map((e) => e.toJson()).toList(),
  'history': instance.history.map((e) => e.toJson()).toList(),
};

_ScheduledFlows _$ScheduledFlowsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ScheduledFlows', json, ($checkedConvert) {
      final val = _ScheduledFlows(
        income: $checkedConvert('income', (v) => (v as num).toInt()),
        expense: $checkedConvert('expense', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$ScheduledFlowsToJson(_ScheduledFlows instance) =>
    <String, dynamic>{'income': instance.income, 'expense': instance.expense};

_CategoryTotal _$CategoryTotalFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CategoryTotal', json, ($checkedConvert) {
      final val = _CategoryTotal(
        categoryId: $checkedConvert('categoryId', (v) => v as String),
        amount: $checkedConvert('amount', (v) => (v as num).toInt()),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CategoryTotalToJson(_CategoryTotal instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'count': instance.count,
    };

_SummaryPoint _$SummaryPointFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SummaryPoint', json, ($checkedConvert) {
      final val = _SummaryPoint(
        month: $checkedConvert(
          'month',
          (v) => const YearMonthConverter().fromJson(v as String),
        ),
        income: $checkedConvert('income', (v) => (v as num).toInt()),
        expense: $checkedConvert('expense', (v) => (v as num).toInt()),
        netWorth: $checkedConvert('netWorth', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$SummaryPointToJson(_SummaryPoint instance) =>
    <String, dynamic>{
      'month': const YearMonthConverter().toJson(instance.month),
      'income': instance.income,
      'expense': instance.expense,
      'netWorth': instance.netWorth,
    };

_AccountBalance _$AccountBalanceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_AccountBalance', json, ($checkedConvert) {
      final val = _AccountBalance(
        accountId: $checkedConvert('accountId', (v) => v as String),
        currency: $checkedConvert(
          'currency',
          (v) => const CurrencyConverter().fromJson(v as String),
        ),
        balance: $checkedConvert('balance', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$AccountBalanceToJson(_AccountBalance instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'currency': const CurrencyConverter().toJson(instance.currency),
      'balance': instance.balance,
    };
