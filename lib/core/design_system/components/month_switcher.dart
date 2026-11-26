import 'package:flutter/widgets.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/components/button_label.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The labels of a [MonthSwitcher], translated by the caller (core has no
/// strings).
typedef MonthSwitcherLabels = ({
  /// The button to the month before ("Previous month").
  String previous,

  /// The button to the month after ("Next month").
  String next,

  /// The way back to the switcher's `current` month ("This month", "Open
  /// invoice").
  String current,
});

/// The side a [MonthSwitcher] is pinned to in its layout.
enum MonthSwitcherAnchor { start, end }

/// The month shown, with the months before and after one tap away and,
/// away from it, a way back to [current]. Within [min] and [max] (the
/// months the API takes by default).
///
/// The way back appears on the side away from [anchor], so the arrows
/// never move when it comes and goes: before them when the switcher is
/// pinned to the end (a header's actions on a tablet or a desktop), after
/// them when it is pinned to the start (a phone's header). By default the
/// anchor follows the breakpoint that way.
class MonthSwitcher extends StatelessWidget {
  const new({
    required this.month,
    required this.current,
    required this.onChanged,
    required this.labels,
    this.min = YearMonth.min,
    this.max = YearMonth.max,
    this.anchor,
    super.key,
  });

  final YearMonth month;
  final YearMonth current;
  final ValueChanged<YearMonth> onChanged;
  final MonthSwitcherLabels labels;
  final YearMonth min;
  final YearMonth max;

  /// Where the layout pins the switcher; null follows the breakpoint (the
  /// start on a phone, the end above).
  final MonthSwitcherAnchor? anchor;

  /// The anchor [MonthSwitcher] takes by default in [context].
  static MonthSwitcherAnchor defaultAnchor(BuildContext context) =>
      context.monthraBreakpoint == MonthraBreakpoint.mobile
      ? MonthSwitcherAnchor.start
      : MonthSwitcherAnchor.end;

  /// Room for the longest month name (`Septiembre de 2026`) at 1x.
  static const double labelWidth = 168;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final label = DisplayFormat.of(context).month(month);
    final end = (anchor ?? defaultAnchor(context)) == MonthSwitcherAnchor.end;
    final back = month == current
        ? null
        : ShadButton.outline(
            onPressed: () => onChanged(current),
            leading: const Icon(LucideIcons.calendarCheck),
            child: ButtonLabel(labels.current),
          );
    final arrows = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadIconButton.ghost(
          onPressed: month > min ? () => onChanged(month.addMonths(-1)) : null,
          icon: Icon(LucideIcons.chevronLeft, semanticLabel: labels.previous),
        ),
        // Wraps at a large text size on a phone rather than overflow.
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: labelWidth),
            // Read once when it changes: the buttons around it keep
            // their own labels.
            child: Semantics(
              liveRegion: true,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.label.copyWith(
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
          ),
        ),
        ShadIconButton.ghost(
          onPressed: month < max ? () => onChanged(month.addMonths(1)) : null,
          icon: Icon(LucideIcons.chevronRight, semanticLabel: labels.next),
        ),
      ],
    );
    return Wrap(
      spacing: MonthraSpacing.x2,
      runSpacing: MonthraSpacing.x2,
      alignment: end ? WrapAlignment.end : WrapAlignment.start,
      // Top-aligned: the outlined button is a little taller than the
      // arrows, and centering would nudge them when it shows.
      // The arrows keep their place: the way back goes on the free side.
      children: [if (end) ?back, arrows, if (!end) ?back],
    );
  }
}
