// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Account', json, ($checkedConvert) {
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
        balance: $checkedConvert('balance', (v) => (v as num).toInt()),
        projectedBalance: $checkedConvert(
          'projectedBalance',
          (v) => (v as num).toInt(),
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
    });

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$AccountTypeEnumMap[instance.type]!,
  'currency': const CurrencyConverter().toJson(instance.currency),
  'balance': instance.balance,
  'projectedBalance': instance.projectedBalance,
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
