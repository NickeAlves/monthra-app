import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A part of a page that sits on the page itself ("Silêncio"): a hairline
/// above, a title row ([title], [description], and [trailing] beside them)
/// and the [child]. No box, background or shadow: space and the line
/// separate sections. Lists, figures and charts go in sections; a form or
/// something that must stand apart goes in a `MonthraCard`.
class MonthraSection extends StatelessWidget {
  const new({
    required this.child,
    this.title,
    this.description,
    this.trailing,
    this.divider = true,
    super.key,
  });

  /// Read as a heading.
  final Widget? title;
  final Widget? description;

  /// Beside the title (an action, a switch).
  final Widget? trailing;
  final Widget child;

  /// The hairline above; off for the first part of a page with no title.
  final bool divider;

  /// Space between the title row and the content.
  static const double headerGap = MonthraSpacing.x4;

  /// Space between the hairline and the title row.
  static const double topGap = MonthraSpacing.x5;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final title = this.title;
    final description = this.description;
    final trailing = this.trailing;
    final hasHeader = title != null || description != null || trailing != null;

    Widget? header;
    if (hasHeader) {
      header = Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Semantics(
                    header: true,
                    child: DefaultTextStyle.merge(
                      style: theme.textTheme.title.copyWith(
                        color: scheme.foreground,
                      ),
                      child: title,
                    ),
                  ),
                if (description != null)
                  DefaultTextStyle.merge(
                    style: theme.textTheme.muted.copyWith(
                      color: scheme.mutedForeground,
                    ),
                    child: description,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: MonthraSpacing.x3),
            trailing,
          ],
        ],
      );
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[header, const SizedBox(height: headerGap)],
        child,
      ],
    );
    if (!divider) return body;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: topGap),
        child: body,
      ),
    );
  }
}
