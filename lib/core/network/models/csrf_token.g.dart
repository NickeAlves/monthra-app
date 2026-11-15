// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csrf_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CsrfToken _$CsrfTokenFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CsrfToken', json, ($checkedConvert) {
      final val = _CsrfToken(
        csrfToken: $checkedConvert('csrfToken', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CsrfTokenToJson(_CsrfToken instance) =>
    <String, dynamic>{'csrfToken': instance.csrfToken};
