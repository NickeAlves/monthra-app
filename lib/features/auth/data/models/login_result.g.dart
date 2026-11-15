// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MfaChallenge _$MfaChallengeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MfaChallenge', json, ($checkedConvert) {
      final val = _MfaChallenge(
        mfaToken: $checkedConvert('mfaToken', (v) => v as String),
        expiresIn: $checkedConvert('expiresIn', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$MfaChallengeToJson(_MfaChallenge instance) =>
    <String, dynamic>{
      'mfaToken': instance.mfaToken,
      'expiresIn': instance.expiresIn,
    };
