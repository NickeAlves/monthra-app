import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/components/button_label.dart';
import 'package:monthra/core/design_system/components/tap_target.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The way back from a page under another one (a settings flow): a link
/// with an arrow above the title.
final class MonthraPageBack {
  const new({required this.label, required this.onPressed});

  /// Names where it goes ("Settings").
  final String label;
  final VoidCallback onPressed;
}

/// A screen of the app shell: its title (and [description], [actions])
/// over [child], scrolling, centered at [maxWidth] with the gutter of the
/// breakpoint, on the app background. A page under another has a [back].
class MonthraPage extends StatelessWidget {
  const new({
    required this.title,
    required this.child,
    this.description,
    this.actions = const [],
    this.back,
    this.maxWidth = MonthraLayout.maxContentWidth,
    super.key,
  });

  final String title;
  final String? description;
  final List<Widget> actions;
  final MonthraPageBack? back;
  final double maxWidth;
  final Widget child;

  /// The gutter around a page at [breakpoint].
  static double gutter(MonthraBreakpoint breakpoint) => switch (breakpoint) {
    MonthraBreakpoint.mobile => MonthraSpacing.x4,
    MonthraBreakpoint.tablet => MonthraSpacing.x6,
    MonthraBreakpoint.desktop => MonthraSpacing.x8,
  };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final breakpoint = context.monthraBreakpoint;
    return ColoredBox(
      color: theme.colorScheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.foreground),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(gutter(breakpoint)),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (back case final back?) ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: MonthraTapTarget(
                        child: ShadButton.link(
                          onPressed: back.onPressed,
                          // The arrow lines up with the title.
                          padding: const EdgeInsetsDirectional.only(
                            end: MonthraSpacing.x2,
                          ),
                          leading: const Icon(LucideIcons.arrowLeft300),
                          child: ButtonLabel(back.label),
                        ),
                      ),
                    ),
                    const SizedBox(height: MonthraSpacing.x2),
                  ],
                  MonthraPageHeader(
                    title: title,
                    description: description,
                    actions: actions,
                  ),
                  SizedBox(
                    height: breakpoint == MonthraBreakpoint.mobile
                        ? MonthraSpacing.x6
                        : MonthraSpacing.x8,
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The title of a page (a heading for assistive technologies), with an
/// optional description below and [actions] beside it (below on a phone).
class MonthraPageHeader extends StatelessWidget {
  const new({
    required this.title,
    this.description,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String? description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final mobile = context.monthraBreakpoint == MonthraBreakpoint.mobile;
    final description = this.description;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: (mobile ? theme.textTheme.h3 : theme.textTheme.h2).copyWith(
              color: theme.colorScheme.foreground,
            ),
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: MonthraSpacing.x1),
          Text(
            description,
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
    if (actions.isEmpty) return heading;
    final buttons = Wrap(
      spacing: MonthraSpacing.x2,
      runSpacing: MonthraSpacing.x2,
      children: actions,
    );
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading,
          const SizedBox(height: MonthraSpacing.x4),
          buttons,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: heading),
        const SizedBox(width: MonthraSpacing.x4),
        buttons,
      ],
    );
  }
}
