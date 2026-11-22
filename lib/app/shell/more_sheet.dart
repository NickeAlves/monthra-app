import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:monthra/app/shell/shell_destinations.dart';
import 'package:monthra/app/shell/widgets/account_avatar.dart';
import 'package:monthra/app/shell/widgets/nav_item.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// What the person picked in the "More" sheet.
sealed class MoreChoice {
  const new();
}

final class MoreDestination extends MoreChoice {
  const new(this.destination);

  final ShellDestination destination;
}

final class MoreSignOut extends MoreChoice {
  const new();
}

final class MoreCatalog extends MoreChoice {
  const new();
}

/// The phone's "More" (a bottom sheet, not a page: it gathers destinations
/// of several branches): who is signed in, the destinations kept off the
/// bar, the catalog outside production and signing out. It closes with the
/// choice, and the shell acts on it after (a branch change would leave a
/// sheet above the shell).
Future<MoreChoice?> showMoreSheet(
  BuildContext context, {
  required ShellDestination current,
  required Me? account,
  required bool catalog,
}) => showShadSheet<MoreChoice>(
  context: context,
  side: ShadSheetSide.bottom,
  barrierLabel: context.l10n.appClose,
  builder: (_) =>
      _MoreSheet(current: current, account: account, catalog: catalog),
);

class _MoreSheet extends StatelessWidget {
  const new({
    required this.current,
    required this.account,
    required this.catalog,
  });

  final ShellDestination current;
  final Me? account;
  final bool catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = this.account;
    void close(MoreChoice choice) => Navigator.of(context).pop(choice);
    const gap = SizedBox(height: MonthraSpacing.x1);
    return Semantics(
      role: SemanticsRole.dialog,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l10n.navMore,
      child: ShadSheet(
        title: Text(l10n.navMore),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        scrollable: true,
        closeIcon: ShadIconButton.ghost(
          width: MonthraLayout.minTouchTarget,
          height: MonthraLayout.minTouchTarget,
          icon: Icon(LucideIcons.x, size: 16, semanticLabel: l10n.appClose),
          onPressed: () => Navigator.of(context).pop(),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: MonthraSpacing.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (account != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MonthraSpacing.x2,
                  ),
                  child: AccountSummary(
                    name: account.name,
                    email: account.email,
                  ),
                ),
                const ShadSeparator.horizontal(
                  margin: EdgeInsets.symmetric(vertical: MonthraSpacing.x4),
                ),
              ],
              for (final d in ShellDestination.more) ...[
                ShellNavItem(
                  icon: d.icon,
                  label: d.label(l10n),
                  selected: d == current,
                  onPressed: () => close(MoreDestination(d)),
                ),
                gap,
              ],
              const ShadSeparator.horizontal(
                margin: EdgeInsets.symmetric(vertical: MonthraSpacing.x2),
              ),
              if (catalog) ...[
                ShellNavItem(
                  icon: LucideIcons.palette,
                  label: l10n.shellDesignSystem,
                  onPressed: () => close(const MoreCatalog()),
                ),
                gap,
              ],
              ShellNavItem(
                icon: LucideIcons.logOut,
                label: l10n.shellSignOut,
                onPressed: () => close(const MoreSignOut()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
