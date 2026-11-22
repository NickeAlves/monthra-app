import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The first letter of [name] in a circle: who is signed in.
class AccountAvatar extends StatelessWidget {
  const new({required this.name, super.key});

  final String name;

  static const double size = 32;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final initial = name.trim().characters.firstOrNull?.toUpperCase() ?? '';
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          style: theme.textTheme.small.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondaryForeground,
          ),
        ),
      ),
    );
  }
}

/// Name and email beside the avatar, one line each.
class AccountSummary extends StatelessWidget {
  const new({required this.name, required this.email, super.key});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MergeSemantics(
      child: Row(
        children: [
          AccountAvatar(name: name),
          const SizedBox(width: MonthraSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
