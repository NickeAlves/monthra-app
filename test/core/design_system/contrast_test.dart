import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/catalog/sample_categories.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// WCAG AA on both themes: 4.5:1 for text, 3:1 for graphics and focus.
void main() {
  const schemes = {
    'light': (MonthraColorSchemes.light, Brightness.light),
    'dark': (MonthraColorSchemes.dark, Brightness.dark),
  };

  for (final MapEntry(key: name, value: (scheme, brightness))
      in schemes.entries) {
    group('$name theme', () {
      final surfaces = {
        'background': scheme.background,
        'card': scheme.card,
        'muted': scheme.muted,
      };
      final texts = {
        'foreground': scheme.foreground,
        'mutedForeground': scheme.mutedForeground,
        'accentText': scheme.accentText,
        'income': scheme.income,
        'expense': scheme.expense,
        'warning': scheme.warning,
        'destructive': scheme.destructive,
      };

      for (final text in texts.entries) {
        for (final surface in surfaces.entries) {
          test('${text.key} reads on ${surface.key}', () {
            expect(
              contrastRatio(text.value, surface.value),
              greaterThanOrEqualTo(4.5),
            );
          });
        }
      }

      test('button labels read on their fills', () {
        expect(
          contrastRatio(scheme.primaryForeground, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(scheme.destructiveForeground, scheme.destructive),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(scheme.secondaryForeground, scheme.secondary),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('the focus ring stands out from the surfaces', () {
        for (final surface in surfaces.values) {
          expect(contrastRatio(scheme.ring, surface), greaterThanOrEqualTo(3));
        }
      });

      test('every default category reads on its tint', () {
        final theme = monthraTheme(brightness);
        for (final category in sampleCategories) {
          final colors = CategoryColors.of(theme, category.color);
          expect(
            contrastRatio(colors.icon, colors.tint),
            greaterThanOrEqualTo(3),
            reason: '${category.key} icon',
          );
          expect(
            contrastRatio(colors.text, colors.tint),
            greaterThanOrEqualTo(4.5),
            reason: '${category.key} label',
          );
        }
      });
    });
  }

  test('the dark primary keeps the brand accent (user decision)', () {
    expect(MonthraColorSchemes.dark.primary, MonthraPalette.accent);
    expect(MonthraColorSchemes.light.primary, MonthraPalette.accent);
    expect(MonthraColorSchemes.dark.accentText, MonthraPalette.accentLight);
  });

  test('a scheme without the Monthra roles falls back', () {
    const zinc = ShadZincColorScheme.light();
    expect(zinc.income, zinc.foreground);
    expect(zinc.skeleton, zinc.muted);
  });
}
