import 'package:flutter/painting.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

void main() {
  group('contrastRatio', () {
    test('matches the WCAG extremes', () {
      const black = Color(0xFF000000);
      const white = Color(0xFFFFFFFF);
      expect(contrastRatio(black, white), closeTo(21, 0.01));
      expect(contrastRatio(white, white), 1);
      expect(contrastRatio(white, black), contrastRatio(black, white));
    });

    test('measures the brand accent on white', () {
      expect(
        contrastRatio(MonthraPalette.accent, MonthraPalette.white),
        closeTo(6.4, 0.05),
      );
    });
  });

  group('ensureContrast', () {
    test('keeps a color that already reads', () {
      expect(
        ensureContrast(MonthraPalette.accent, MonthraPalette.white),
        MonthraPalette.accent,
      );
    });

    test('darkens a light color on a light surface', () {
      const yellow = Color(0xFFEAB308);
      final fixed = ensureContrast(yellow, MonthraPalette.white);
      expect(
        contrastRatio(fixed, MonthraPalette.white),
        greaterThanOrEqualTo(3),
      );
      expect(fixed.computeLuminance(), lessThan(yellow.computeLuminance()));
      expect(
        HSLColor.fromColor(fixed).hue,
        closeTo(HSLColor.fromColor(yellow).hue, 1),
      );
    });

    test('lightens a dark color on a dark surface', () {
      const indigo = Color(0xFF3730A3);
      final fixed = ensureContrast(
        indigo,
        MonthraPalette.graphite,
        minRatio: 4.5,
      );
      expect(
        contrastRatio(fixed, MonthraPalette.graphite),
        greaterThanOrEqualTo(4.5),
      );
      expect(fixed.computeLuminance(), greaterThan(indigo.computeLuminance()));
    });

    test('falls back to black or white when no lightness works', () {
      expect(
        ensureContrast(
          const Color(0xFF777777),
          const Color(0xFF777777),
          minRatio: 21,
        ),
        anyOf(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      );
    });
  });

  group('parseHexColor', () {
    test('reads #RRGGBB in either case', () {
      expect(parseHexColor('#1E6B52'), const Color(0xFF1E6B52));
      expect(parseHexColor('#1e6b52'), const Color(0xFF1E6B52));
    });

    test('refuses anything else', () {
      for (final value in [
        null,
        '',
        '1E6B52',
        '#1E6B5',
        '#1E6B52FF',
        '#GGGGGG',
      ]) {
        expect(parseHexColor(value), isNull, reason: '$value');
      }
    });
  });
}
