import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/accounts/application/accounts_provider.dart';
import 'package:monthra/features/accounts/presentation/account_form.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/categories/application/categories_provider.dart';
import 'package:monthra/features/dashboard/application/dashboard_providers.dart';
import 'package:monthra/features/dashboard/domain/dashboard_view.dart';
import 'package:monthra/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:monthra/features/dashboard/presentation/widgets/dashboard_skeleton.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The dashboard (§1.2), the app's first page: the month's balance, income
/// and expenses, the split by category, 12 months of cash flow and net
/// worth, and each account's balance, by currency and never converted.
///
/// `/?month=YYYY-MM` picks the month (a link or the browser's back moves
/// it too); without it, or with a month the API does not take, the
/// device's current month shows. While another month loads, the last one
/// stays on screen, dimmed.
class DashboardPage extends ConsumerStatefulWidget {
  const new({this.month, super.key});

  /// The month the address asks for; null for the current one.
  final YearMonth? month;

  /// The month [uri] asks for (`?month=`), null for the current one.
  static YearMonth? monthOf(Uri uri) =>
      YearMonth.tryParse(uri.queryParameters['month']);

  /// The address of [month]'s dashboard: `/` for [current].
  static String location(YearMonth month, YearMonth current) => month == current
      ? AppRoutes.home
      : Uri(
          path: AppRoutes.home,
          queryParameters: {'month': month.toString()},
        ).toString();

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  /// What showed last, kept on screen (dimmed) while another month loads.
  DashboardView? _shown;

  void _refresh(YearMonth month) {
    ref
      ..invalidate(dashboardSummaryProvider(month))
      ..invalidate(accountsProvider)
      ..invalidate(categoriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = YearMonth.of(ref.watch(clockProvider)());
    final month = widget.month ?? current;
    final name = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.name : ''),
    );
    final provider = dashboardViewProvider(month);
    // A refresh that fails keeps the figures it had: say so in a toast.
    ref.listen(provider, (_, next) {
      if (next case AsyncError(:final error) when next.hasValue) {
        showMonthraToast(
          context,
          title: l10n.dashboardLoadError,
          description: error is ApiException
              ? l10n.apiError(error).message
              : null,
          closeLabel: l10n.appClose,
          destructive: true,
        );
      }
    });
    final state = ref.watch(provider);
    final view = state.value;
    if (view != null) _shown = view;

    // The last month shown stays, dimmed, while another one loads.
    final shown = view ?? (state.isLoading ? _shown : null);
    final waiting = view == null;
    final Widget body;
    if (shown != null) {
      body = Semantics(
        container: true,
        label: waiting ? l10n.dashboardLoading : null,
        liveRegion: waiting,
        child: ExcludeSemantics(
          excluding: waiting,
          child: IgnorePointer(
            ignoring: waiting,
            child: AnimatedOpacity(
              opacity: waiting ? 0.5 : 1,
              duration: MonthraMotion.of(context, MonthraMotion.fast),
              curve: MonthraMotion.curve,
              child: _content(shown),
            ),
          ),
        ),
      );
    } else if (state case AsyncError(:final error)) {
      body = ErrorState(
        title: l10n.dashboardLoadError,
        message: error is ApiException ? l10n.apiError(error).message : null,
        onRetry: () => _refresh(month),
        retryLabel: l10n.appRetry,
      );
    } else {
      body = const DashboardSkeleton();
    }

    return MonthraPage(
      title: l10n.dashboardGreeting(name),
      actions: [
        MonthSwitcher(
          month: month,
          current: current,
          onChanged: (next) =>
              context.go(DashboardPage.location(next, current)),
          labels: (
            previous: l10n.dashboardPreviousMonth,
            next: l10n.dashboardNextMonth,
            current: l10n.dashboardThisMonth,
          ),
        ),
        MonthraTapTarget(
          child: ShadIconButton.outline(
            onPressed: state.isLoading ? null : () => _refresh(month),
            icon: Icon(
              LucideIcons.refreshCw,
              semanticLabel: l10n.dashboardRefresh,
            ),
          ),
        ),
      ],
      child: body,
    );
  }

  Widget _content(DashboardView view) {
    final l10n = context.l10n;
    if (!view.hasAccounts) {
      return EmptyState(
        icon: LucideIcons.wallet,
        title: l10n.dashboardEmptyTitle,
        message: l10n.dashboardEmptyMessage,
        action: MonthraTapTarget(
          child: ShadButton(
            onPressed: () => showAccountForm(context),
            leading: const Icon(LucideIcons.plus),
            child: ButtonLabel(l10n.accountsCreateFirst),
          ),
        ),
      );
    }
    return DashboardLayout(view: view);
  }
}
