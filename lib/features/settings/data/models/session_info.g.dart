// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionInfo _$SessionInfoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_SessionInfo', json, ($checkedConvert) {
  final val = _SessionInfo(
    id: $checkedConvert('id', (v) => v as String),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    lastUsedAt: $checkedConvert(
      'lastUsedAt',
      (v) => DateTime.parse(v as String),
    ),
    expiresAt: $checkedConvert('expiresAt', (v) => DateTime.parse(v as String)),
    userAgent: $checkedConvert('userAgent', (v) => v as String),
    ip: $checkedConvert('ip', (v) => v as String),
    current: $checkedConvert('current', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$SessionInfoToJson(_SessionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'userAgent': instance.userAgent,
      'ip': instance.ip,
      'current': instance.current,
    };
