import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/components/button_label.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Nothing to show yet: a list without items, a month without data.
/// Texts come translated from the screen.
class EmptyState extends StatelessWidget {
  const new({
    required this.title,
    this.message,
    this.icon = LucideIcons.inbox,
    this.action,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// Usually a button that creates the first item.
  final Widget? action;

  @override
  Widget build(BuildContext context) =>
      _StateMessage(icon: icon, title: title, message: message, action: action);
}

/// A load that failed, with a way to try again. Announced to assistive
/// technologies when it appears.
class ErrorState extends StatelessWidget {
  const new({
    required this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  }) : assert(
         (onRetry == null) == (retryLabel == null),
         'onRetry and retryLabel go together',
       );

  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final label = retryLabel;
    return Semantics(
      liveRegion: true,
      child: _StateMessage(
        icon: LucideIcons.circleAlert,
        title: title,
        message: message,
        action: retry == null || label == null
            ? null
            : ShadButton.outline(
                onPressed: retry,
                leading: const Icon(LucideIcons.rotateCw),
                child: ButtonLabel(label),
              ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final message = this.message;
    final action = this.action;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: MonthraLayout.maxMessageWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(MonthraSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: SizedBox.square(
                  dimension: MonthraSpacing.x12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: MonthraSpacing.x6,
                      color: scheme.mutedForeground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: MonthraSpacing.x4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.large.copyWith(color: scheme.foreground),
              ),
              if (message != null) ...[
                const SizedBox(height: MonthraSpacing.x1),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted.copyWith(
                    color: scheme.mutedForeground,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: MonthraSpacing.x6),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
