import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:monthra/app/shell/shell_destinations.dart';
import 'package:monthra/app/shell/widgets/account_avatar.dart';
import 'package:monthra/app/shell/widgets/nav_item.dart';
import 'package:monthra/app/shell/widgets/shell_brand.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The side menu (§4.4): every destination with its label on a desktop
/// ([expanded]), icons only on a tablet. The account and the way out sit
/// at the bottom; the whole column scrolls when the window is short.
class ShellSidebar extends StatelessWidget {
  const new({
    required this.expanded,
    required this.current,
    required this.onSelect,
    required this.account,
    required this.onSignOut,
    required this.signingOut,
    this.onCatalog,
    super.key,
  });

  final bool expanded;
  final ShellDestination current;
  final ValueChanged<ShellDestination> onSelect;

  /// Null for the frame of a sign-out.
  final Me? account;
  final VoidCallback onSignOut;
  final bool signingOut;

  /// Opens the design system catalog (outside production only).
  final VoidCallback? onCatalog;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    final l10n = context.l10n;
    final compact = !expanded;
    final padding = EdgeInsets.symmetric(
      horizontal: expanded
          ? MonthraSpacing.x4
          : (MonthraLayout.railWidth - MonthraLayout.minTouchTarget) / 2,
      vertical: MonthraSpacing.x4,
    );
    final account = this.account;
    final onCatalog = this.onCatalog;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.background,
        border: BorderDirectional(end: BorderSide(color: scheme.border)),
      ),
      child: SizedBox(
        width: expanded ? MonthraLayout.sidebarWidth : MonthraLayout.railWidth,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding.copyWith(bottom: 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: expanded
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: expanded ? MonthraSpacing.x2 : 0,
                        vertical: MonthraSpacing.x2,
                      ),
                      child: Align(
                        alignment: expanded
                            ? AlignmentDirectional.centerStart
                            : Alignment.center,
                        child: ShellBrand(compact: compact),
                      ),
                    ),
                    const SizedBox(height: MonthraSpacing.x6),
                    Semantics(
                      role: SemanticsRole.navigation,
                      label: l10n.shellNavigationLabel,
                      container: true,
                      explicitChildNodes: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, d)
                              in ShellDestination.values.indexed) ...[
                            if (i > 0)
                              const SizedBox(height: MonthraSpacing.x1),
                            ShellNavItem(
                              icon: d.icon,
                              label: d.label(l10n),
                              selected: d == current,
                              compact: compact,
                              onPressed: () => onSelect(d),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: expanded
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: MonthraSpacing.x6),
                    if (onCatalog != null) ...[
                      ShellNavItem(
                        icon: LucideIcons.palette300,
                        label: l10n.shellDesignSystem,
                        compact: compact,
                        onPressed: onCatalog,
                      ),
                      const SizedBox(height: MonthraSpacing.x2),
                    ],
                    const ShadSeparator.horizontal(
                      margin: EdgeInsets.symmetric(vertical: MonthraSpacing.x2),
                    ),
                    if (expanded)
                      Row(
                        children: [
                          Expanded(
                            child: account == null
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      start: MonthraSpacing.x2,
                                    ),
                                    child: AccountSummary(
                                      name: account.name,
                                      email: account.email,
                                    ),
                                  ),
                          ),
                          ShellNavItem(
                            icon: LucideIcons.logOut300,
                            label: l10n.shellSignOut,
                            compact: true,
                            enabled: !signingOut,
                            onPressed: onSignOut,
                          ),
                        ],
                      )
                    else ...[
                      if (account != null)
                        Semantics(
                          label: l10n.shellSignedInAs(account.name),
                          child: ShadTooltip(
                            anchor: ShellNavItem.besideAnchor,
                            builder: (_) => Text(account.name),
                            child: AccountAvatar(name: account.name),
                          ),
                        ),
                      const SizedBox(height: MonthraSpacing.x2),
                      ShellNavItem(
                        icon: LucideIcons.logOut300,
                        label: l10n.shellSignOut,
                        compact: true,
                        enabled: !signingOut,
                        onPressed: onSignOut,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
