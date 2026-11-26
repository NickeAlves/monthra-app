// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_Invoice', json, ($checkedConvert) {
      final val = _Invoice(
        month: $checkedConvert(
          'month',
          (v) => const YearMonthConverter().fromJson(v as String),
        ),
        closingDate: $checkedConvert(
          'closingDate',
          (v) => const CivilDateConverter().fromJson(v as String),
        ),
        dueDate: $checkedConvert(
          'dueDate',
          (v) => const CivilDateConverter().fromJson(v as String),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$InvoiceStatusEnumMap,
            v,
            unknownValue: InvoiceStatus.unknown,
          ),
        ),
        currency: $checkedConvert(
          'currency',
          (v) => const CurrencyConverter().fromJson(v as String),
        ),
        previousBalance: $checkedConvert(
          'previousBalance',
          (v) => (v as num).toInt(),
        ),
        charges: $checkedConvert('charges', (v) => (v as num).toInt()),
        credits: $checkedConvert('credits', (v) => (v as num).toInt()),
        total: $checkedConvert('total', (v) => (v as num).toInt()),
        paid: $checkedConvert('paid', (v) => (v as num).toInt()),
        remaining: $checkedConvert('remaining', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'month': const YearMonthConverter().toJson(instance.month),
  'closingDate': const CivilDateConverter().toJson(instance.closingDate),
  'dueDate': const CivilDateConverter().toJson(instance.dueDate),
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'currency': const CurrencyConverter().toJson(instance.currency),
  'previousBalance': instance.previousBalance,
  'charges': instance.charges,
  'credits': instance.credits,
  'total': instance.total,
  'paid': instance.paid,
  'remaining': instance.remaining,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.upcoming: 'upcoming',
  InvoiceStatus.open: 'open',
  InvoiceStatus.closed: 'closed',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.carriedOver: 'carried_over',
  InvoiceStatus.unknown: 'unknown',
};
