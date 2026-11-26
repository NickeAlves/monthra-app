import 'package:flutter/foundation.dart';

/// A civil month (`YYYY-MM`, the API's `Month`): no day, no time zone.
@immutable
final class YearMonth implements Comparable<YearMonth> {
  const new(this.year, this.month)
    : assert(month >= 1 && month <= 12, 'month is 1 to 12');

  /// The month [day] falls in, as the device's calendar reads it.
  factory of(DateTime day) => YearMonth(day.year, day.month);

  /// Parses `YYYY-MM` within [min] and [max]; throws a [FormatException]
  /// otherwise.
  factory parse(String text) {
    final month = tryParse(text);
    if (month == null) throw FormatException('not a YYYY-MM month', text);
    return month;
  }

  /// The earliest and latest months the API takes (server `MinMonth` and
  /// `MaxMonth`).
  static const min = YearMonth(1900, 1);
  static const max = YearMonth(2100, 12);

  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})$');

  /// The month `YYYY-MM` names, or null for anything else (a malformed or
  /// out-of-range value from an address, say).
  static YearMonth? tryParse(String? text) {
    final match = _pattern.firstMatch(text ?? '');
    if (match == null) return null;
    final month = int.parse(match[2]!);
    if (month < 1 || month > 12) return null;
    final parsed = YearMonth(int.parse(match[1]!), month);
    return parsed < min || parsed > max ? null : parsed;
  }

  final int year;

  /// 1 (January) to 12.
  final int month;

  int get _index => year * 12 + month - 1;

  /// [count] months later (earlier when negative).
  YearMonth addMonths(int count) {
    final index = _index + count;
    return YearMonth(index ~/ 12, index % 12 + 1);
  }

  /// Midnight of the month's first day, in local time (to format the
  /// month's name).
  DateTime get firstDay => DateTime(year, month);

  @override
  int compareTo(YearMonth other) => _index.compareTo(other._index);

  bool operator <(YearMonth other) => _index < other._index;
  bool operator >(YearMonth other) => _index > other._index;

  @override
  bool operator ==(Object other) =>
      other is YearMonth && other._index == _index;

  @override
  int get hashCode => _index.hashCode;

  /// `YYYY-MM`, as the API takes it.
  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}

/// [day] as a civil date (`YYYY-MM-DD`, the API's `Date`) in the device's
/// calendar: the reader's today the API takes as `asOf`.
String civilDate(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

final RegExp _civilDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// Local midnight of the civil date `YYYY-MM-DD`; throws a
/// [FormatException] for anything else (a day that does not exist too).
DateTime parseCivilDate(String text) {
  final match = _civilDate.firstMatch(text);
  if (match != null) {
    final day = DateTime(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
    if (civilDate(day) == text) return day;
  }
  throw FormatException('not a YYYY-MM-DD date', text);
}
