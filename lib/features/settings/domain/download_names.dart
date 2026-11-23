/// The data export's file name, as the server names it
/// (`Content-Disposition`, which a browser on another origin cannot read):
/// `monthra-data-YYYY-MM-DD.zip`, the day in UTC.
String exportFileName(DateTime at) {
  final day = at.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'monthra-data-${day.year}-${two(day.month)}-${two(day.day)}.zip';
}

/// The recovery codes' text file.
const String recoveryCodesFileName = 'monthra-recovery-codes.txt';
