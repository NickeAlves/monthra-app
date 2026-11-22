import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/features/settings/presentation/settings_page.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Where a destination sits on a phone: in the bottom bar, or in the list
/// "More" opens. Tablets and desktops list every destination.
enum ShellPlacement { bar, more }

/// The pages of the app shell, one navigation branch each (its own history
/// and scroll position): the one place a feature adds its page.
///
/// Only pages that exist are listed (user decision of 2026-11-22). The
/// order of the values is the order of the sidebar and of the phone's bar,
/// whose final shape is Dashboard, Transactions, (+), Budgets, More: the
/// new-transaction button lands with the transactions PR, in the middle of
/// the bar (`ShellBottomBar.centerAction`).
enum ShellDestination {
  dashboard(AppRoutes.home, LucideIcons.layoutDashboard, ShellPlacement.bar),
  settings(AppRoutes.settings, LucideIcons.settings, ShellPlacement.more);

  new(this.path, this.icon, this.mobile);

  /// The branch's first page.
  final String path;
  final IconData icon;
  final ShellPlacement mobile;

  String label(AppLocalizations l10n) => switch (this) {
    dashboard => l10n.navDashboard,
    settings => l10n.navSettings,
  };

  Widget page(GoRouterState state) => switch (this) {
    dashboard => const HomePage(),
    settings => const SettingsPage(),
  };

  /// Pages under [path] (a detail, a flow of its own): the destination
  /// stays selected on them.
  List<RouteBase> get routes => const [];

  static List<ShellDestination> get bar => [
    for (final d in values)
      if (d.mobile == ShellPlacement.bar) d,
  ];

  static List<ShellDestination> get more => [
    for (final d in values)
      if (d.mobile == ShellPlacement.more) d,
  ];
}
