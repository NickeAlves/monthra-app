// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'me.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Me {

 String get id; String get name; String get email; bool get emailVerified; MfaStatus get mfa; MePreferences get preferences; DateTime get createdAt;
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MeCopyWith<Me> get copyWith => _$MeCopyWithImpl<Me>(this as Me, _$identity);

  /// Serializes this Me to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Me;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Me&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.emailVerified, _this.emailVerified) || other.emailVerified == _this.emailVerified)&&(identical(other.mfa, _this.mfa) || other.mfa == _this.mfa)&&(identical(other.preferences, _this.preferences) || other.preferences == _this.preferences)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Me;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.emailVerified,_this.mfa,_this.preferences,_this.createdAt);
}



}

/// @nodoc
abstract mixin class $MeCopyWith<$Res>  {
  factory $MeCopyWith(Me value, $Res Function(Me) _then) = _$MeCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, bool emailVerified, MfaStatus mfa, MePreferences preferences, DateTime createdAt
});


$MfaStatusCopyWith<$Res> get mfa;$MePreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$MeCopyWithImpl<$Res>
    implements $MeCopyWith<$Res> {
  _$MeCopyWithImpl(this._self, this._then);

  final Me _self;
  final $Res Function(Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? emailVerified = null,Object? mfa = null,Object? preferences = null,Object? createdAt = null,}) {
  return _then(Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,mfa: null == mfa ? _self.mfa : mfa // ignore: cast_nullable_to_non_nullable
as MfaStatus,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as MePreferences,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaStatusCopyWith<$Res> get mfa {
  
  return $MfaStatusCopyWith<$Res>(_self.mfa, (value) {
    return _then(_self.copyWith(mfa: value));
  });
}/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MePreferencesCopyWith<$Res> get preferences {
  
  return $MePreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// Adds pattern-matching-related methods to [Me].
extension MePatterns on Me {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Me value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Me value)  $default,){
final _that = this;
switch (_that) {
case _Me():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Me value)?  $default,){
final _that = this;
switch (_that) {
case _Me() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  bool emailVerified,  MfaStatus mfa,  MePreferences preferences,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.emailVerified,_that.mfa,_that.preferences,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  bool emailVerified,  MfaStatus mfa,  MePreferences preferences,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Me():
return $default(_that.id,_that.name,_that.email,_that.emailVerified,_that.mfa,_that.preferences,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  bool emailVerified,  MfaStatus mfa,  MePreferences preferences,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Me() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.emailVerified,_that.mfa,_that.preferences,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Me extends Me {
  const _Me({required this.id, required this.name, required this.email, required this.emailVerified, required this.mfa, required this.preferences, required this.createdAt}): super._();
  factory _Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  bool emailVerified;
@override final  MfaStatus mfa;
@override final  MePreferences preferences;
@override final  DateTime createdAt;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MeCopyWith<_Me> get copyWith => __$MeCopyWithImpl<_Me>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Me&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailVerified, emailVerified) || other.emailVerified == emailVerified)&&(identical(other.mfa, mfa) || other.mfa == mfa)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,emailVerified,mfa,preferences,createdAt);
}



}

/// @nodoc
abstract mixin class _$MeCopyWith<$Res> implements $MeCopyWith<$Res> {
  factory _$MeCopyWith(_Me value, $Res Function(_Me) _then) = __$MeCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, bool emailVerified, MfaStatus mfa, MePreferences preferences, DateTime createdAt
});


@override $MfaStatusCopyWith<$Res> get mfa;@override $MePreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class __$MeCopyWithImpl<$Res>
    implements _$MeCopyWith<$Res> {
  __$MeCopyWithImpl(this._self, this._then);

  final _Me _self;
  final $Res Function(_Me) _then;

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? emailVerified = null,Object? mfa = null,Object? preferences = null,Object? createdAt = null,}) {
  return _then(_Me(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailVerified: null == emailVerified ? _self.emailVerified : emailVerified // ignore: cast_nullable_to_non_nullable
as bool,mfa: null == mfa ? _self.mfa : mfa // ignore: cast_nullable_to_non_nullable
as MfaStatus,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as MePreferences,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MfaStatusCopyWith<$Res> get mfa {
  
  return $MfaStatusCopyWith<$Res>(_self.mfa, (value) {
    return _then(_self.copyWith(mfa: value));
  });
}/// Create a copy of Me
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MePreferencesCopyWith<$Res> get preferences {
  
  return $MePreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}


/// @nodoc
mixin _$MfaStatus {

 bool get enabled; int get recoveryCodesRemaining;
/// Create a copy of MfaStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MfaStatusCopyWith<MfaStatus> get copyWith => _$MfaStatusCopyWithImpl<MfaStatus>(this as MfaStatus, _$identity);

  /// Serializes this MfaStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MfaStatus;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MfaStatus&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled)&&(identical(other.recoveryCodesRemaining, _this.recoveryCodesRemaining) || other.recoveryCodesRemaining == _this.recoveryCodesRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MfaStatus;
  return Object.hash(runtimeType,_this.enabled,_this.recoveryCodesRemaining);
}

@override
String toString() {
  final _this = this as MfaStatus;
  return 'MfaStatus(enabled: ${_this.enabled}, recoveryCodesRemaining: ${_this.recoveryCodesRemaining})';
}


}

/// @nodoc
abstract mixin class $MfaStatusCopyWith<$Res>  {
  factory $MfaStatusCopyWith(MfaStatus value, $Res Function(MfaStatus) _then) = _$MfaStatusCopyWithImpl;
@useResult
$Res call({
 bool enabled, int recoveryCodesRemaining
});




}
/// @nodoc
class _$MfaStatusCopyWithImpl<$Res>
    implements $MfaStatusCopyWith<$Res> {
  _$MfaStatusCopyWithImpl(this._self, this._then);

  final MfaStatus _self;
  final $Res Function(MfaStatus) _then;

/// Create a copy of MfaStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? recoveryCodesRemaining = null,}) {
  return _then(MfaStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,recoveryCodesRemaining: null == recoveryCodesRemaining ? _self.recoveryCodesRemaining : recoveryCodesRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MfaStatus].
extension MfaStatusPatterns on MfaStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MfaStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MfaStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MfaStatus value)  $default,){
final _that = this;
switch (_that) {
case _MfaStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MfaStatus value)?  $default,){
final _that = this;
switch (_that) {
case _MfaStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  int recoveryCodesRemaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MfaStatus() when $default != null:
return $default(_that.enabled,_that.recoveryCodesRemaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  int recoveryCodesRemaining)  $default,) {final _that = this;
switch (_that) {
case _MfaStatus():
return $default(_that.enabled,_that.recoveryCodesRemaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  int recoveryCodesRemaining)?  $default,) {final _that = this;
switch (_that) {
case _MfaStatus() when $default != null:
return $default(_that.enabled,_that.recoveryCodesRemaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MfaStatus extends MfaStatus {
  const _MfaStatus({required this.enabled, required this.recoveryCodesRemaining}): super._();
  factory _MfaStatus.fromJson(Map<String, dynamic> json) => _$MfaStatusFromJson(json);

@override final  bool enabled;
@override final  int recoveryCodesRemaining;

/// Create a copy of MfaStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MfaStatusCopyWith<_MfaStatus> get copyWith => __$MfaStatusCopyWithImpl<_MfaStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MfaStatusToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MfaStatus&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.recoveryCodesRemaining, recoveryCodesRemaining) || other.recoveryCodesRemaining == recoveryCodesRemaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,enabled,recoveryCodesRemaining);
}

@override
String toString() {
    return 'MfaStatus(enabled: $enabled, recoveryCodesRemaining: $recoveryCodesRemaining)';
}


}

/// @nodoc
abstract mixin class _$MfaStatusCopyWith<$Res> implements $MfaStatusCopyWith<$Res> {
  factory _$MfaStatusCopyWith(_MfaStatus value, $Res Function(_MfaStatus) _then) = __$MfaStatusCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, int recoveryCodesRemaining
});




}
/// @nodoc
class __$MfaStatusCopyWithImpl<$Res>
    implements _$MfaStatusCopyWith<$Res> {
  __$MfaStatusCopyWithImpl(this._self, this._then);

  final _MfaStatus _self;
  final $Res Function(_MfaStatus) _then;

/// Create a copy of MfaStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? recoveryCodesRemaining = null,}) {
  return _then(_MfaStatus(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,recoveryCodesRemaining: null == recoveryCodesRemaining ? _self.recoveryCodesRemaining : recoveryCodesRemaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$MePreferences {

 String get locale; String get theme; String get currency; bool get budgetAlerts;
/// Create a copy of MePreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MePreferencesCopyWith<MePreferences> get copyWith => _$MePreferencesCopyWithImpl<MePreferences>(this as MePreferences, _$identity);

  /// Serializes this MePreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MePreferences;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MePreferences&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.theme, _this.theme) || other.theme == _this.theme)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.budgetAlerts, _this.budgetAlerts) || other.budgetAlerts == _this.budgetAlerts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MePreferences;
  return Object.hash(runtimeType,_this.locale,_this.theme,_this.currency,_this.budgetAlerts);
}

@override
String toString() {
  final _this = this as MePreferences;
  return 'MePreferences(locale: ${_this.locale}, theme: ${_this.theme}, currency: ${_this.currency}, budgetAlerts: ${_this.budgetAlerts})';
}


}

/// @nodoc
abstract mixin class $MePreferencesCopyWith<$Res>  {
  factory $MePreferencesCopyWith(MePreferences value, $Res Function(MePreferences) _then) = _$MePreferencesCopyWithImpl;
@useResult
$Res call({
 String locale, String theme, String currency, bool budgetAlerts
});




}
/// @nodoc
class _$MePreferencesCopyWithImpl<$Res>
    implements $MePreferencesCopyWith<$Res> {
  _$MePreferencesCopyWithImpl(this._self, this._then);

  final MePreferences _self;
  final $Res Function(MePreferences) _then;

/// Create a copy of MePreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locale = null,Object? theme = null,Object? currency = null,Object? budgetAlerts = null,}) {
  return _then(MePreferences(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,budgetAlerts: null == budgetAlerts ? _self.budgetAlerts : budgetAlerts // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MePreferences].
extension MePreferencesPatterns on MePreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MePreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MePreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MePreferences value)  $default,){
final _that = this;
switch (_that) {
case _MePreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MePreferences value)?  $default,){
final _that = this;
switch (_that) {
case _MePreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String locale,  String theme,  String currency,  bool budgetAlerts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MePreferences() when $default != null:
return $default(_that.locale,_that.theme,_that.currency,_that.budgetAlerts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String locale,  String theme,  String currency,  bool budgetAlerts)  $default,) {final _that = this;
switch (_that) {
case _MePreferences():
return $default(_that.locale,_that.theme,_that.currency,_that.budgetAlerts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String locale,  String theme,  String currency,  bool budgetAlerts)?  $default,) {final _that = this;
switch (_that) {
case _MePreferences() when $default != null:
return $default(_that.locale,_that.theme,_that.currency,_that.budgetAlerts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MePreferences extends MePreferences {
  const _MePreferences({required this.locale, required this.theme, required this.currency, required this.budgetAlerts}): super._();
  factory _MePreferences.fromJson(Map<String, dynamic> json) => _$MePreferencesFromJson(json);

@override final  String locale;
@override final  String theme;
@override final  String currency;
@override final  bool budgetAlerts;

/// Create a copy of MePreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MePreferencesCopyWith<_MePreferences> get copyWith => __$MePreferencesCopyWithImpl<_MePreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MePreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MePreferences&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.budgetAlerts, budgetAlerts) || other.budgetAlerts == budgetAlerts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,locale,theme,currency,budgetAlerts);
}

@override
String toString() {
    return 'MePreferences(locale: $locale, theme: $theme, currency: $currency, budgetAlerts: $budgetAlerts)';
}


}

/// @nodoc
abstract mixin class _$MePreferencesCopyWith<$Res> implements $MePreferencesCopyWith<$Res> {
  factory _$MePreferencesCopyWith(_MePreferences value, $Res Function(_MePreferences) _then) = __$MePreferencesCopyWithImpl;
@override @useResult
$Res call({
 String locale, String theme, String currency, bool budgetAlerts
});




}
/// @nodoc
class __$MePreferencesCopyWithImpl<$Res>
    implements _$MePreferencesCopyWith<$Res> {
  __$MePreferencesCopyWithImpl(this._self, this._then);

  final _MePreferences _self;
  final $Res Function(_MePreferences) _then;

/// Create a copy of MePreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locale = null,Object? theme = null,Object? currency = null,Object? budgetAlerts = null,}) {
  return _then(_MePreferences(
locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,budgetAlerts: null == budgetAlerts ? _self.budgetAlerts : budgetAlerts // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
