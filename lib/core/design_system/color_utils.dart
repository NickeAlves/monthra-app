import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The WCAG 2 contrast ratio of two opaque colors, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [color] as it reads on [surface], or with its lightness moved away from
/// the surface (hue and saturation kept) until it reaches [minRatio].
///
/// User colors (a category's) are mid tones: yellow on white or indigo on
/// graphite would fall under the 3:1 that icons need (WCAG 1.4.11).
Color ensureContrast(Color color, Color surface, {double minRatio = 3}) {
  if (contrastRatio(color, surface) >= minRatio) return color;
  final hsl = HSLColor.fromColor(color);
  final darken = surface.computeLuminance() > 0.18;
  const step = 0.01;
  var lightness = hsl.lightness;
  while (lightness > 0 && lightness < 1) {
    lightness = (lightness + (darken ? -step : step)).clamp(0, 1);
    final candidate = hsl.withLightness(lightness).toColor();
    if (contrastRatio(candidate, surface) >= minRatio) return candidate;
  }
  return darken ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
}

final _hexColor = RegExp(r'^#([0-9a-fA-F]{6})$');

/// Parses a `#RRGGBB` color (as the API stores categories'), or null.
Color? parseHexColor(String? value) {
  final match = _hexColor.firstMatch(value ?? '');
  if (match == null) return null;
  return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
}
