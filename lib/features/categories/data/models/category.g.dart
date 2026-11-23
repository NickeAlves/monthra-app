// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Category', json, ($checkedConvert) {
      final val = _Category(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$CategoryKindEnumMap,
            v,
            unknownValue: CategoryKind.unknown,
          ),
        ),
        icon: $checkedConvert('icon', (v) => v as String),
        color: $checkedConvert('color', (v) => v as String),
        defaultKey: $checkedConvert('defaultKey', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'kind': _$CategoryKindEnumMap[instance.kind]!,
  'icon': instance.icon,
  'color': instance.color,
  'defaultKey': instance.defaultKey,
};

const _$CategoryKindEnumMap = {
  CategoryKind.expense: 'expense',
  CategoryKind.income: 'income',
  CategoryKind.unknown: 'unknown',
};
