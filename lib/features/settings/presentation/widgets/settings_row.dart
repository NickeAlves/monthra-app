import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One setting: [title] and [description] with its [control] beside them
/// on a wide card, below them on a narrow one or with large text.
class SettingsRow extends StatelessWidget {
  const new({
    required this.title,
    required this.control,
    this.description,
    this.badge,
    this.controlLabeled = false,
    super.key,
  });

  final String title;

  /// A state beside the title (on, off).
  final Widget? badge;
  final String? description;
  final Widget control;

  /// The control reads [title] out itself (the pickers carry their own
  /// label), so the visible title is not read twice.
  final bool controlLabeled;

  /// Narrowest a card gets with the control beside the text.
  static const double sideBySideFrom = 560;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final description = this.description;
    final badge = this.badge;
    final heading = Text(
      title,
      style: theme.textTheme.p.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.foreground,
      ),
    );
    Widget text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge == null)
          heading
        else
          Wrap(
            spacing: MonthraSpacing.x2,
            runSpacing: MonthraSpacing.x1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [heading, badge],
          ),
        if (description != null) ...[
          const SizedBox(height: MonthraSpacing.x1),
          Text(
            description,
            style: theme.textTheme.muted.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
    if (controlLabeled) text = ExcludeSemantics(child: text);
    // Large text needs the width: one column above 1.5x.
    final largeText = MediaQuery.textScalerOf(context).scale(10) > 15;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < sideBySideFrom || largeText) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text,
              const SizedBox(height: MonthraSpacing.x3),
              control,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: text),
            const SizedBox(width: MonthraSpacing.x4),
            control,
          ],
        );
      },
    );
  }
}
