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
        'popover': scheme.popover,
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

      test('the destructive label reads on its hover tint', () {
        final tint = scheme.destructive.withValues(
          alpha: destructiveHoverAlpha,
        );
        for (final surface in [scheme.background, scheme.card]) {
          expect(
            contrastRatio(scheme.destructive, Color.alphaBlend(tint, surface)),
            greaterThanOrEqualTo(4.5),
          );
        }
      });

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
        expect(
          contrastRatio(scheme.onBrand, scheme.brand),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('chart marks read at 3:1 where charts sit', () {
        final marks = {
          'income': scheme.income,
          'chartMuted': scheme.chartMuted,
          for (final (i, c) in scheme.chartRamp.indexed) 'chartRamp[$i]': c,
        };
        for (final mark in marks.entries) {
          for (final surface in [scheme.background, scheme.card]) {
            expect(
              contrastRatio(mark.value, surface),
              greaterThanOrEqualTo(3),
              reason: mark.key,
            );
          }
        }
      });

      test('the chart ramp holds five distinct greens', () {
        expect(scheme.chartRamp, hasLength(5));
        expect(scheme.chartRamp.toSet(), hasLength(5));
      });

      test('the focus ring stands out from the surfaces', () {
        for (final surface in surfaces.values) {
          expect(contrastRatio(scheme.ring, surface), greaterThanOrEqualTo(3));
        }
      });

      test('every default category dot reads at 3:1 on the page', () {
        final theme = monthraTheme(brightness);
        for (final category in sampleCategories) {
          expect(
            contrastRatio(
              CategoryDot.colorOf(theme, category.color),
              theme.colorScheme.background,
            ),
            greaterThanOrEqualTo(3),
            reason: category.key,
          );
        }
      });
    });
  }

  test('the primary is ink and the brand stays green (user decision)', () {
    expect(MonthraColorSchemes.light.primary, MonthraPalette.ink);
    expect(MonthraColorSchemes.dark.primary, MonthraPalette.offWhite);
    expect(MonthraColorSchemes.light.brand, MonthraPalette.accent);
    expect(MonthraColorSchemes.dark.brand, MonthraPalette.accent);
    expect(MonthraColorSchemes.dark.accentText, MonthraPalette.accentLight);
    expect(MonthraColorSchemes.light.expense, MonthraPalette.ink);
  });

  test('a scheme without the Monthra roles falls back', () {
    const zinc = ShadZincColorScheme.light();
    expect(zinc.income, zinc.foreground);
    expect(zinc.skeleton, zinc.muted);
    expect(zinc.brand, zinc.primary);
    expect(zinc.chartRamp, everyElement(zinc.foreground));
  });
}
