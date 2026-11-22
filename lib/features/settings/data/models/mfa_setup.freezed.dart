// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mfa_setup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MfaSetup {

/// Base32.
 String get secret;/// `otpauth://totp/...`.
 String get otpauthUri;/// Seconds left to confirm it with a first code (900).
 int get expiresIn;
/// Create a copy of MfaSetup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaSetupCopyWith<MfaSetup> get copyWith => _$MfaSetupCopyWithImpl<MfaSetup>(this as MfaSetup, _$identity);

  /// Serializes this MfaSetup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaSetup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaSetup&&(identical(other.secret, _this.secret) || other.secret == _this.secret)&&(identical(other.otpauthUri, _this.otpauthUri) || other.otpauthUri == _this.otpauthUri)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaSetup;
  return Object.hash(runtimeType,_this.secret,_this.otpauthUri,_this.expiresIn);
}



}

/// @nodoc
abstract mixin class $MfaSetupCopyWith<$Res>  {
  factory $MfaSetupCopyWith(MfaSetup value, $Res Function(MfaSetup) _then) = _$MfaSetupCopyWithImpl;
@useResult
$Res call({
 String secret, String otpauthUri, int expiresIn
});




}
/// @nodoc
class _$MfaSetupCopyWithImpl<$Res>
    implements $MfaSetupCopyWith<$Res> {
  _$MfaSetupCopyWithImpl(this._self, this._then);

  final MfaSetup _self;
  final $Res Function(MfaSetup) _then;

/// Create a copy of MfaSetup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secret = null,Object? otpauthUri = null,Object? expiresIn = null,}) {
  return _then(MfaSetup(
secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,otpauthUri: null == otpauthUri ? _self.otpauthUri : otpauthUri // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaSetup].
extension MfaSetupPatterns on MfaSetup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaSetup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaSetup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaSetup value)  $default,){
final _that = this;
switch (_that) {
case _MfaSetup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaSetup value)?  $default,){
final _that = this;
switch (_that) {
case _MfaSetup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String secret,  String otpauthUri,  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaSetup() when $default != null:
return $default(_that.secret,_that.otpauthUri,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String secret,  String otpauthUri,  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _MfaSetup():
return $default(_that.secret,_that.otpauthUri,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String secret,  String otpauthUri,  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _MfaSetup() when $default != null:
return $default(_that.secret,_that.otpauthUri,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaSetup extends MfaSetup {
  const _MfaSetup({required this.secret, required this.otpauthUri, required this.expiresIn}): super._();
  factory _MfaSetup.fromJson(Map<String, dynamic> json) => _$MfaSetupFromJson(json);

/// Base32.
@override final  String secret;
/// `otpauth://totp/...`.
@override final  String otpauthUri;
/// Seconds left to confirm it with a first code (900).
@override final  int expiresIn;

/// Create a copy of MfaSetup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaSetupCopyWith<_MfaSetup> get copyWith => __$MfaSetupCopyWithImpl<_MfaSetup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaSetupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaSetup&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.otpauthUri, otpauthUri) || other.otpauthUri == otpauthUri)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,secret,otpauthUri,expiresIn);
}



}

/// @nodoc
abstract mixin class _$MfaSetupCopyWith<$Res> implements $MfaSetupCopyWith<$Res> {
  factory _$MfaSetupCopyWith(_MfaSetup value, $Res Function(_MfaSetup) _then) = __$MfaSetupCopyWithImpl;
@override @useResult
$Res call({
 String secret, String otpauthUri, int expiresIn
});




}
/// @nodoc
class __$MfaSetupCopyWithImpl<$Res>
    implements _$MfaSetupCopyWith<$Res> {
  __$MfaSetupCopyWithImpl(this._self, this._then);

  final _MfaSetup _self;
  final $Res Function(_MfaSetup) _then;

/// Create a copy of MfaSetup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secret = null,Object? otpauthUri = null,Object? expiresIn = null,}) {
  return _then(_MfaSetup(
secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as String,otpauthUri: null == otpauthUri ? _self.otpauthUri : otpauthUri // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
