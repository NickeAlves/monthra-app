// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Session', json, ($checkedConvert) {
      final val = _Session(
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num).toInt()),
        refreshExpiresIn: $checkedConvert(
          'refreshExpiresIn',
          (v) => (v as num).toInt(),
        ),
        tokenType: $checkedConvert('tokenType', (v) => v as String?),
        accessToken: $checkedConvert('accessToken', (v) => v as String?),
        refreshToken: $checkedConvert('refreshToken', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'expiresIn': instance.expiresIn,
  'refreshExpiresIn': instance.refreshExpiresIn,
  'tokenType': instance.tokenType,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
};
