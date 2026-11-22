import 'dart:async';

import 'package:flutter/semantics.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/app/shell/more_sheet.dart';
import 'package:monthra/app/shell/shell_bottom_bar.dart';
import 'package:monthra/app/shell/shell_destinations.dart';
import 'package:monthra/app/shell/shell_sidebar.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The frame of every signed-in page (§4.4): the sidebar on a desktop, its
/// icons on a tablet, the bottom bar on a phone, around [shell] (the
/// branch shown). It also signs out, and reports the preference changes
/// the profile refused, wherever the person is.
class AppShell extends ConsumerStatefulWidget {
  const new({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _signingOut = false;

  ShellDestination get _current =>
      ShellDestination.values[widget.shell.currentIndex];

  /// Goes to [destination], where it was left; the one shown goes back to
  /// its first page.
  void _select(ShellDestination destination) => widget.shell.goBranch(
    destination.index,
    initialLocation: destination == _current,
  );

  void _openCatalog() => unawaited(context.push(AppRoutes.designSystem));

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } on ApiException catch (e) {
      // Only on the web: its cookies only go away through the server.
      if (mounted) {
        final l10n = context.l10n;
        final error = l10n.apiError(e);
        final reference = error.reference;
        showMonthraToast(
          context,
          title: l10n.shellSignOutFailed,
          description: reference == null
              ? error.message
              : '${error.message}\n${l10n.errorReference(reference)}',
          destructive: true,
          closeLabel: l10n.appClose,
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  Future<void> _openMore() async {
    final choice = await showMoreSheet(
      context,
      current: _current,
      account: _account,
      catalog: _catalog,
    );
    if (!mounted) return;
    switch (choice) {
      case MoreDestination(:final destination):
        _select(destination);
      case MoreSignOut():
        await _signOut();
      case MoreCatalog():
        _openCatalog();
      case null:
        break;
    }
  }

  Me? get _account => switch (ref.read(authControllerProvider)) {
    SignedIn(:final me) => me,
    _ => null,
  };

  bool get _catalog => catalogEnabled(ref.read(envProvider));

  void _onPreferenceFailure(PreferenceSaveFailure? failure) {
    if (failure == null || !mounted) return;
    final l10n = context.l10n;
    showMonthraToast(
      context,
      title: l10n.settingsSaveFailed,
      description: l10n.apiError(failure.error).message,
      destructive: true,
      closeLabel: l10n.appClose,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      profileControllerProvider.select((s) => s.failure),
      (_, failure) => _onPreferenceFailure(failure),
    );
    final l10n = context.l10n;
    final scheme = ShadTheme.of(context).colorScheme;
    final account = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me : null),
    );
    final catalog = catalogEnabled(ref.watch(envProvider));
    final breakpoint = context.monthraBreakpoint;
    // No Scaffold here: the content makes room for the keyboard itself.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final content = Semantics(
      role: SemanticsRole.main,
      container: true,
      explicitChildNodes: true,
      child: FocusTraversalGroup(
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboard),
          child: widget.shell,
        ),
      ),
    );
    final current = _current;
    return ColoredBox(
      color: scheme.background,
      child: switch (breakpoint) {
        MonthraBreakpoint.mobile => Column(
          children: [
            Expanded(child: SafeArea(bottom: false, child: content)),
            if (keyboard == 0)
              FocusTraversalGroup(
                child: ShellBottomBar(
                  label: l10n.shellNavigationLabel,
                  entries: [
                    for (final d in ShellDestination.bar)
                      ShellBarEntry(
                        icon: d.icon,
                        label: d.label(l10n),
                        selected: d == current,
                        onPressed: () => _select(d),
                      ),
                    ShellBarEntry(
                      icon: LucideIcons.ellipsis,
                      label: l10n.navMore,
                      selected: current.mobile == ShellPlacement.more,
                      onPressed: () => unawaited(_openMore()),
                    ),
                  ],
                ),
              ),
          ],
        ),
        MonthraBreakpoint.tablet || MonthraBreakpoint.desktop => SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusTraversalGroup(
                child: ShellSidebar(
                  expanded: breakpoint == MonthraBreakpoint.desktop,
                  current: current,
                  onSelect: _select,
                  account: account,
                  signingOut: _signingOut,
                  onSignOut: () => unawaited(_signOut()),
                  onCatalog: catalog ? _openCatalog : null,
                ),
              ),
              Expanded(child: content),
            ],
          ),
        ),
      },
    );
  }
}
