// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Me _$MeFromJson(Map<String, dynamic> json) => $checkedCreate('_Me', json, (
  $checkedConvert,
) {
  final val = _Me(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
    mfa: $checkedConvert(
      'mfa',
      (v) => MfaStatus.fromJson(v as Map<String, dynamic>),
    ),
    preferences: $checkedConvert(
      'preferences',
      (v) => MePreferences.fromJson(v as Map<String, dynamic>),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$MeToJson(_Me instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'emailVerified': instance.emailVerified,
  'mfa': instance.mfa.toJson(),
  'preferences': instance.preferences.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
};

_MfaStatus _$MfaStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MfaStatus', json, ($checkedConvert) {
      final val = _MfaStatus(
        enabled: $checkedConvert('enabled', (v) => v as bool),
        recoveryCodesRemaining: $checkedConvert(
          'recoveryCodesRemaining',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MfaStatusToJson(_MfaStatus instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'recoveryCodesRemaining': instance.recoveryCodesRemaining,
    };

_MePreferences _$MePreferencesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MePreferences', json, ($checkedConvert) {
      final val = _MePreferences(
        locale: $checkedConvert('locale', (v) => v as String),
        theme: $checkedConvert('theme', (v) => v as String),
        currency: $checkedConvert('currency', (v) => v as String),
        budgetAlerts: $checkedConvert('budgetAlerts', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$MePreferencesToJson(_MePreferences instance) =>
    <String, dynamic>{
      'locale': instance.locale,
      'theme': instance.theme,
      'currency': instance.currency,
      'budgetAlerts': instance.budgetAlerts,
    };
