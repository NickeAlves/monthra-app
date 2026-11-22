import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// One entry of the sidebar: icon and label across the sidebar, or the
/// icon alone ([compact], the tablet's rail) with the label in a tooltip
/// (hover, long press or keyboard focus) and for screen readers. A
/// destination says whether it is [selected]; an action (sign out) leaves
/// it null.
class ShellNavItem extends StatefulWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected,
    this.compact = false,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool? selected;
  final bool compact;
  final bool enabled;

  /// A compact entry's tooltip: to its right, centered on it.
  static const ShadAnchorAuto besideAnchor = ShadAnchorAuto(
    offset: Offset(MonthraSpacing.x2, 0),
    followerAnchor: Alignment.centerRight,
    targetAnchor: Alignment.centerRight,
  );

  @override
  State<ShellNavItem> createState() => _ShellNavItemState();
}

class _ShellNavItemState extends State<ShellNavItem> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final selected = widget.selected ?? false;
    final iconColor = selected ? scheme.accentText : scheme.mutedForeground;
    final labelColor = selected ? scheme.foreground : scheme.mutedForeground;
    const size = MonthraLayout.minTouchTarget;
    Widget button(Widget? child, {required Widget icon}) => selected
        ? ShadButton.secondary(
            focusNode: _focus,
            enabled: widget.enabled,
            width: widget.compact ? size : double.infinity,
            height: size,
            padding: widget.compact ? EdgeInsets.zero : null,
            mainAxisAlignment: widget.compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            foregroundColor: labelColor,
            hoverForegroundColor: labelColor,
            onPressed: widget.onPressed,
            leading: child == null ? null : icon,
            child: child ?? icon,
          )
        : ShadButton.ghost(
            focusNode: _focus,
            enabled: widget.enabled,
            width: widget.compact ? size : double.infinity,
            height: size,
            padding: widget.compact ? EdgeInsets.zero : null,
            mainAxisAlignment: widget.compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            foregroundColor: labelColor,
            hoverForegroundColor: scheme.foreground,
            onPressed: widget.onPressed,
            leading: child == null ? null : icon,
            child: child ?? icon,
          );
    // One node: the button, its label and the selected state together.
    Widget item(Widget child) => MergeSemantics(
      child: Semantics(selected: widget.selected, button: true, child: child),
    );
    if (!widget.compact) {
      return item(
        button(
          ButtonLabel(widget.label),
          icon: Icon(widget.icon, size: 20, color: iconColor),
        ),
      );
    }
    return ShadTooltip(
      focusNode: _focus,
      // Beside the rail, never over the entries above it.
      anchor: ShellNavItem.besideAnchor,
      builder: (_) => Text(widget.label),
      child: item(
        button(
          null,
          icon: Icon(
            widget.icon,
            size: 20,
            color: iconColor,
            semanticLabel: widget.label,
          ),
        ),
      ),
    );
  }
}
