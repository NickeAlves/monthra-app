import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One line of what a data page explains, after its [icon] (decorative:
/// the text says it all).
class DataPoint extends StatelessWidget {
  const new({required this.icon, required this.text, this.color, super.key});

  final IconData icon;
  final String text;

  /// The icon's color; muted by default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: color ?? theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(width: MonthraSpacing.x3),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.foreground,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
