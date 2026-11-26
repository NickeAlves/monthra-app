import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/breakpoints.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/radii.dart';
import 'package:monthra/core/design_system/tokens/spacing.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The one lifted surface ("Silêncio"): a card with a 1 px border and no
/// shadow, for forms and for what must stand apart from the page. Lists,
/// figures and charts sit on the page in a `MonthraSection` instead.
///
/// The padding follows the breakpoint (16 on mobile, 20 above). With
/// [onTap], the card is a button: it takes keyboard focus (Enter or Space
/// activates it), darkens its border on hover and draws the focus ring.
class MonthraCard extends StatefulWidget {
  const new({
    this.title,
    this.description,
    this.trailing,
    this.footer,
    this.child,
    this.onTap,
    this.semanticLabel,
    this.padding,
    super.key,
  });

  final Widget? title;
  final Widget? description;

  /// Beside the title (an action, a badge).
  final Widget? trailing;
  final Widget? footer;
  final Widget? child;
  final VoidCallback? onTap;

  /// Read for a tappable card instead of its whole content.
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;

  @override
  State<MonthraCard> createState() => _MonthraCardState();
}

class _MonthraCardState extends State<MonthraCard> {
  bool _hovered = false;
  bool _focused = false;

  void _activate() => widget.onTap?.call();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final padding =
        widget.padding ??
        EdgeInsets.all(
          context.monthraBreakpoint == MonthraBreakpoint.mobile
              ? MonthraSpacing.x4
              : MonthraSpacing.x5,
        );
    // shadcn titles cards with h3; a card title stays below the figures it
    // introduces, like a section's.
    final titleWidget = widget.title;
    final title = titleWidget == null
        ? null
        : DefaultTextStyle.merge(
            style: theme.textTheme.title.copyWith(color: scheme.cardForeground),
            child: titleWidget,
          );
    final onTap = widget.onTap;
    final interactive = onTap != null;
    final borderColor = interactive && _hovered
        ? Color.lerp(scheme.border, scheme.foreground, 0.2)!
        : scheme.border;

    Widget card = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: borderColor),
      duration: MonthraMotion.of(context, MonthraMotion.fast),
      curve: MonthraMotion.curve,
      builder: (context, color, _) => ShadCard(
        title: title,
        description: widget.description,
        trailing: widget.trailing,
        footer: widget.footer,
        padding: padding,
        border: ShadBorder.all(color: color ?? borderColor, width: 1),
        child: widget.child,
      ),
    );
    if (!interactive) return card;

    card = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: MonthraRadii.lgAll,
        border: _focused ? Border.all(color: scheme.ring, width: 2) : null,
      ),
      child: card,
    );
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _activate,
          child: widget.semanticLabel == null
              ? card
              : ExcludeSemantics(child: card),
        ),
      ),
    );
  }
}
