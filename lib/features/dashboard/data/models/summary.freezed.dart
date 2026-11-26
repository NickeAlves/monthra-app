// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSummary {

@YearMonthConverter() YearMonth get month;/// The day the balances count up to: the month's last day, or the
/// reader's today when that comes first.
@CivilDateConverter() DateTime get asOf;/// One per currency of the caller's accounts, alphabetically.
 List<CurrencySummary> get currencies;/// Every account, archived ones included, oldest first.
 List<AccountBalance> get accounts;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);

  /// Serializes this DashboardSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DashboardSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.asOf, _this.asOf) || other.asOf == _this.asOf)&&const DeepCollectionEquality().equals(other.currencies, _this.currencies)&&const DeepCollectionEquality().equals(other.accounts, _this.accounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DashboardSummary;
  return Object.hash(runtimeType,_this.month,_this.asOf,const DeepCollectionEquality().hash(_this.currencies),const DeepCollectionEquality().hash(_this.accounts));
}

@override
String toString() {
  final _this = this as DashboardSummary;
  return 'DashboardSummary(month: ${_this.month}, asOf: ${_this.asOf}, currencies: ${_this.currencies}, accounts: ${_this.accounts})';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
@YearMonthConverter() YearMonth month,@CivilDateConverter() DateTime asOf, List<CurrencySummary> currencies, List<AccountBalance> accounts
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? asOf = null,Object? currencies = null,Object? accounts = null,}) {
  return _then(DashboardSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,currencies: null == currencies ? _self.currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencySummary>,accounts: null == accounts ? _self.accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountBalance>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime asOf,  List<CurrencySummary> currencies,  List<AccountBalance> accounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.month,_that.asOf,_that.currencies,_that.accounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime asOf,  List<CurrencySummary> currencies,  List<AccountBalance> accounts)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.month,_that.asOf,_that.currencies,_that.accounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime asOf,  List<CurrencySummary> currencies,  List<AccountBalance> accounts)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.month,_that.asOf,_that.currencies,_that.accounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DashboardSummary extends DashboardSummary {
  const _DashboardSummary({@YearMonthConverter() required this.month, @CivilDateConverter() required this.asOf, required  List<CurrencySummary> currencies, required  List<AccountBalance> accounts}): _currencies = currencies,_accounts = accounts,super._();
  factory _DashboardSummary.fromJson(Map<String, dynamic> json) => _$DashboardSummaryFromJson(json);

@override@YearMonthConverter() final  YearMonth month;
/// The day the balances count up to: the month's last day, or the
/// reader's today when that comes first.
@override@CivilDateConverter() final  DateTime asOf;
/// One per currency of the caller's accounts, alphabetically.
 final  List<CurrencySummary> _currencies;
/// One per currency of the caller's accounts, alphabetically.
@override List<CurrencySummary> get currencies {
  if (_currencies is EqualUnmodifiableListView) return _currencies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currencies);
}

/// Every account, archived ones included, oldest first.
 final  List<AccountBalance> _accounts;
/// Every account, archived ones included, oldest first.
@override List<AccountBalance> get accounts {
  if (_accounts is EqualUnmodifiableListView) return _accounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accounts);
}


/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.month, month) || other.month == month)&&(identical(other.asOf, asOf) || other.asOf == asOf)&&const DeepCollectionEquality().equals(other.currencies, _currencies)&&const DeepCollectionEquality().equals(other.accounts, _accounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,month,asOf,const DeepCollectionEquality().hash(_currencies),const DeepCollectionEquality().hash(_accounts));
}

@override
String toString() {
    return 'DashboardSummary(month: $month, asOf: $asOf, currencies: $currencies, accounts: $accounts)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
@YearMonthConverter() YearMonth month,@CivilDateConverter() DateTime asOf, List<CurrencySummary> currencies, List<AccountBalance> accounts
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? asOf = null,Object? currencies = null,Object? accounts = null,}) {
  return _then(_DashboardSummary(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,currencies: null == currencies ? _self._currencies : currencies // ignore: cast_nullable_to_non_nullable
as List<CurrencySummary>,accounts: null == accounts ? _self._accounts : accounts // ignore: cast_nullable_to_non_nullable
as List<AccountBalance>,
  ));
}


}


/// @nodoc
mixin _$CurrencySummary {

@CurrencyConverter() Currency get currency;/// The whole month, the days still to come included; transfers are
/// neither income nor expense.
 int get income; int get expense;/// `income - expense`.
 int get net;/// What the recurrences are still to create in the month.
 ScheduledFlows get scheduled;/// The net worth on `asOf` (a card's debt counts against it).
 int get balance;/// The largest first.
 List<CategoryTotal> get expensesByCategory; List<CategoryTotal> get incomeByCategory;/// The 12 months up to the month, oldest first.
 List<SummaryPoint> get history;
/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurrencySummaryCopyWith<CurrencySummary> get copyWith => _$CurrencySummaryCopyWithImpl<CurrencySummary>(this as CurrencySummary, _$identity);

  /// Serializes this CurrencySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CurrencySummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurrencySummary&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&(identical(other.net, _this.net) || other.net == _this.net)&&(identical(other.scheduled, _this.scheduled) || other.scheduled == _this.scheduled)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&const DeepCollectionEquality().equals(other.expensesByCategory, _this.expensesByCategory)&&const DeepCollectionEquality().equals(other.incomeByCategory, _this.incomeByCategory)&&const DeepCollectionEquality().equals(other.history, _this.history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CurrencySummary;
  return Object.hash(runtimeType,_this.currency,_this.income,_this.expense,_this.net,_this.scheduled,_this.balance,const DeepCollectionEquality().hash(_this.expensesByCategory),const DeepCollectionEquality().hash(_this.incomeByCategory),const DeepCollectionEquality().hash(_this.history));
}

@override
String toString() {
  final _this = this as CurrencySummary;
  return 'CurrencySummary(currency: ${_this.currency}, income: ${_this.income}, expense: ${_this.expense}, net: ${_this.net}, scheduled: ${_this.scheduled}, balance: ${_this.balance}, expensesByCategory: ${_this.expensesByCategory}, incomeByCategory: ${_this.incomeByCategory}, history: ${_this.history})';
}


}

/// @nodoc
abstract mixin class $CurrencySummaryCopyWith<$Res>  {
  factory $CurrencySummaryCopyWith(CurrencySummary value, $Res Function(CurrencySummary) _then) = _$CurrencySummaryCopyWithImpl;
@useResult
$Res call({
@CurrencyConverter() Currency currency, int income, int expense, int net, ScheduledFlows scheduled, int balance, List<CategoryTotal> expensesByCategory, List<CategoryTotal> incomeByCategory, List<SummaryPoint> history
});


$ScheduledFlowsCopyWith<$Res> get scheduled;

}
/// @nodoc
class _$CurrencySummaryCopyWithImpl<$Res>
    implements $CurrencySummaryCopyWith<$Res> {
  _$CurrencySummaryCopyWithImpl(this._self, this._then);

  final CurrencySummary _self;
  final $Res Function(CurrencySummary) _then;

/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currency = null,Object? income = null,Object? expense = null,Object? net = null,Object? scheduled = null,Object? balance = null,Object? expensesByCategory = null,Object? incomeByCategory = null,Object? history = null,}) {
  return _then(CurrencySummary(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as ScheduledFlows,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,expensesByCategory: null == expensesByCategory ? _self.expensesByCategory : expensesByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryTotal>,incomeByCategory: null == incomeByCategory ? _self.incomeByCategory : incomeByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryTotal>,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<SummaryPoint>,
  ));
}
/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduledFlowsCopyWith<$Res> get scheduled {
  
  return $ScheduledFlowsCopyWith<$Res>(_self.scheduled, (value) {
    return _then(_self.copyWith(scheduled: value));
  });
}
}


/// Adds pattern-matching-related methods to [CurrencySummary].
extension CurrencySummaryPatterns on CurrencySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurrencySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurrencySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurrencySummary value)  $default,){
final _that = this;
switch (_that) {
case _CurrencySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurrencySummary value)?  $default,){
final _that = this;
switch (_that) {
case _CurrencySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@CurrencyConverter()  Currency currency,  int income,  int expense,  int net,  ScheduledFlows scheduled,  int balance,  List<CategoryTotal> expensesByCategory,  List<CategoryTotal> incomeByCategory,  List<SummaryPoint> history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurrencySummary() when $default != null:
return $default(_that.currency,_that.income,_that.expense,_that.net,_that.scheduled,_that.balance,_that.expensesByCategory,_that.incomeByCategory,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@CurrencyConverter()  Currency currency,  int income,  int expense,  int net,  ScheduledFlows scheduled,  int balance,  List<CategoryTotal> expensesByCategory,  List<CategoryTotal> incomeByCategory,  List<SummaryPoint> history)  $default,) {final _that = this;
switch (_that) {
case _CurrencySummary():
return $default(_that.currency,_that.income,_that.expense,_that.net,_that.scheduled,_that.balance,_that.expensesByCategory,_that.incomeByCategory,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@CurrencyConverter()  Currency currency,  int income,  int expense,  int net,  ScheduledFlows scheduled,  int balance,  List<CategoryTotal> expensesByCategory,  List<CategoryTotal> incomeByCategory,  List<SummaryPoint> history)?  $default,) {final _that = this;
switch (_that) {
case _CurrencySummary() when $default != null:
return $default(_that.currency,_that.income,_that.expense,_that.net,_that.scheduled,_that.balance,_that.expensesByCategory,_that.incomeByCategory,_that.history);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurrencySummary extends CurrencySummary {
  const _CurrencySummary({@CurrencyConverter() required this.currency, required this.income, required this.expense, required this.net, required this.scheduled, required this.balance, required  List<CategoryTotal> expensesByCategory, required  List<CategoryTotal> incomeByCategory, required  List<SummaryPoint> history}): _expensesByCategory = expensesByCategory,_incomeByCategory = incomeByCategory,_history = history,super._();
  factory _CurrencySummary.fromJson(Map<String, dynamic> json) => _$CurrencySummaryFromJson(json);

@override@CurrencyConverter() final  Currency currency;
/// The whole month, the days still to come included; transfers are
/// neither income nor expense.
@override final  int income;
@override final  int expense;
/// `income - expense`.
@override final  int net;
/// What the recurrences are still to create in the month.
@override final  ScheduledFlows scheduled;
/// The net worth on `asOf` (a card's debt counts against it).
@override final  int balance;
/// The largest first.
 final  List<CategoryTotal> _expensesByCategory;
/// The largest first.
@override List<CategoryTotal> get expensesByCategory {
  if (_expensesByCategory is EqualUnmodifiableListView) return _expensesByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expensesByCategory);
}

 final  List<CategoryTotal> _incomeByCategory;
@override List<CategoryTotal> get incomeByCategory {
  if (_incomeByCategory is EqualUnmodifiableListView) return _incomeByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_incomeByCategory);
}

/// The 12 months up to the month, oldest first.
 final  List<SummaryPoint> _history;
/// The 12 months up to the month, oldest first.
@override List<SummaryPoint> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}


/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurrencySummaryCopyWith<_CurrencySummary> get copyWith => __$CurrencySummaryCopyWithImpl<_CurrencySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurrencySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurrencySummary&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.net, net) || other.net == net)&&(identical(other.scheduled, scheduled) || other.scheduled == scheduled)&&(identical(other.balance, balance) || other.balance == balance)&&const DeepCollectionEquality().equals(other.expensesByCategory, _expensesByCategory)&&const DeepCollectionEquality().equals(other.incomeByCategory, _incomeByCategory)&&const DeepCollectionEquality().equals(other.history, _history));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,currency,income,expense,net,scheduled,balance,const DeepCollectionEquality().hash(_expensesByCategory),const DeepCollectionEquality().hash(_incomeByCategory),const DeepCollectionEquality().hash(_history));
}

@override
String toString() {
    return 'CurrencySummary(currency: $currency, income: $income, expense: $expense, net: $net, scheduled: $scheduled, balance: $balance, expensesByCategory: $expensesByCategory, incomeByCategory: $incomeByCategory, history: $history)';
}


}

/// @nodoc
abstract mixin class _$CurrencySummaryCopyWith<$Res> implements $CurrencySummaryCopyWith<$Res> {
  factory _$CurrencySummaryCopyWith(_CurrencySummary value, $Res Function(_CurrencySummary) _then) = __$CurrencySummaryCopyWithImpl;
@override @useResult
$Res call({
@CurrencyConverter() Currency currency, int income, int expense, int net, ScheduledFlows scheduled, int balance, List<CategoryTotal> expensesByCategory, List<CategoryTotal> incomeByCategory, List<SummaryPoint> history
});


@override $ScheduledFlowsCopyWith<$Res> get scheduled;

}
/// @nodoc
class __$CurrencySummaryCopyWithImpl<$Res>
    implements _$CurrencySummaryCopyWith<$Res> {
  __$CurrencySummaryCopyWithImpl(this._self, this._then);

  final _CurrencySummary _self;
  final $Res Function(_CurrencySummary) _then;

/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currency = null,Object? income = null,Object? expense = null,Object? net = null,Object? scheduled = null,Object? balance = null,Object? expensesByCategory = null,Object? incomeByCategory = null,Object? history = null,}) {
  return _then(_CurrencySummary(
currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,net: null == net ? _self.net : net // ignore: cast_nullable_to_non_nullable
as int,scheduled: null == scheduled ? _self.scheduled : scheduled // ignore: cast_nullable_to_non_nullable
as ScheduledFlows,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,expensesByCategory: null == expensesByCategory ? _self._expensesByCategory : expensesByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryTotal>,incomeByCategory: null == incomeByCategory ? _self._incomeByCategory : incomeByCategory // ignore: cast_nullable_to_non_nullable
as List<CategoryTotal>,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<SummaryPoint>,
  ));
}

/// Create a copy of CurrencySummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScheduledFlowsCopyWith<$Res> get scheduled {
  
  return $ScheduledFlowsCopyWith<$Res>(_self.scheduled, (value) {
    return _then(_self.copyWith(scheduled: value));
  });
}
}


/// @nodoc
mixin _$ScheduledFlows {

 int get income; int get expense;
/// Create a copy of ScheduledFlows
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScheduledFlowsCopyWith<ScheduledFlows> get copyWith => _$ScheduledFlowsCopyWithImpl<ScheduledFlows>(this as ScheduledFlows, _$identity);

  /// Serializes this ScheduledFlows to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ScheduledFlows;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScheduledFlows&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ScheduledFlows;
  return Object.hash(runtimeType,_this.income,_this.expense);
}

@override
String toString() {
  final _this = this as ScheduledFlows;
  return 'ScheduledFlows(income: ${_this.income}, expense: ${_this.expense})';
}


}

/// @nodoc
abstract mixin class $ScheduledFlowsCopyWith<$Res>  {
  factory $ScheduledFlowsCopyWith(ScheduledFlows value, $Res Function(ScheduledFlows) _then) = _$ScheduledFlowsCopyWithImpl;
@useResult
$Res call({
 int income, int expense
});




}
/// @nodoc
class _$ScheduledFlowsCopyWithImpl<$Res>
    implements $ScheduledFlowsCopyWith<$Res> {
  _$ScheduledFlowsCopyWithImpl(this._self, this._then);

  final ScheduledFlows _self;
  final $Res Function(ScheduledFlows) _then;

/// Create a copy of ScheduledFlows
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? income = null,Object? expense = null,}) {
  return _then(ScheduledFlows(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ScheduledFlows].
extension ScheduledFlowsPatterns on ScheduledFlows {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScheduledFlows value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScheduledFlows() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScheduledFlows value)  $default,){
final _that = this;
switch (_that) {
case _ScheduledFlows():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScheduledFlows value)?  $default,){
final _that = this;
switch (_that) {
case _ScheduledFlows() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int income,  int expense)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScheduledFlows() when $default != null:
return $default(_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int income,  int expense)  $default,) {final _that = this;
switch (_that) {
case _ScheduledFlows():
return $default(_that.income,_that.expense);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int income,  int expense)?  $default,) {final _that = this;
switch (_that) {
case _ScheduledFlows() when $default != null:
return $default(_that.income,_that.expense);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScheduledFlows extends ScheduledFlows {
  const _ScheduledFlows({required this.income, required this.expense}): super._();
  factory _ScheduledFlows.fromJson(Map<String, dynamic> json) => _$ScheduledFlowsFromJson(json);

@override final  int income;
@override final  int expense;

/// Create a copy of ScheduledFlows
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScheduledFlowsCopyWith<_ScheduledFlows> get copyWith => __$ScheduledFlowsCopyWithImpl<_ScheduledFlows>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScheduledFlowsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScheduledFlows&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,income,expense);
}

@override
String toString() {
    return 'ScheduledFlows(income: $income, expense: $expense)';
}


}

/// @nodoc
abstract mixin class _$ScheduledFlowsCopyWith<$Res> implements $ScheduledFlowsCopyWith<$Res> {
  factory _$ScheduledFlowsCopyWith(_ScheduledFlows value, $Res Function(_ScheduledFlows) _then) = __$ScheduledFlowsCopyWithImpl;
@override @useResult
$Res call({
 int income, int expense
});




}
/// @nodoc
class __$ScheduledFlowsCopyWithImpl<$Res>
    implements _$ScheduledFlowsCopyWith<$Res> {
  __$ScheduledFlowsCopyWithImpl(this._self, this._then);

  final _ScheduledFlows _self;
  final $Res Function(_ScheduledFlows) _then;

/// Create a copy of ScheduledFlows
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? income = null,Object? expense = null,}) {
  return _then(_ScheduledFlows(
income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CategoryTotal {

 String get categoryId; int get amount; int get count;
/// Create a copy of CategoryTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryTotalCopyWith<CategoryTotal> get copyWith => _$CategoryTotalCopyWithImpl<CategoryTotal>(this as CategoryTotal, _$identity);

  /// Serializes this CategoryTotal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CategoryTotal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryTotal&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.count, _this.count) || other.count == _this.count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CategoryTotal;
  return Object.hash(runtimeType,_this.categoryId,_this.amount,_this.count);
}

@override
String toString() {
  final _this = this as CategoryTotal;
  return 'CategoryTotal(categoryId: ${_this.categoryId}, amount: ${_this.amount}, count: ${_this.count})';
}


}

/// @nodoc
abstract mixin class $CategoryTotalCopyWith<$Res>  {
  factory $CategoryTotalCopyWith(CategoryTotal value, $Res Function(CategoryTotal) _then) = _$CategoryTotalCopyWithImpl;
@useResult
$Res call({
 String categoryId, int amount, int count
});




}
/// @nodoc
class _$CategoryTotalCopyWithImpl<$Res>
    implements $CategoryTotalCopyWith<$Res> {
  _$CategoryTotalCopyWithImpl(this._self, this._then);

  final CategoryTotal _self;
  final $Res Function(CategoryTotal) _then;

/// Create a copy of CategoryTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? amount = null,Object? count = null,}) {
  return _then(CategoryTotal(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryTotal].
extension CategoryTotalPatterns on CategoryTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryTotal value)  $default,){
final _that = this;
switch (_that) {
case _CategoryTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryTotal value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  int amount,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryTotal() when $default != null:
return $default(_that.categoryId,_that.amount,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  int amount,  int count)  $default,) {final _that = this;
switch (_that) {
case _CategoryTotal():
return $default(_that.categoryId,_that.amount,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  int amount,  int count)?  $default,) {final _that = this;
switch (_that) {
case _CategoryTotal() when $default != null:
return $default(_that.categoryId,_that.amount,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryTotal extends CategoryTotal {
  const _CategoryTotal({required this.categoryId, required this.amount, required this.count}): super._();
  factory _CategoryTotal.fromJson(Map<String, dynamic> json) => _$CategoryTotalFromJson(json);

@override final  String categoryId;
@override final  int amount;
@override final  int count;

/// Create a copy of CategoryTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryTotalCopyWith<_CategoryTotal> get copyWith => __$CategoryTotalCopyWithImpl<_CategoryTotal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryTotalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryTotal&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,categoryId,amount,count);
}

@override
String toString() {
    return 'CategoryTotal(categoryId: $categoryId, amount: $amount, count: $count)';
}


}

/// @nodoc
abstract mixin class _$CategoryTotalCopyWith<$Res> implements $CategoryTotalCopyWith<$Res> {
  factory _$CategoryTotalCopyWith(_CategoryTotal value, $Res Function(_CategoryTotal) _then) = __$CategoryTotalCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, int amount, int count
});




}
/// @nodoc
class __$CategoryTotalCopyWithImpl<$Res>
    implements _$CategoryTotalCopyWith<$Res> {
  __$CategoryTotalCopyWithImpl(this._self, this._then);

  final _CategoryTotal _self;
  final $Res Function(_CategoryTotal) _then;

/// Create a copy of CategoryTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? amount = null,Object? count = null,}) {
  return _then(_CategoryTotal(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SummaryPoint {

@YearMonthConverter() YearMonth get month; int get income; int get expense;/// The balance at the end of the month (on `asOf` in its month); null
/// for a month after `asOf`.
 int? get netWorth;
/// Create a copy of SummaryPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SummaryPointCopyWith<SummaryPoint> get copyWith => _$SummaryPointCopyWithImpl<SummaryPoint>(this as SummaryPoint, _$identity);

  /// Serializes this SummaryPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SummaryPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SummaryPoint&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.income, _this.income) || other.income == _this.income)&&(identical(other.expense, _this.expense) || other.expense == _this.expense)&&(identical(other.netWorth, _this.netWorth) || other.netWorth == _this.netWorth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SummaryPoint;
  return Object.hash(runtimeType,_this.month,_this.income,_this.expense,_this.netWorth);
}

@override
String toString() {
  final _this = this as SummaryPoint;
  return 'SummaryPoint(month: ${_this.month}, income: ${_this.income}, expense: ${_this.expense}, netWorth: ${_this.netWorth})';
}


}

/// @nodoc
abstract mixin class $SummaryPointCopyWith<$Res>  {
  factory $SummaryPointCopyWith(SummaryPoint value, $Res Function(SummaryPoint) _then) = _$SummaryPointCopyWithImpl;
@useResult
$Res call({
@YearMonthConverter() YearMonth month, int income, int expense, int? netWorth
});




}
/// @nodoc
class _$SummaryPointCopyWithImpl<$Res>
    implements $SummaryPointCopyWith<$Res> {
  _$SummaryPointCopyWithImpl(this._self, this._then);

  final SummaryPoint _self;
  final $Res Function(SummaryPoint) _then;

/// Create a copy of SummaryPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? income = null,Object? expense = null,Object? netWorth = freezed,}) {
  return _then(SummaryPoint(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,netWorth: freezed == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [SummaryPoint].
extension SummaryPointPatterns on SummaryPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SummaryPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SummaryPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SummaryPoint value)  $default,){
final _that = this;
switch (_that) {
case _SummaryPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SummaryPoint value)?  $default,){
final _that = this;
switch (_that) {
case _SummaryPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month,  int income,  int expense,  int? netWorth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SummaryPoint() when $default != null:
return $default(_that.month,_that.income,_that.expense,_that.netWorth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month,  int income,  int expense,  int? netWorth)  $default,) {final _that = this;
switch (_that) {
case _SummaryPoint():
return $default(_that.month,_that.income,_that.expense,_that.netWorth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@YearMonthConverter()  YearMonth month,  int income,  int expense,  int? netWorth)?  $default,) {final _that = this;
switch (_that) {
case _SummaryPoint() when $default != null:
return $default(_that.month,_that.income,_that.expense,_that.netWorth);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SummaryPoint extends SummaryPoint {
  const _SummaryPoint({@YearMonthConverter() required this.month, required this.income, required this.expense, required this.netWorth}): super._();
  factory _SummaryPoint.fromJson(Map<String, dynamic> json) => _$SummaryPointFromJson(json);

@override@YearMonthConverter() final  YearMonth month;
@override final  int income;
@override final  int expense;
/// The balance at the end of the month (on `asOf` in its month); null
/// for a month after `asOf`.
@override final  int? netWorth;

/// Create a copy of SummaryPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SummaryPointCopyWith<_SummaryPoint> get copyWith => __$SummaryPointCopyWithImpl<_SummaryPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SummaryPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SummaryPoint&&(identical(other.month, month) || other.month == month)&&(identical(other.income, income) || other.income == income)&&(identical(other.expense, expense) || other.expense == expense)&&(identical(other.netWorth, netWorth) || other.netWorth == netWorth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,month,income,expense,netWorth);
}

@override
String toString() {
    return 'SummaryPoint(month: $month, income: $income, expense: $expense, netWorth: $netWorth)';
}


}

/// @nodoc
abstract mixin class _$SummaryPointCopyWith<$Res> implements $SummaryPointCopyWith<$Res> {
  factory _$SummaryPointCopyWith(_SummaryPoint value, $Res Function(_SummaryPoint) _then) = __$SummaryPointCopyWithImpl;
@override @useResult
$Res call({
@YearMonthConverter() YearMonth month, int income, int expense, int? netWorth
});




}
/// @nodoc
class __$SummaryPointCopyWithImpl<$Res>
    implements _$SummaryPointCopyWith<$Res> {
  __$SummaryPointCopyWithImpl(this._self, this._then);

  final _SummaryPoint _self;
  final $Res Function(_SummaryPoint) _then;

/// Create a copy of SummaryPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? income = null,Object? expense = null,Object? netWorth = freezed,}) {
  return _then(_SummaryPoint(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as int,expense: null == expense ? _self.expense : expense // ignore: cast_nullable_to_non_nullable
as int,netWorth: freezed == netWorth ? _self.netWorth : netWorth // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AccountBalance {

 String get accountId;@CurrencyConverter() Currency get currency; int get balance;
/// Create a copy of AccountBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountBalanceCopyWith<AccountBalance> get copyWith => _$AccountBalanceCopyWithImpl<AccountBalance>(this as AccountBalance, _$identity);

  /// Serializes this AccountBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AccountBalance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountBalance&&(identical(other.accountId, _this.accountId) || other.accountId == _this.accountId)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.balance, _this.balance) || other.balance == _this.balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AccountBalance;
  return Object.hash(runtimeType,_this.accountId,_this.currency,_this.balance);
}

@override
String toString() {
  final _this = this as AccountBalance;
  return 'AccountBalance(accountId: ${_this.accountId}, currency: ${_this.currency}, balance: ${_this.balance})';
}


}

/// @nodoc
abstract mixin class $AccountBalanceCopyWith<$Res>  {
  factory $AccountBalanceCopyWith(AccountBalance value, $Res Function(AccountBalance) _then) = _$AccountBalanceCopyWithImpl;
@useResult
$Res call({
 String accountId,@CurrencyConverter() Currency currency, int balance
});




}
/// @nodoc
class _$AccountBalanceCopyWithImpl<$Res>
    implements $AccountBalanceCopyWith<$Res> {
  _$AccountBalanceCopyWithImpl(this._self, this._then);

  final AccountBalance _self;
  final $Res Function(AccountBalance) _then;

/// Create a copy of AccountBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? currency = null,Object? balance = null,}) {
  return _then(AccountBalance(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountBalance].
extension AccountBalancePatterns on AccountBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountBalance value)  $default,){
final _that = this;
switch (_that) {
case _AccountBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountBalance value)?  $default,){
final _that = this;
switch (_that) {
case _AccountBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId, @CurrencyConverter()  Currency currency,  int balance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountBalance() when $default != null:
return $default(_that.accountId,_that.currency,_that.balance);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId, @CurrencyConverter()  Currency currency,  int balance)  $default,) {final _that = this;
switch (_that) {
case _AccountBalance():
return $default(_that.accountId,_that.currency,_that.balance);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId, @CurrencyConverter()  Currency currency,  int balance)?  $default,) {final _that = this;
switch (_that) {
case _AccountBalance() when $default != null:
return $default(_that.accountId,_that.currency,_that.balance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccountBalance extends AccountBalance {
  const _AccountBalance({required this.accountId, @CurrencyConverter() required this.currency, required this.balance}): super._();
  factory _AccountBalance.fromJson(Map<String, dynamic> json) => _$AccountBalanceFromJson(json);

@override final  String accountId;
@override@CurrencyConverter() final  Currency currency;
@override final  int balance;

/// Create a copy of AccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountBalanceCopyWith<_AccountBalance> get copyWith => __$AccountBalanceCopyWithImpl<_AccountBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccountBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountBalance&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.balance, balance) || other.balance == balance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,accountId,currency,balance);
}

@override
String toString() {
    return 'AccountBalance(accountId: $accountId, currency: $currency, balance: $balance)';
}


}

/// @nodoc
abstract mixin class _$AccountBalanceCopyWith<$Res> implements $AccountBalanceCopyWith<$Res> {
  factory _$AccountBalanceCopyWith(_AccountBalance value, $Res Function(_AccountBalance) _then) = __$AccountBalanceCopyWithImpl;
@override @useResult
$Res call({
 String accountId,@CurrencyConverter() Currency currency, int balance
});




}
/// @nodoc
class __$AccountBalanceCopyWithImpl<$Res>
    implements _$AccountBalanceCopyWith<$Res> {
  __$AccountBalanceCopyWithImpl(this._self, this._then);

  final _AccountBalance _self;
  final $Res Function(_AccountBalance) _then;

/// Create a copy of AccountBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? currency = null,Object? balance = null,}) {
  return _then(_AccountBalance(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
