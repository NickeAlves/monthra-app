// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_problem.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiProblem {

 String get type; String get title; int get status; String get code; String? get detail; String? get instance; String? get requestId; List<FieldError> get errors;
/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiProblemCopyWith<ApiProblem> get copyWith => _$ApiProblemCopyWithImpl<ApiProblem>(this as ApiProblem, _$identity);

  /// Serializes this ApiProblem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApiProblem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiProblem&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.detail, _this.detail) || other.detail == _this.detail)&&(identical(other.instance, _this.instance) || other.instance == _this.instance)&&(identical(other.requestId, _this.requestId) || other.requestId == _this.requestId)&&const DeepCollectionEquality().equals(other.errors, _this.errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiProblem;
  return Object.hash(runtimeType,_this.type,_this.title,_this.status,_this.code,_this.detail,_this.instance,_this.requestId,const DeepCollectionEquality().hash(_this.errors));
}

@override
String toString() {
  final _this = this as ApiProblem;
  return 'ApiProblem(type: ${_this.type}, title: ${_this.title}, status: ${_this.status}, code: ${_this.code}, detail: ${_this.detail}, instance: ${_this.instance}, requestId: ${_this.requestId}, errors: ${_this.errors})';
}


}

/// @nodoc
abstract mixin class $ApiProblemCopyWith<$Res>  {
  factory $ApiProblemCopyWith(ApiProblem value, $Res Function(ApiProblem) _then) = _$ApiProblemCopyWithImpl;
@useResult
$Res call({
 String type, String title, int status, String code, String? detail, String? instance, String? requestId, List<FieldError> errors
});




}
/// @nodoc
class _$ApiProblemCopyWithImpl<$Res>
    implements $ApiProblemCopyWith<$Res> {
  _$ApiProblemCopyWithImpl(this._self, this._then);

  final ApiProblem _self;
  final $Res Function(ApiProblem) _then;

/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? detail = freezed,Object? instance = freezed,Object? requestId = freezed,Object? errors = null,}) {
  return _then(ApiProblem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self.errors : errors // ignore: cast_nullable_to_non_nullable
as List<FieldError>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiProblem].
extension ApiProblemPatterns on ApiProblem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiProblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiProblem value)  $default,){
final _that = this;
switch (_that) {
case _ApiProblem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiProblem value)?  $default,){
final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  String? requestId,  List<FieldError> errors)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.requestId,_that.errors);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  String? requestId,  List<FieldError> errors)  $default,) {final _that = this;
switch (_that) {
case _ApiProblem():
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.requestId,_that.errors);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String title,  int status,  String code,  String? detail,  String? instance,  String? requestId,  List<FieldError> errors)?  $default,) {final _that = this;
switch (_that) {
case _ApiProblem() when $default != null:
return $default(_that.type,_that.title,_that.status,_that.code,_that.detail,_that.instance,_that.requestId,_that.errors);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiProblem extends ApiProblem {
  const _ApiProblem({required this.type, required this.title, required this.status, required this.code, this.detail, this.instance, this.requestId,  List<FieldError> errors = const <FieldError>[]}): _errors = errors,super._();
  factory _ApiProblem.fromJson(Map<String, dynamic> json) => _$ApiProblemFromJson(json);

@override final  String type;
@override final  String title;
@override final  int status;
@override final  String code;
@override final  String? detail;
@override final  String? instance;
@override final  String? requestId;
 final  List<FieldError> _errors;
@override@JsonKey() List<FieldError> get errors {
  if (_errors is EqualUnmodifiableListView) return _errors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_errors);
}


/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiProblemCopyWith<_ApiProblem> get copyWith => __$ApiProblemCopyWithImpl<_ApiProblem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiProblemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiProblem&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.code, code) || other.code == code)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.instance, instance) || other.instance == instance)&&(identical(other.requestId, requestId) || other.requestId == requestId)&&const DeepCollectionEquality().equals(other.errors, _errors));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,type,title,status,code,detail,instance,requestId,const DeepCollectionEquality().hash(_errors));
}

@override
String toString() {
    return 'ApiProblem(type: $type, title: $title, status: $status, code: $code, detail: $detail, instance: $instance, requestId: $requestId, errors: $errors)';
}


}

/// @nodoc
abstract mixin class _$ApiProblemCopyWith<$Res> implements $ApiProblemCopyWith<$Res> {
  factory _$ApiProblemCopyWith(_ApiProblem value, $Res Function(_ApiProblem) _then) = __$ApiProblemCopyWithImpl;
@override @useResult
$Res call({
 String type, String title, int status, String code, String? detail, String? instance, String? requestId, List<FieldError> errors
});




}
/// @nodoc
class __$ApiProblemCopyWithImpl<$Res>
    implements _$ApiProblemCopyWith<$Res> {
  __$ApiProblemCopyWithImpl(this._self, this._then);

  final _ApiProblem _self;
  final $Res Function(_ApiProblem) _then;

/// Create a copy of ApiProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = null,Object? status = null,Object? code = null,Object? detail = freezed,Object? instance = freezed,Object? requestId = freezed,Object? errors = null,}) {
  return _then(_ApiProblem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,instance: freezed == instance ? _self.instance : instance // ignore: cast_nullable_to_non_nullable
as String?,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,errors: null == errors ? _self._errors : errors // ignore: cast_nullable_to_non_nullable
as List<FieldError>,
  ));
}


}


/// @nodoc
mixin _$FieldError {

 String get field; String get code;
/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldErrorCopyWith<FieldError> get copyWith => _$FieldErrorCopyWithImpl<FieldError>(this as FieldError, _$identity);

  /// Serializes this FieldError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as FieldError;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldError&&(identical(other.field, _this.field) || other.field == _this.field)&&(identical(other.code, _this.code) || other.code == _this.code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as FieldError;
  return Object.hash(runtimeType,_this.field,_this.code);
}

@override
String toString() {
  final _this = this as FieldError;
  return 'FieldError(field: ${_this.field}, code: ${_this.code})';
}


}

/// @nodoc
abstract mixin class $FieldErrorCopyWith<$Res>  {
  factory $FieldErrorCopyWith(FieldError value, $Res Function(FieldError) _then) = _$FieldErrorCopyWithImpl;
@useResult
$Res call({
 String field, String code
});




}
/// @nodoc
class _$FieldErrorCopyWithImpl<$Res>
    implements $FieldErrorCopyWith<$Res> {
  _$FieldErrorCopyWithImpl(this._self, this._then);

  final FieldError _self;
  final $Res Function(FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? code = null,}) {
  return _then(FieldError(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldError].
extension FieldErrorPatterns on FieldError {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldError value)  $default,){
final _that = this;
switch (_that) {
case _FieldError():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldError value)?  $default,){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String field,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.field,_that.code);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String field,  String code)  $default,) {final _that = this;
switch (_that) {
case _FieldError():
return $default(_that.field,_that.code);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String field,  String code)?  $default,) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.field,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FieldError extends FieldError {
  const _FieldError({required this.field, required this.code}): super._();
  factory _FieldError.fromJson(Map<String, dynamic> json) => _$FieldErrorFromJson(json);

@override final  String field;
@override final  String code;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldErrorCopyWith<_FieldError> get copyWith => __$FieldErrorCopyWithImpl<_FieldError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldErrorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldError&&(identical(other.field, field) || other.field == field)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,field,code);
}

@override
String toString() {
    return 'FieldError(field: $field, code: $code)';
}


}

/// @nodoc
abstract mixin class _$FieldErrorCopyWith<$Res> implements $FieldErrorCopyWith<$Res> {
  factory _$FieldErrorCopyWith(_FieldError value, $Res Function(_FieldError) _then) = __$FieldErrorCopyWithImpl;
@override @useResult
$Res call({
 String field, String code
});




}
/// @nodoc
class __$FieldErrorCopyWithImpl<$Res>
    implements _$FieldErrorCopyWith<$Res> {
  __$FieldErrorCopyWithImpl(this._self, this._then);

  final _FieldError _self;
  final $Res Function(_FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? code = null,}) {
  return _then(_FieldError(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
