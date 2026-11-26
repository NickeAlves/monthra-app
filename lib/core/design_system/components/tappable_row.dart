import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// A row of a list that opens something: one button for assistive
/// technologies (its content read together), a tap or Enter/Space
/// activates it, the pointer and keyboard focus highlight it. At least a
/// touch target tall.
class TappableRow extends StatefulWidget {
  const new({required this.child, required this.onPressed, super.key});

  final Widget child;
  final VoidCallback onPressed;

  @override
  State<TappableRow> createState() => _TappableRowState();
}

class _TappableRowState extends State<TappableRow> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowHoverHighlight: (v) => setState(() => _hovered = v),
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onPressed();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: MonthraMotion.of(context, MonthraMotion.fast),
              curve: MonthraMotion.curve,
              constraints: const BoxConstraints(
                minHeight: MonthraLayout.minTouchTarget,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: MonthraSpacing.x3,
                vertical: MonthraSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: _hovered || _focused ? scheme.muted : null,
                borderRadius: MonthraRadii.mdAll,
                border: Border.all(
                  color: _focused ? scheme.ring : const Color(0x00000000),
                  width: 2,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
