import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/features/dashboard/presentation/dashboard_page.dart';
import 'package:monthra/features/settings/presentation/data/delete_account_page.dart';
import 'package:monthra/features/settings/presentation/data/export_data_page.dart';
import 'package:monthra/features/settings/presentation/security/change_password_page.dart';
import 'package:monthra/features/settings/presentation/security/disable_mfa_page.dart';
import 'package:monthra/features/settings/presentation/security/enable_mfa_page.dart';
import 'package:monthra/features/settings/presentation/security/recovery_codes_exit.dart';
import 'package:monthra/features/settings/presentation/security/regenerate_recovery_codes_page.dart';
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
    dashboard => DashboardPage(month: DashboardPage.monthOf(state.uri)),
    settings => const SettingsPage(),
  };

  /// Pages under [path] (a detail, a flow of its own): the destination
  /// stays selected on them. Their paths are relative to [path].
  List<RouteBase> get routes => switch (this) {
    dashboard => const [],
    settings => [
      GoRoute(
        path: _under(AppRoutes.settingsPassword),
        builder: (_, _) => const ChangePasswordPage(),
      ),
      // Both show recovery codes once: leaving them unsaved asks first.
      GoRoute(
        path: _under(AppRoutes.settingsMfaEnable),
        onExit: confirmLeavingRecoveryCodes,
        builder: (_, _) => const EnableMfaPage(),
      ),
      GoRoute(
        path: _under(AppRoutes.settingsMfaDisable),
        builder: (_, _) => const DisableMfaPage(),
      ),
      GoRoute(
        path: _under(AppRoutes.settingsRecoveryCodes),
        onExit: confirmLeavingRecoveryCodes,
        builder: (_, _) => const RegenerateRecoveryCodesPage(),
      ),
      GoRoute(
        path: _under(AppRoutes.settingsExport),
        builder: (_, _) => const ExportDataPage(),
      ),
      GoRoute(
        path: _under(AppRoutes.settingsDeleteAccount),
        builder: (_, _) => const DeleteAccountPage(),
      ),
    ],
  };

  /// [route] relative to [path] (`/settings/password` -> `password`).
  String _under(String route) {
    assert(route.startsWith('$path/'), '$route is not under $path');
    return route.substring(path.length + 1);
  }

  static List<ShellDestination> get bar => [
    for (final d in values)
      if (d.mobile == ShellPlacement.bar) d,
  ];

  static List<ShellDestination> get more => [
    for (final d in values)
      if (d.mobile == ShellPlacement.more) d,
  ];
}
