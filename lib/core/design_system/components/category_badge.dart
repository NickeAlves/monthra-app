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

/// The colors a category paints with on the current theme: a soft tint of
/// its color (opaque, over the card surface) and the color itself, moved
/// until it reads on that tint.
@immutable
class CategoryColors {
  const new({required this.tint, required this.icon, required this.text});

  /// [hex] is the category's `#RRGGBB`; an invalid one paints muted.
  factory of(ShadThemeData theme, String hex) {
    final scheme = theme.colorScheme;
    final base = parseHexColor(hex) ?? scheme.mutedForeground;
    final alpha = theme.brightness == Brightness.light ? 0.12 : 0.18;
    final tint = Color.alphaBlend(base.withValues(alpha: alpha), scheme.card);
    return CategoryColors(
      tint: tint,
      icon: ensureContrast(base, tint),
      // A hair above 4.5: antialiased glyphs read slightly lighter.
      text: ensureContrast(base, tint, minRatio: 4.7),
    );
  }

  final Color tint;

  /// At least 3:1 on [tint] (WCAG 1.4.11, graphics).
  final Color icon;

  /// At least 4.5:1 on [tint] (WCAG 1.4.3, text), with a margin.
  final Color text;
}

/// A category's Lucide icon on a tile of its color. Decorative unless
/// [semanticLabel] is given (lists read the category name next to it).
class CategoryIcon extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    this.size = CategoryIconSize.md,
    this.semanticLabel,
    super.key,
  });

  /// The Lucide name in kebab-case, as stored by the API.
  final String icon;

  /// `#RRGGBB`, as stored by the API.
  final String color;
  final CategoryIconSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = CategoryColors.of(ShadTheme.of(context), color);
    final tile = SizedBox.square(
      dimension: size.box,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.tint,
          borderRadius: MonthraRadii.smAll,
        ),
        child: Center(
          child: Icon(
            CategoryIcons.resolve(icon),
            size: size.glyph,
            color: colors.icon,
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

/// A pill with a category's icon and name, for chips and details.
class CategoryBadge extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    required this.label,
    super.key,
  });

  final String icon;
  final String color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = CategoryColors.of(theme, color);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tint,
        borderRadius: MonthraRadii.pillAll,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MonthraSpacing.x3,
          vertical: MonthraSpacing.x1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                CategoryIcons.resolve(icon),
                size: 14,
                color: colors.icon,
              ),
            ),
            const SizedBox(width: MonthraSpacing.x1 + 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(color: colors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
