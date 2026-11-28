import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/color_utils.dart';
import 'package:monthra/core/design_system/components/category_icons.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Sizes of a [CategoryIcon]: the tile's side and the glyph's.
enum CategoryIconSize {
  sm(28, 14),
  md(36, 18),
  lg(44, 22);

  new(this.box, this.glyph);

  final double box;
  final double glyph;
}

/// A category's Lucide icon on a neutral tile ("Silêncio": a category's
/// color shows only as a [CategoryDot]). Decorative unless [semanticLabel]
/// is given (lists read the category name next to it).
class CategoryIcon extends StatelessWidget {
  const new({
    required this.icon,
    this.size = CategoryIconSize.md,
    this.semanticLabel,
    super.key,
  });

  /// The Lucide name in kebab-case, as stored by the API.
  final String icon;
  final CategoryIconSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final tile = SizedBox.square(
      dimension: size.box,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.muted,
          borderRadius: MonthraRadii.mdAll,
        ),
        child: Center(
          child: Icon(
            CategoryIcons.resolve(icon),
            size: size.glyph,
            color: scheme.mutedForeground,
          ),
        ),
      ),
    );
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: tile);
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: tile),
    );
  }
}

/// A category's color as a small dot, moved until it reads at 3:1 on the
/// page (WCAG 1.4.11): user colors are mid tones. An invalid color paints
/// muted. Decorative: the name beside it says which category it is.
class CategoryDot extends StatelessWidget {
  const new(this.color, {this.size = 8, super.key});

  /// `#RRGGBB`, as stored by the API.
  final String color;
  final double size;

  /// [hex] as the dot paints it on the theme's background.
  static Color colorOf(ShadThemeData theme, String hex) {
    final scheme = theme.colorScheme;
    final base = parseHexColor(hex) ?? scheme.mutedForeground;
    return ensureContrast(base, scheme.background);
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorOf(ShadTheme.of(context), color),
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

/// A neutral pill with a category's dot and name, for chips and details.
class CategoryBadge extends StatelessWidget {
  const new({required this.color, required this.label, super.key});

  /// `#RRGGBB`, as stored by the API.
  final String color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.muted,
        borderRadius: MonthraRadii.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MonthraSpacing.x3 - 2,
          vertical: MonthraSpacing.x1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CategoryDot(color, size: 7),
            const SizedBox(width: MonthraSpacing.x2 - 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(color: scheme.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
