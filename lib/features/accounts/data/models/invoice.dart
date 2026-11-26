import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/json/converters.dart';
import 'package:monthra/core/money/currency.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

/// Where an invoice stands on the day it was read (server
/// `domain.InvoiceStatus`).
@JsonEnum(fieldRename: FieldRename.snake)
enum InvoiceStatus {
  /// Not started: the invoice before it is still open.
  upcoming,

  /// Takes the purchases of the current cycle.
  open,

  /// Closed, waiting for its payment, not yet due.
  closed,

  /// Closed with nothing left to pay.
  paid,

  /// Past its due day with something left to pay.
  overdue,

  /// Closed with something left that the next invoice, closed since, took
  /// as its previous balance.
  carriedOver,

  /// A status this build does not know yet.
  unknown,
}

/// The statement of a credit card for one month (`Invoice` in the
/// OpenAPI), named after the month it falls due in. Amounts in minor units
/// of [currency]: [total] = [previousBalance] + [charges] - [credits],
/// [remaining] = [total] - [paid] (below zero, a credit), which the next
/// invoice takes as its previous balance.
@freezed
abstract class Invoice with _$Invoice {
  const factory({
    @YearMonthConverter() required YearMonth month,
    @CivilDateConverter() required DateTime closingDate,
    @CivilDateConverter() required DateTime dueDate,
    @JsonKey(unknownEnumValue: InvoiceStatus.unknown)
    required InvoiceStatus status,
    @CurrencyConverter() required Currency currency,
    required int previousBalance,
    required int charges,
    required int credits,
    required int total,
    required int paid,
    required int remaining,
  }) = _Invoice;

  factory fromJson(Map<String, Object?> json) => _$InvoiceFromJson(json);
}
