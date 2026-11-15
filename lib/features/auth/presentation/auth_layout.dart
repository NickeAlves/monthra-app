import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The frame of the sign-in pages (user decisions of 2026-11-15): on a
/// desktop the brand panel on the left and the form on the right; on a
/// tablet or phone the form alone with the symbol on top. No theme or
/// language picker: before signing in the app follows the device, after it
/// the profile.
class AuthLayout extends StatelessWidget {
  const new({required this.child, super.key});

  /// The page's content: title, form and links.
  final Widget child;

  static const double formMaxWidth = 400;

  /// The symbol above the form on phones and tablets.
  static const double symbolSize = 48;

  /// The symbol beside the brand name on the desktop panel.
  static const double panelSymbolSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final desktop = context.monthraBreakpoint == MonthraBreakpoint.desktop;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final form = SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: MonthraSpacing.x4,
              vertical: MonthraSpacing.x10,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!desktop) ...[
                    const Center(child: _Symbol(size: symbolSize)),
                    const SizedBox(height: MonthraSpacing.x8),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return ColoredBox(
      color: theme.colorScheme.background,
      child: DefaultTextStyle(
        style: theme.textTheme.p.copyWith(color: theme.colorScheme.foreground),
        child: desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(child: _BrandPanel()),
                  Expanded(child: form),
                ],
              )
            : form,
      ),
    );
  }
}

/// The page title and the line under it.
class AuthHeading extends StatelessWidget {
  const new({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.only(bottom: MonthraSpacing.x6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.h3.copyWith(
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: MonthraSpacing.x2),
            Text(
              subtitle,
              style: theme.textTheme.p.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "New to Monthra? Create an account": a line with a link to the other
/// page of a pair (sign in, sign up).
class AuthSwitchLink extends StatelessWidget {
  const new({
    required this.text,
    required this.link,
    required this.onPressed,
    super.key,
  });

  final String text;
  final String link;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          text,
          style: theme.textTheme.p.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        ShadButton.link(onPressed: onPressed, child: ButtonLabel(link)),
      ],
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final ink = theme.colorScheme.primaryForeground;
    return ColoredBox(
      color: theme.colorScheme.primary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MonthraSpacing.x12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AuthLayout.formMaxWidth,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _Symbol(
                        size: AuthLayout.panelSymbolSize,
                        onPrimary: true,
                      ),
                      const SizedBox(width: MonthraSpacing.x3),
                      Text(
                        'Monthra',
                        style: theme.textTheme.h3.copyWith(color: ink),
                      ),
                    ],
                  ),
                  const SizedBox(height: MonthraSpacing.x8),
                  Text(
                    context.l10n.authTagline,
                    style: theme.textTheme.h2.copyWith(color: ink),
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

/// The brand symbol: green on the light theme, white on the dark theme and
/// on the green panel. Decorative (the brand name is written beside it, or
/// is the page's title).
class _Symbol extends StatelessWidget {
  const new({required this.size, this.onPrimary = false});

  final double size;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final white =
        onPrimary || ShadTheme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        white
            ? 'assets/brand/monthra-simbolo-branco.svg'
            : 'assets/brand/monthra-simbolo.svg',
        width: size,
        height: size,
      ),
    );
  }
}
