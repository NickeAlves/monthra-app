// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invoice {

@YearMonthConverter() YearMonth get month;@CivilDateConverter() DateTime get closingDate;@CivilDateConverter() DateTime get dueDate;@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus get status;@CurrencyConverter() Currency get currency; int get previousBalance; int get charges; int get credits; int get total; int get paid; int get remaining;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invoice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.closingDate, _this.closingDate) || other.closingDate == _this.closingDate)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.previousBalance, _this.previousBalance) || other.previousBalance == _this.previousBalance)&&(identical(other.charges, _this.charges) || other.charges == _this.charges)&&(identical(other.credits, _this.credits) || other.credits == _this.credits)&&(identical(other.total, _this.total) || other.total == _this.total)&&(identical(other.paid, _this.paid) || other.paid == _this.paid)&&(identical(other.remaining, _this.remaining) || other.remaining == _this.remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invoice;
  return Object.hash(runtimeType,_this.month,_this.closingDate,_this.dueDate,_this.status,_this.currency,_this.previousBalance,_this.charges,_this.credits,_this.total,_this.paid,_this.remaining);
}

@override
String toString() {
  final _this = this as Invoice;
  return 'Invoice(month: ${_this.month}, closingDate: ${_this.closingDate}, dueDate: ${_this.dueDate}, status: ${_this.status}, currency: ${_this.currency}, previousBalance: ${_this.previousBalance}, charges: ${_this.charges}, credits: ${_this.credits}, total: ${_this.total}, paid: ${_this.paid}, remaining: ${_this.remaining})';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
@YearMonthConverter() YearMonth month,@CivilDateConverter() DateTime closingDate,@CivilDateConverter() DateTime dueDate,@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus status,@CurrencyConverter() Currency currency, int previousBalance, int charges, int credits, int total, int paid, int remaining
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? month = null,Object? closingDate = null,Object? dueDate = null,Object? status = null,Object? currency = null,Object? previousBalance = null,Object? charges = null,Object? credits = null,Object? total = null,Object? paid = null,Object? remaining = null,}) {
  return _then(Invoice(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,closingDate: null == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as int,charges: null == charges ? _self.charges : charges // ignore: cast_nullable_to_non_nullable
as int,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime closingDate, @CivilDateConverter()  DateTime dueDate, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status, @CurrencyConverter()  Currency currency,  int previousBalance,  int charges,  int credits,  int total,  int paid,  int remaining)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.month,_that.closingDate,_that.dueDate,_that.status,_that.currency,_that.previousBalance,_that.charges,_that.credits,_that.total,_that.paid,_that.remaining);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime closingDate, @CivilDateConverter()  DateTime dueDate, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status, @CurrencyConverter()  Currency currency,  int previousBalance,  int charges,  int credits,  int total,  int paid,  int remaining)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.month,_that.closingDate,_that.dueDate,_that.status,_that.currency,_that.previousBalance,_that.charges,_that.credits,_that.total,_that.paid,_that.remaining);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@YearMonthConverter()  YearMonth month, @CivilDateConverter()  DateTime closingDate, @CivilDateConverter()  DateTime dueDate, @JsonKey(unknownEnumValue: InvoiceStatus.unknown)  InvoiceStatus status, @CurrencyConverter()  Currency currency,  int previousBalance,  int charges,  int credits,  int total,  int paid,  int remaining)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.month,_that.closingDate,_that.dueDate,_that.status,_that.currency,_that.previousBalance,_that.charges,_that.credits,_that.total,_that.paid,_that.remaining);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({@YearMonthConverter() required this.month, @CivilDateConverter() required this.closingDate, @CivilDateConverter() required this.dueDate, @JsonKey(unknownEnumValue: InvoiceStatus.unknown) required this.status, @CurrencyConverter() required this.currency, required this.previousBalance, required this.charges, required this.credits, required this.total, required this.paid, required this.remaining});
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override@YearMonthConverter() final  YearMonth month;
@override@CivilDateConverter() final  DateTime closingDate;
@override@CivilDateConverter() final  DateTime dueDate;
@override@JsonKey(unknownEnumValue: InvoiceStatus.unknown) final  InvoiceStatus status;
@override@CurrencyConverter() final  Currency currency;
@override final  int previousBalance;
@override final  int charges;
@override final  int credits;
@override final  int total;
@override final  int paid;
@override final  int remaining;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.month, month) || other.month == month)&&(identical(other.closingDate, closingDate) || other.closingDate == closingDate)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.previousBalance, previousBalance) || other.previousBalance == previousBalance)&&(identical(other.charges, charges) || other.charges == charges)&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.total, total) || other.total == total)&&(identical(other.paid, paid) || other.paid == paid)&&(identical(other.remaining, remaining) || other.remaining == remaining));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,month,closingDate,dueDate,status,currency,previousBalance,charges,credits,total,paid,remaining);
}

@override
String toString() {
    return 'Invoice(month: $month, closingDate: $closingDate, dueDate: $dueDate, status: $status, currency: $currency, previousBalance: $previousBalance, charges: $charges, credits: $credits, total: $total, paid: $paid, remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
@YearMonthConverter() YearMonth month,@CivilDateConverter() DateTime closingDate,@CivilDateConverter() DateTime dueDate,@JsonKey(unknownEnumValue: InvoiceStatus.unknown) InvoiceStatus status,@CurrencyConverter() Currency currency, int previousBalance, int charges, int credits, int total, int paid, int remaining
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? month = null,Object? closingDate = null,Object? dueDate = null,Object? status = null,Object? currency = null,Object? previousBalance = null,Object? charges = null,Object? credits = null,Object? total = null,Object? paid = null,Object? remaining = null,}) {
  return _then(_Invoice(
month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as YearMonth,closingDate: null == closingDate ? _self.closingDate : closingDate // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as Currency,previousBalance: null == previousBalance ? _self.previousBalance : previousBalance // ignore: cast_nullable_to_non_nullable
as int,charges: null == charges ? _self.charges : charges // ignore: cast_nullable_to_non_nullable
as int,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,paid: null == paid ? _self.paid : paid // ignore: cast_nullable_to_non_nullable
as int,remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
