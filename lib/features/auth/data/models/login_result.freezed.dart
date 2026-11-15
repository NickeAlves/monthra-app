// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MfaChallenge {

/// Single use; it takes 5 codes at most.
 String get mfaToken;/// Seconds left to answer (300).
 int get expiresIn;
/// Create a copy of MfaChallenge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaChallengeCopyWith<MfaChallenge> get copyWith => _$MfaChallengeCopyWithImpl<MfaChallenge>(this as MfaChallenge, _$identity);

  /// Serializes this MfaChallenge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaChallenge;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaChallenge&&(identical(other.mfaToken, _this.mfaToken) || other.mfaToken == _this.mfaToken)&&(identical(other.expiresIn, _this.expiresIn) || other.expiresIn == _this.expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaChallenge;
  return Object.hash(runtimeType,_this.mfaToken,_this.expiresIn);
}



}

/// @nodoc
abstract mixin class $MfaChallengeCopyWith<$Res>  {
  factory $MfaChallengeCopyWith(MfaChallenge value, $Res Function(MfaChallenge) _then) = _$MfaChallengeCopyWithImpl;
@useResult
$Res call({
 String mfaToken, int expiresIn
});




}
/// @nodoc
class _$MfaChallengeCopyWithImpl<$Res>
    implements $MfaChallengeCopyWith<$Res> {
  _$MfaChallengeCopyWithImpl(this._self, this._then);

  final MfaChallenge _self;
  final $Res Function(MfaChallenge) _then;

/// Create a copy of MfaChallenge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mfaToken = null,Object? expiresIn = null,}) {
  return _then(MfaChallenge(
mfaToken: null == mfaToken ? _self.mfaToken : mfaToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaChallenge].
extension MfaChallengePatterns on MfaChallenge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaChallenge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaChallenge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaChallenge value)  $default,){
final _that = this;
switch (_that) {
case _MfaChallenge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaChallenge value)?  $default,){
final _that = this;
switch (_that) {
case _MfaChallenge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mfaToken,  int expiresIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaChallenge() when $default != null:
return $default(_that.mfaToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mfaToken,  int expiresIn)  $default,) {final _that = this;
switch (_that) {
case _MfaChallenge():
return $default(_that.mfaToken,_that.expiresIn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mfaToken,  int expiresIn)?  $default,) {final _that = this;
switch (_that) {
case _MfaChallenge() when $default != null:
return $default(_that.mfaToken,_that.expiresIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaChallenge extends MfaChallenge {
  const _MfaChallenge({required this.mfaToken, required this.expiresIn}): super._();
  factory _MfaChallenge.fromJson(Map<String, dynamic> json) => _$MfaChallengeFromJson(json);

/// Single use; it takes 5 codes at most.
@override final  String mfaToken;
/// Seconds left to answer (300).
@override final  int expiresIn;

/// Create a copy of MfaChallenge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaChallengeCopyWith<_MfaChallenge> get copyWith => __$MfaChallengeCopyWithImpl<_MfaChallenge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaChallengeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaChallenge&&(identical(other.mfaToken, mfaToken) || other.mfaToken == mfaToken)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,mfaToken,expiresIn);
}



}

/// @nodoc
abstract mixin class _$MfaChallengeCopyWith<$Res> implements $MfaChallengeCopyWith<$Res> {
  factory _$MfaChallengeCopyWith(_MfaChallenge value, $Res Function(_MfaChallenge) _then) = __$MfaChallengeCopyWithImpl;
@override @useResult
$Res call({
 String mfaToken, int expiresIn
});




}
/// @nodoc
class __$MfaChallengeCopyWithImpl<$Res>
    implements _$MfaChallengeCopyWith<$Res> {
  __$MfaChallengeCopyWithImpl(this._self, this._then);

  final _MfaChallenge _self;
  final $Res Function(_MfaChallenge) _then;

/// Create a copy of MfaChallenge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mfaToken = null,Object? expiresIn = null,}) {
  return _then(_MfaChallenge(
mfaToken: null == mfaToken ? _self.mfaToken : mfaToken // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
