// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_setup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MfaSetup _$MfaSetupFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MfaSetup', json, ($checkedConvert) {
      final val = _MfaSetup(
        secret: $checkedConvert('secret', (v) => v as String),
        otpauthUri: $checkedConvert('otpauthUri', (v) => v as String),
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$MfaSetupToJson(_MfaSetup instance) => <String, dynamic>{
  'secret': instance.secret,
  'otpauthUri': instance.otpauthUri,
  'expiresIn': instance.expiresIn,
};
