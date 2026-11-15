// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_problem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiProblem _$ApiProblemFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ApiProblem', json, ($checkedConvert) {
      final val = _ApiProblem(
        type: $checkedConvert('type', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        code: $checkedConvert('code', (v) => v as String),
        detail: $checkedConvert('detail', (v) => v as String?),
        instance: $checkedConvert('instance', (v) => v as String?),
        requestId: $checkedConvert('requestId', (v) => v as String?),
        errors: $checkedConvert(
          'errors',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => FieldError.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const <FieldError>[],
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiProblemToJson(_ApiProblem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'status': instance.status,
      'code': instance.code,
      'detail': instance.detail,
      'instance': instance.instance,
      'requestId': instance.requestId,
      'errors': instance.errors.map((e) => e.toJson()).toList(),
    };

_FieldError _$FieldErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_FieldError', json, ($checkedConvert) {
      final val = _FieldError(
        field: $checkedConvert('field', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$FieldErrorToJson(_FieldError instance) =>
    <String, dynamic>{'field': instance.field, 'code': instance.code};
