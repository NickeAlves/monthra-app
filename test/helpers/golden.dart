import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

import 'frame.dart';

/// Share of pixels a golden may differ by (antialiasing noise between CI
/// machines); anything visible is far above it.
const double goldenTolerance = 0.001;

/// Font rasterization differs between macOS and Linux, so goldens are
/// rendered and compared on Linux only: CI is the reference (README,
/// "Golden tests").
final bool goldensRunHere = Platform.isLinux;

/// A [LocalFileComparator] that passes images within [goldenTolerance].
class TolerantGoldenFileComparator extends LocalFileComparator {
  new(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= goldenTolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Golden tests of [build] in the light and dark themes, at [size] and a
/// pixel ratio of 1, with animations off (skeletons hold still). Images go
/// to `goldens/<name>_<brightness>.png` next to the test file.
///
/// The subject is laid out on every OS, so an overflow fails anywhere; the
/// image comparison runs on Linux only and is reported as skipped elsewhere.
///
/// [setup] runs after the first frame, before the comparison (focus a
/// control, hover it). [store] holds the preferences (pt-BR and the system
/// theme when null, like the frame).
void goldenTest(
  String name,
  Widget Function() build, {
  Size size = const Size(480, 480),
  Future<void> Function(WidgetTester tester)? setup,
  PreferencesStore Function()? store,
}) {
  group(name, () {
    for (final brightness in Brightness.values) {
      testWidgets(brightness.name, tags: ['golden'], (tester) async {
        tester.reduceMotion();
        await tester.pumpFrame(
          build(),
          brightness: brightness,
          size: size,
          store: store?.call(),
        );
        await setup?.call(tester);
        await tester.pump(const Duration(milliseconds: 300));

        if (!goldensRunHere) {
          markTestSkipped('image comparison runs on Linux only (see README)');
          return;
        }
        await expectLater(
          find.byType(TestFrame),
          matchesGoldenFile('goldens/${name}_${brightness.name}.png'),
        );
      });
    }
  });
}
