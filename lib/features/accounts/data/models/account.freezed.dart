// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardSettings {

 int get closingDay; int get dueDay; int? get limit;
/// Create a copy of CardSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardSettingsCopyWith<CardSettings> get copyWith => _$CardSettingsCopyWithImpl<CardSettings>(this as CardSettings, _$identity);

  /// Serializes this CardSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardSettings&&(identical(other.closingDay, _this.closingDay) || other.closingDay == _this.closingDay)&&(identical(other.dueDay, _this.dueDay) || other.dueDay == _this.dueDay)&&(identical(other.limit, _this.limit) || other.limit == _this.limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardSettings;
  return Object.hash(runtimeType,_this.closingDay,_this.dueDay,_this.limit);
}

@override
String toString() {
  final _this = this as CardSettings;
  return 'CardSettings(closingDay: ${_this.closingDay}, dueDay: ${_this.dueDay}, limit: ${_this.limit})';
}


}

/// @nodoc
abstract mixin class $CardSettingsCopyWith<$Res>  {
  factory $CardSettingsCopyWith(CardSettings value, $Res Function(CardSettings) _then) = _$CardSettingsCopyWithImpl;
@useResult
$Res call({
 int closingDay, int dueDay, int? limit
});




}
/// @nodoc
class _$CardSettingsCopyWithImpl<$Res>
    implements $CardSettingsCopyWith<$Res> {
  _$CardSettingsCopyWithImpl(this._self, this._then);

  final CardSettings _self;
  final $Res Function(CardSettings) _then;

/// Create a copy of CardSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? closingDay = null,Object? dueDay = null,Object? limit = freezed,}) {
  return _then(CardSettings(
closingDay: null == closingDay ? _self.closingDay : closingDay // ignore: cast_nullable_to_non_nullable
as int,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardSettings].
extension CardSettingsPatterns on CardSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardSettings value)  $default,){
final _that = this;
switch (_that) {
case _CardSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardSettings value)?  $default,){
final _that = this;
switch (_that) {
case _CardSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int closingDay,  int dueDay,  int? limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardSettings() when $default != null:
return $default(_that.closingDay,_that.dueDay,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int closingDay,  int dueDay,  int? limit)  $default,) {final _that = this;
switch (_that) {
case _CardSettings():
return $default(_that.closingDay,_that.dueDay,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int closingDay,  int dueDay,  int? limit)?  $default,) {final _that = this;
switch (_that) {
case _CardSettings() when $default != null:
return $default(_that.closingDay,_that.dueDay,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardSettings implements CardSettings {
  const _CardSettings({required this.closingDay, required this.dueDay, this.limit});
  factory _CardSettings.fromJson(Map<String, dynamic> json) => _$CardSettingsFromJson(json);

@override final  int closingDay;
@override final  int dueDay;
@override final  int? limit;

/// Create a copy of CardSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardSettingsCopyWith<_CardSettings> get copyWith => __$CardSettingsCopyWithImpl<_CardSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardSettings&&(identical(other.closingDay, closingDay) || other.closingDay == closingDay)&&(identical(other.dueDay, dueDay) || other.dueDay == dueDay)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,closingDay,dueDay,limit);
}

@override
String toString() {
    return 'CardSettings(closingDay: $closingDay, dueDay: $dueDay, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$CardSettingsCopyWith<$Res> implements $CardSettingsCopyWith<$Res> {
  factory _$CardSettingsCopyWith(_CardSettings value, $Res Function(_CardSettings) _then) = __$CardSettingsCopyWithImpl;
@override @useResult
$Res call({
 int closingDay, int dueDay, int? limit
});




}
/// @nodoc
class __$CardSettingsCopyWithImpl<$Res>
    implements _$CardSettingsCopyWith<$Res> {
  __$CardSettingsCopyWithImpl(this._self, this._then);

  final _CardSettings _self;
  final $Res Function(_CardSettings) _then;

/// Create a copy of CardSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? closingDay = null,Object? dueDay = null,Object? limit = freezed,}) {
  return _then(_CardSettings(
closingDay: null == closingDay ? _self.closingDay : closingDay // ignore: cast_nullable_to_non_nullable
as int,dueDay: null == dueDay ? _self.dueDay : dueDay // ignore: cast_nullable_to_non_nullable
as int,limit: freezed == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Account {

 String get id; String get name;@JsonKey(unknownEnumValue: AccountType.unknown) AccountType get type;@CurrencyConverter() Currency get currency;/// The balance before any transaction (a card's debt below zero).
 int get initialBalance;/// The initial balance plus the transactions up to `asOf`.
 int get balance;/// The initial balance plus every transaction, future ones included.
 int get projectedBalance;/// A credit card's cycle; null for every other type.
 CardSettings? get card;@JsonKey(unknownEnumValue: AccountSource.unknown) AccountSource get source; bool get archived;
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountCopyWith<Account> get copyWith => _$AccountCopyWithImpl<Account>(this as Account, _$identity);

  /// Serializes this Account to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Account;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Account&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.initialBalance, _this.initialBalance) || other.initialBalance == _this.initialBalance)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.projectedBalance, _this.projectedBalance) || other.projectedBalance == _this.projectedBalance)&&(identical(other.card, _this.card) || other.card == _this.card)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.archived, _this.archived) || other.archived == _this.archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Account;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.currency,_this.initialBalance,_this.balance,_this.projectedBalance,_this.card,_this.source,_this.archived);
}



}

/// @nodoc
abstract mixin class $AccountCopyWith<$Res>  {
  factory $AccountCopyWith(Account value, $Res Function(Account) _then) = _$AccountCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: AccountType.unknown) AccountType type,@CurrencyConverter() Currency currency, int initialBalance, int balance, int projectedBalance, CardSettings? card,@JsonKey(unknownEnumValue: AccountSource.unknown) AccountSource source, bool archived
});


$CardSettingsCopyWith<$Res>? get card;

}
/// @nodoc
class _$AccountCopyWithImpl<$Res>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._self, this._then);

  final Account _self;
  final $Res Function(Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? currency = null,Object? initialBalance = null,Object? balance = null,Object? projectedBalance = null,Object? card = freezed,Object? source = null,Object? archived = null,}) {
  return _then(Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,projectedBalance: null == projectedBalance ? _self.projectedBalance : projectedBalance // ignore: cast_nullable_to_non_nullable
as int,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as CardSettings?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AccountSource,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardSettingsCopyWith<$Res>? get card {
    if (_self.card == null) {
    return null;
  }

  return $CardSettingsCopyWith<$Res>(_self.card!, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}


/// Adds pattern-matching-related methods to [Account].
extension AccountPatterns on Account {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Account value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Account value)  $default,){
final _that = this;
switch (_that) {
case _Account():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Account value)?  $default,){
final _that = this;
switch (_that) {
case _Account() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: AccountType.unknown)  AccountType type, @CurrencyConverter()  Currency currency,  int initialBalance,  int balance,  int projectedBalance,  CardSettings? card, @JsonKey(unknownEnumValue: AccountSource.unknown)  AccountSource source,  bool archived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.currency,_that.initialBalance,_that.balance,_that.projectedBalance,_that.card,_that.source,_that.archived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: AccountType.unknown)  AccountType type, @CurrencyConverter()  Currency currency,  int initialBalance,  int balance,  int projectedBalance,  CardSettings? card, @JsonKey(unknownEnumValue: AccountSource.unknown)  AccountSource source,  bool archived)  $default,) {final _that = this;
switch (_that) {
case _Account():
return $default(_that.id,_that.name,_that.type,_that.currency,_that.initialBalance,_that.balance,_that.projectedBalance,_that.card,_that.source,_that.archived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(unknownEnumValue: AccountType.unknown)  AccountType type, @CurrencyConverter()  Currency currency,  int initialBalance,  int balance,  int projectedBalance,  CardSettings? card, @JsonKey(unknownEnumValue: AccountSource.unknown)  AccountSource source,  bool archived)?  $default,) {final _that = this;
switch (_that) {
case _Account() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.currency,_that.initialBalance,_that.balance,_that.projectedBalance,_that.card,_that.source,_that.archived);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Account extends Account {
  const _Account({required this.id, required this.name, @JsonKey(unknownEnumValue: AccountType.unknown) required this.type, @CurrencyConverter() required this.currency, required this.initialBalance, required this.balance, required this.projectedBalance, required this.card, @JsonKey(unknownEnumValue: AccountSource.unknown) required this.source, required this.archived}): super._();
  factory _Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(unknownEnumValue: AccountType.unknown) final  AccountType type;
@override@CurrencyConverter() final  Currency currency;
/// The balance before any transaction (a card's debt below zero).
@override final  int initialBalance;
/// The initial balance plus the transactions up to `asOf`.
@override final  int balance;
/// The initial balance plus every transaction, future ones included.
@override final  int projectedBalance;
/// A credit card's cycle; null for every other type.
@override final  CardSettings? card;
@override@JsonKey(unknownEnumValue: AccountSource.unknown) final  AccountSource source;
@override final  bool archived;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountCopyWith<_Account> get copyWith => __$AccountCopyWithImpl<_Account>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Account&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.initialBalance, initialBalance) || other.initialBalance == initialBalance)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.projectedBalance, projectedBalance) || other.projectedBalance == projectedBalance)&&(identical(other.card, card) || other.card == card)&&(identical(other.source, source) || other.source == source)&&(identical(other.archived, archived) || other.archived == archived));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,currency,initialBalance,balance,projectedBalance,card,source,archived);
}



}

/// @nodoc
abstract mixin class _$AccountCopyWith<$Res> implements $AccountCopyWith<$Res> {
  factory _$AccountCopyWith(_Account value, $Res Function(_Account) _then) = __$AccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: AccountType.unknown) AccountType type,@CurrencyConverter() Currency currency, int initialBalance, int balance, int projectedBalance, CardSettings? card,@JsonKey(unknownEnumValue: AccountSource.unknown) AccountSource source, bool archived
});


@override $CardSettingsCopyWith<$Res>? get card;

}
/// @nodoc
class __$AccountCopyWithImpl<$Res>
    implements _$AccountCopyWith<$Res> {
  __$AccountCopyWithImpl(this._self, this._then);

  final _Account _self;
  final $Res Function(_Account) _then;

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? currency = null,Object? initialBalance = null,Object? balance = null,Object? projectedBalance = null,Object? card = freezed,Object? source = null,Object? archived = null,}) {
  return _then(_Account(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AccountType,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,initialBalance: null == initialBalance ? _self.initialBalance : initialBalance // ignore: cast_nullable_to_non_nullable
as int,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,projectedBalance: null == projectedBalance ? _self.projectedBalance : projectedBalance // ignore: cast_nullable_to_non_nullable
as int,card: freezed == card ? _self.card : card // ignore: cast_nullable_to_non_nullable
as CardSettings?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as AccountSource,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Account
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardSettingsCopyWith<$Res>? get card {
    if (_self.card == null) {
    return null;
  }

  return $CardSettingsCopyWith<$Res>(_self.card!, (value) {
    return _then(_self.copyWith(card: value));
  });
}
}

// dart format on
