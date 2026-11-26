// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CardSettings _$CardSettingsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CardSettings', json, ($checkedConvert) {
      final val = _CardSettings(
        closingDay: $checkedConvert('closingDay', (v) => (v as num).toInt()),
        dueDay: $checkedConvert('dueDay', (v) => (v as num).toInt()),
        limit: $checkedConvert('limit', (v) => (v as num?)?.toInt()),
      );
      return val;
    });

Map<String, dynamic> _$CardSettingsToJson(_CardSettings instance) =>
    <String, dynamic>{
      'closingDay': instance.closingDay,
      'dueDay': instance.dueDay,
      'limit': instance.limit,
    };

_Account _$AccountFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Account',
  json,
  ($checkedConvert) {
    final val = _Account(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(
          _$AccountTypeEnumMap,
          v,
          unknownValue: AccountType.unknown,
        ),
      ),
      currency: $checkedConvert(
        'currency',
        (v) => const CurrencyConverter().fromJson(v as String),
      ),
      initialBalance: $checkedConvert(
        'initialBalance',
        (v) => (v as num).toInt(),
      ),
      balance: $checkedConvert('balance', (v) => (v as num).toInt()),
      projectedBalance: $checkedConvert(
        'projectedBalance',
        (v) => (v as num).toInt(),
      ),
      card: $checkedConvert(
        'card',
        (v) =>
            v == null ? null : CardSettings.fromJson(v as Map<String, dynamic>),
      ),
      source: $checkedConvert(
        'source',
        (v) => $enumDecode(
          _$AccountSourceEnumMap,
          v,
          unknownValue: AccountSource.unknown,
        ),
      ),
      archived: $checkedConvert('archived', (v) => v as bool),
    );
    return val;
  },
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$AccountTypeEnumMap[instance.type]!,
  'currency': const CurrencyConverter().toJson(instance.currency),
  'initialBalance': instance.initialBalance,
  'balance': instance.balance,
  'projectedBalance': instance.projectedBalance,
  'card': instance.card?.toJson(),
  'source': _$AccountSourceEnumMap[instance.source]!,
  'archived': instance.archived,
};

const _$AccountTypeEnumMap = {
  AccountType.checking: 'checking',
  AccountType.savings: 'savings',
  AccountType.creditCard: 'credit_card',
  AccountType.cash: 'cash',
  AccountType.brokerage: 'brokerage',
  AccountType.unknown: 'unknown',
};

const _$AccountSourceEnumMap = {
  AccountSource.manual: 'manual',
  AccountSource.openFinance: 'open_finance',
  AccountSource.unknown: 'unknown',
};
