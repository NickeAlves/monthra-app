import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/accounts/application/accounts_provider.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/domain/accounts_view.dart';
import 'package:monthra/features/accounts/presentation/account_form.dart';
import 'package:monthra/features/accounts/presentation/widgets/account_tile.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/l10n/currency_names.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The accounts page (`/accounts`): the open accounts by currency, each
/// group with its total on the device's today, and the archived ones on
/// request. A row opens the account; "New account" opens the form.
class AccountsPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  bool _showArchived = false;

  Future<void> _create() async {
    final account = await showAccountForm(context);
    if (account != null && mounted) {
      context.go(AppRoutes.account(account.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preferred = ref.watch(
      authControllerProvider.select(
        (s) => s is SignedIn ? s.me.preferences.currencyValue : null,
      ),
    );
    final state = ref.watch(accountsProvider);
    final accounts = state.value;
    final Widget body;
    if (accounts != null) {
      final view = AccountsView.build(accounts, preferred: preferred);
      body = view.isEmpty
          ? EmptyState(
              icon: LucideIcons.wallet,
              title: l10n.accountsEmptyTitle,
              message: l10n.accountsEmptyMessage,
              action: ShadButton(
                onPressed: _create,
                leading: const Icon(LucideIcons.plus),
                child: ButtonLabel(l10n.accountsCreateFirst),
              ),
            )
          : _AccountsList(
              view: view,
              showArchived: _showArchived,
              onToggleArchived: () =>
                  setState(() => _showArchived = !_showArchived),
            );
    } else if (state case AsyncError(:final error)) {
      body = ErrorState(
        title: l10n.accountsLoadError,
        message: error is ApiException ? l10n.apiError(error).message : null,
        onRetry: () => ref.invalidate(accountsProvider),
        retryLabel: l10n.appRetry,
      );
    } else {
      body = const AccountsSkeleton();
    }
    return MonthraPage(
      title: l10n.accountsTitle,
      description: l10n.accountsDescription,
      actions: [
        if (accounts?.isNotEmpty ?? false)
          ShadButton(
            onPressed: _create,
            leading: const Icon(LucideIcons.plus),
            child: ButtonLabel(l10n.accountsNew),
          ),
      ],
      child: body,
    );
  }
}

class _AccountsList extends StatelessWidget {
  const new({
    required this.view,
    required this.showArchived,
    required this.onToggleArchived,
  });

  final AccountsView view;
  final bool showArchived;
  final VoidCallback onToggleArchived;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final narrow = context.monthraBreakpoint == MonthraBreakpoint.mobile;
    final gap = narrow ? MonthraSpacing.x6 : MonthraSpacing.x8;
    void open(String id) => context.go(AppRoutes.account(id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, group) in view.groups.indexed) ...[
          if (i > 0) SizedBox(height: gap),
          MonthraSection(
            // The first group sits right under the page's title.
            divider: i > 0,
            title: Text(l10n.currencyName(group.currency)),
            trailing: _GroupTotal(group: group),
            child: _Tiles(accounts: group.accounts, onOpen: open),
          ),
        ],
        if (view.archived.isNotEmpty) ...[
          SizedBox(height: gap),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShadButton.ghost(
              onPressed: onToggleArchived,
              leading: Icon(
                showArchived ? LucideIcons.chevronUp : LucideIcons.archive,
              ),
              child: ButtonLabel(
                showArchived
                    ? l10n.accountsHideArchived
                    : l10n.accountsShowArchived(view.archived.length),
              ),
            ),
          ),
          if (showArchived) ...[
            const SizedBox(height: MonthraSpacing.x2),
            MonthraSection(
              title: Text(l10n.accountsArchivedTitle),
              child: _Tiles(accounts: view.archived, onOpen: open),
            ),
          ],
        ],
      ],
    );
  }
}

class _GroupTotal extends StatelessWidget {
  const new({required this.group});

  final CurrencyAccounts group;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.l10n.accountsGroupTotal(group.currency.code),
            style: theme.textTheme.caption.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AmountText(
            group.total,
            currency: group.currency,
            alignment: AlignmentDirectional.centerEnd,
          ),
        ],
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const new({required this.accounts, required this.onOpen});

  final List<Account> accounts;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final account in accounts)
        AccountTile(account: account, onPressed: () => onOpen(account.id)),
    ],
  );
}

/// The accounts page's shape while it loads, read once as "loading".
class AccountsSkeleton extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: true,
    label: context.l10n.accountsLoading,
    child: ExcludeSemantics(
      child: MonthraSection(
        divider: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Skeleton(width: 160),
            for (var i = 0; i < 3; i++) ...[
              const SizedBox(height: MonthraSpacing.x6),
              const Row(
                children: [
                  Skeleton(width: 36, height: 36),
                  SizedBox(width: MonthraSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 140, height: MonthraSpacing.x3),
                        SizedBox(height: MonthraSpacing.x2),
                        Skeleton(width: 96, height: MonthraSpacing.x3),
                      ],
                    ),
                  ),
                  Skeleton(width: 88),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
