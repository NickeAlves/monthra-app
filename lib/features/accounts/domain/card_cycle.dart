import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/features/accounts/data/models/account.dart';

/// The invoice cycle of a credit card, as the server reckons it
/// (monthra-server `internal/domain/card.go`). An invoice is named after
/// the month it falls due in: the December invoice is due on [dueDay] of
/// December and closes on [closingDay] of that month when the due day
/// comes later, or of the month before otherwise. A day past the end of a
/// shorter month is its last day. Days are local midnights of civil days.
extension CardCycle on CardSettings {
  /// The day invoice [month] closes: purchases before it belong to
  /// [month], those of that day on to the next invoice.
  DateTime closingDate(YearMonth month) => dueDay > closingDay
      ? month.day(closingDay)
      : month.addMonths(-1).day(closingDay);

  /// The day invoice [month] falls due.
  DateTime dueDate(YearMonth month) => month.day(dueDay);

  /// The invoice of a purchase on [day]: the first one that closes after
  /// it, so a purchase on the closing day goes to the next invoice.
  YearMonth invoiceFor(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    var month = YearMonth.of(date);
    if (dueDay <= closingDay) month = month.addMonths(1);
    return date.isBefore(closingDate(month)) ? month : month.addMonths(1);
  }

  /// The invoice a payment on [day] pays when none is named: the last one
  /// closed on or before it.
  YearMonth paymentInvoice(DateTime day) => invoiceFor(day).addMonths(-1);
}
