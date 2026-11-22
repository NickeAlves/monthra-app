import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One entry of the bottom bar.
@immutable
class ShellBarEntry {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;
}

/// The phone's navigation (§4.4): the bar destinations and "More", with
/// [centerAction] (the new-transaction button, with the transactions PR)
/// in the middle. Entries keep a bounded width, centered, so a short bar
/// does not stretch across the screen.
class ShellBottomBar extends StatelessWidget {
  const new({
    required this.entries,
    required this.label,
    this.centerAction,
    super.key,
  });

  final List<ShellBarEntry> entries;

  /// The navigation's name for screen readers.
  final String label;
  final Widget? centerAction;

  static const double maxEntryWidth = 120;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final items = <Widget>[
      for (final entry in entries)
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: maxEntryWidth),
            child: _BarItem(entry),
          ),
        ),
    ];
    final center = centerAction;
    if (center != null) items.insert(items.length ~/ 2, center);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.background,
        border: Border(top: BorderSide(color: scheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: MonthraLayout.bottomBarMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MonthraSpacing.x2,
              vertical: MonthraSpacing.x1,
            ),
            // Labels grow up to 1.5x; the full text stays in semantics.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.5,
              child: Semantics(
                role: SemanticsRole.navigation,
                label: label,
                container: true,
                explicitChildNodes: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatefulWidget {
  const new(this.entry);

  final ShellBarEntry entry;

  @override
  State<_BarItem> createState() => _BarItemState();
}

class _BarItemState extends State<_BarItem> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final entry = widget.entry;
    final selected = entry.selected;
    final duration = MonthraMotion.of(context, MonthraMotion.fast);
    final pill = selected
        ? scheme.secondary
        : (_hovered ? scheme.muted : scheme.secondary.withValues(alpha: 0));
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                entry.onPressed();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: entry.onPressed,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: MonthraLayout.bottomBarMinHeight - MonthraSpacing.x2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: MonthraSpacing.x1,
                vertical: MonthraSpacing.x1,
              ),
              decoration: BoxDecoration(
                borderRadius: MonthraRadii.mdAll,
                border: Border.all(
                  color: _focused
                      ? scheme.ring
                      : scheme.ring.withValues(alpha: 0),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: MonthraMotion.curve,
                    padding: const EdgeInsets.symmetric(
                      horizontal: MonthraSpacing.x4,
                      vertical: MonthraSpacing.x1,
                    ),
                    decoration: BoxDecoration(
                      color: pill,
                      borderRadius: MonthraRadii.pillAll,
                    ),
                    child: Icon(
                      entry.icon,
                      size: 20,
                      color: selected
                          ? scheme.accentText
                          : scheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x1),
                  Text(
                    entry.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.small.copyWith(
                      fontSize: 12,
                      color: selected
                          ? scheme.foreground
                          : scheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
