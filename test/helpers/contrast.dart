import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/design_system/design_system.dart';

/// A text or icon that reads below WCAG AA on what is painted behind it.
typedef ContrastIssue = ({String text, double ratio, double minimum});

/// Checks every text (4.5:1) and icon (3:1, WCAG 1.4.11) in the tree against
/// the opaque color painted behind it, by color rather than by pixels.
///
/// Flutter's `textContrastGuideline` samples a screenshot and takes the most
/// frequent light and dark pixels: with the thin antialiasing of small text
/// on Linux, the text's own color never wins and it fails on colors that
/// pass. This reads the colors the widgets paint with. Text under an
/// [Opacity] below 1 (disabled controls, which WCAG exempts) is skipped.
List<ContrastIssue> contrastIssues(WidgetTester tester) {
  final issues = <ContrastIssue>[];
  for (final element in find.byType(RichText).evaluate()) {
    final span = (element.widget as RichText).text;
    final style = span.style;
    final color = style?.color;
    if (style == null || color == null) continue;

    final behind = _paintedBehind(element);
    if (behind == null) continue;

    final isIcon = style.fontFamily?.contains('Lucide') ?? false;
    final minimum = isIcon ? 3.0 : 4.5;
    final ratio = contrastRatio(Color.alphaBlend(color, behind), behind);
    if (ratio < minimum) {
      issues.add((
        text: isIcon ? 'icon U+${_codePoint(span)}' : span.toPlainText(),
        ratio: double.parse(ratio.toStringAsFixed(2)),
        minimum: minimum,
      ));
    }
  }
  return issues;
}

String _codePoint(InlineSpan span) => span
    .toPlainText()
    .runes
    .map((r) => r.toRadixString(16).toUpperCase())
    .join();

/// The opaque color behind [element], blending translucent layers on the
/// way down; null when a dimmed ancestor (Opacity < 1) exempts it or when
/// nothing opaque is found.
Color? _paintedBehind(Element element) {
  final layers = <Color>[];
  Color? opaque;
  var dimmed = false;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Opacity && widget.opacity < 1) {
      dimmed = true;
      return false;
    }
    final color = switch (widget) {
      ColoredBox(:final color) => color,
      DecoratedBox(
        decoration: BoxDecoration(:final color?),
        position: DecorationPosition.background,
      ) =>
        color,
      // shadcn badges and buttons paint shapes.
      DecoratedBox(
        decoration: ShapeDecoration(:final color?),
        position: DecorationPosition.background,
      ) =>
        color,
      _ => null,
    };
    if (color == null || color.a == 0) return true;
    if (color.a >= 1) {
      opaque = color;
      return false;
    }
    layers.add(color);
    return true;
  });
  final base = opaque;
  if (dimmed || base == null) return null;
  return layers.reversed.fold<Color>(
    base,
    (c, layer) => Color.alphaBlend(layer, c),
  );
}
