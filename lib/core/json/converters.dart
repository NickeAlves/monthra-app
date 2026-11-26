import 'package:json_annotation/json_annotation.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/money/currency.dart';

/// An ISO 4217 code of the API (`BRL`) as a [Currency]; any other code
/// fails the read.
final class CurrencyConverter implements JsonConverter<Currency, String> {
  const new();

  @override
  Currency fromJson(String json) => Currency.fromCode(json);

  @override
  String toJson(Currency object) => object.code;
}

/// The API's `Month` (`YYYY-MM`) as a [YearMonth].
final class YearMonthConverter implements JsonConverter<YearMonth, String> {
  const new();

  @override
  YearMonth fromJson(String json) => YearMonth.parse(json);

  @override
  String toJson(YearMonth object) => object.toString();
}

/// The API's `Date` (`YYYY-MM-DD`, a civil day) as local midnight of that
/// day, so formatting it shows the same day in any time zone.
final class CivilDateConverter implements JsonConverter<DateTime, String> {
  const new();

  @override
  DateTime fromJson(String json) => parseCivilDate(json);

  @override
  String toJson(DateTime object) => civilDate(object);
}
