import 'package:flutter/widgets.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/dashboard/presentation/dashboard_format.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The month shown, with the months before and after one tap away and,
/// away from it, a way back to [current]. Within the months the API takes
/// ([YearMonth.min] to [YearMonth.max]).
class MonthSwitcher extends StatelessWidget {
  const new({
    required this.month,
    required this.current,
    required this.onChanged,
    super.key,
  });

  final YearMonth month;
  final YearMonth current;
  final ValueChanged<YearMonth> onChanged;

  /// Room for the longest month name (`Septiembre de 2026`) at 1x.
  static const double labelWidth = 168;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final label = DashboardFormat.of(context).month(month);
    return Wrap(
      spacing: MonthraSpacing.x2,
      runSpacing: MonthraSpacing.x2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadIconButton.ghost(
              onPressed: month > YearMonth.min
                  ? () => onChanged(month.addMonths(-1))
                  : null,
              icon: Icon(
                LucideIcons.chevronLeft,
                semanticLabel: l10n.dashboardPreviousMonth,
              ),
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
              onPressed: month < YearMonth.max
                  ? () => onChanged(month.addMonths(1))
                  : null,
              icon: Icon(
                LucideIcons.chevronRight,
                semanticLabel: l10n.dashboardNextMonth,
              ),
            ),
          ],
        ),
        if (month != current)
          ShadButton.outline(
            onPressed: () => onChanged(current),
            leading: const Icon(LucideIcons.calendarCheck),
            child: ButtonLabel(l10n.dashboardThisMonth),
          ),
      ],
    );
  }
}
