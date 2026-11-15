import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'helpers/fonts.dart';
import 'helpers/golden.dart';

/// Runs before every test file: the app's fonts replace the test font, so
/// layouts and goldens use Inter and the Lucide glyphs, and goldens accept
/// a sliver of antialiasing noise. shadcn_ui's strings for pt and es are
/// deferred libraries, loaded here with real async (a test's fake clock
/// would never finish them), so a pumped app only needs a frame more.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  await Future.wait([
    for (final l in AppLocale.values)
      GlobalShadLocalizations.delegate.load(l.locale),
  ]);
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenFileComparator(
      comparator.basedir.resolve('golden_test.dart'),
    );
  }
  await testMain();
}
