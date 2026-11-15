import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/fonts.dart';
import 'helpers/golden.dart';

/// Runs before every test file: the app's fonts replace the test font, so
/// layouts and goldens use Inter and the Lucide glyphs, and goldens accept
/// a sliver of antialiasing noise.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  final comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenFileComparator(
      comparator.basedir.resolve('golden_test.dart'),
    );
  }
  await testMain();
}
