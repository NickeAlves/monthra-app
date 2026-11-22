import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/domain/download_names.dart';

void main() {
  test('the export is named after the day in UTC, as the server names it', () {
    expect(
      exportFileName(DateTime.utc(2026, 3, 5, 12)),
      'monthra-data-2026-03-05.zip',
    );
    // 23:30 on Nov 22 in São Paulo is already Nov 23 in UTC.
    expect(
      exportFileName(DateTime.utc(2026, 11, 23, 2, 30).toLocal()),
      'monthra-data-2026-11-23.zip',
    );
    expect(recoveryCodesFileName, 'monthra-recovery-codes.txt');
  });
}
