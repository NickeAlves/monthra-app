// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'csrf_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CsrfToken {

 String get csrfToken;
/// Create a copy of CsrfToken
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CsrfTokenCopyWith<CsrfToken> get copyWith => _$CsrfTokenCopyWithImpl<CsrfToken>(this as CsrfToken, _$identity);

  /// Serializes this CsrfToken to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CsrfToken;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CsrfToken&&(identical(other.csrfToken, _this.csrfToken) || other.csrfToken == _this.csrfToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CsrfToken;
  return Object.hash(runtimeType,_this.csrfToken);
}

@override
String toString() {
  final _this = this as CsrfToken;
  return 'CsrfToken(csrfToken: ${_this.csrfToken})';
}


}

/// @nodoc
abstract mixin class $CsrfTokenCopyWith<$Res>  {
  factory $CsrfTokenCopyWith(CsrfToken value, $Res Function(CsrfToken) _then) = _$CsrfTokenCopyWithImpl;
@useResult
$Res call({
 String csrfToken
});




}
/// @nodoc
class _$CsrfTokenCopyWithImpl<$Res>
    implements $CsrfTokenCopyWith<$Res> {
  _$CsrfTokenCopyWithImpl(this._self, this._then);

  final CsrfToken _self;
  final $Res Function(CsrfToken) _then;

/// Create a copy of CsrfToken
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? csrfToken = null,}) {
  return _then(CsrfToken(
csrfToken: null == csrfToken ? _self.csrfToken : csrfToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CsrfToken].
extension CsrfTokenPatterns on CsrfToken {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CsrfToken value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CsrfToken() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CsrfToken value)  $default,){
final _that = this;
switch (_that) {
case _CsrfToken():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CsrfToken value)?  $default,){
final _that = this;
switch (_that) {
case _CsrfToken() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String csrfToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CsrfToken() when $default != null:
return $default(_that.csrfToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String csrfToken)  $default,) {final _that = this;
switch (_that) {
case _CsrfToken():
return $default(_that.csrfToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String csrfToken)?  $default,) {final _that = this;
switch (_that) {
case _CsrfToken() when $default != null:
return $default(_that.csrfToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CsrfToken implements CsrfToken {
  const _CsrfToken({required this.csrfToken});
  factory _CsrfToken.fromJson(Map<String, dynamic> json) => _$CsrfTokenFromJson(json);

@override final  String csrfToken;

/// Create a copy of CsrfToken
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CsrfTokenCopyWith<_CsrfToken> get copyWith => __$CsrfTokenCopyWithImpl<_CsrfToken>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CsrfTokenToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CsrfToken&&(identical(other.csrfToken, csrfToken) || other.csrfToken == csrfToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,csrfToken);
}

@override
String toString() {
    return 'CsrfToken(csrfToken: $csrfToken)';
}


}

/// @nodoc
abstract mixin class _$CsrfTokenCopyWith<$Res> implements $CsrfTokenCopyWith<$Res> {
  factory _$CsrfTokenCopyWith(_CsrfToken value, $Res Function(_CsrfToken) _then) = __$CsrfTokenCopyWithImpl;
@override @useResult
$Res call({
 String csrfToken
});




}
/// @nodoc
class __$CsrfTokenCopyWithImpl<$Res>
    implements _$CsrfTokenCopyWith<$Res> {
  __$CsrfTokenCopyWithImpl(this._self, this._then);

  final _CsrfToken _self;
  final $Res Function(_CsrfToken) _then;

/// Create a copy of CsrfToken
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? csrfToken = null,}) {
  return _then(_CsrfToken(
csrfToken: null == csrfToken ? _self.csrfToken : csrfToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
