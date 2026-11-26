import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/dates/year_month.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/accounts/application/accounts_provider.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/data/models/invoice.dart';
import 'package:monthra/features/accounts/domain/card_cycle.dart';
import 'package:monthra/features/accounts/presentation/account_form.dart';
import 'package:monthra/features/accounts/presentation/account_labels.dart';
import 'package:monthra/features/accounts/presentation/accounts_page.dart';
import 'package:monthra/features/accounts/presentation/widgets/account_tile.dart';
import 'package:monthra/features/accounts/presentation/widgets/invoice_views.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The page of one account (`/accounts/:id`): its balance today (and with
/// the future transactions), and for a credit card its limit and invoices
/// (`?invoice=YYYY-MM` picks one; the one open today by default). Edit,
/// archive (or bring back) and delete it from the header. The statement
/// comes with the transactions.
class AccountDetailPage extends ConsumerStatefulWidget {
  const new({required this.id, this.invoice, super.key});

  final String id;

  /// The invoice the address asks for; null for the open one.
  final YearMonth? invoice;

  /// The invoice [uri] asks for (`?invoice=`).
  static YearMonth? invoiceOf(Uri uri) =>
      YearMonth.tryParse(uri.queryParameters['invoice']);

  /// The address of account [id] showing [invoice] (none for [open]).
  static String location(String id, YearMonth invoice, YearMonth open) =>
      invoice == open
      ? AppRoutes.account(id)
      : Uri(
          path: AppRoutes.account(id),
          queryParameters: {'invoice': invoice.toString()},
        ).toString();

  @override
  ConsumerState<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends ConsumerState<AccountDetailPage> {
  bool _busy = false;

  AppLocalizations get _l10n => context.l10n;

  void _toast(String title, {String? description, bool destructive = false}) {
    if (!mounted) return;
    showMonthraToast(
      context,
      title: title,
      description: description,
      closeLabel: _l10n.appClose,
      destructive: destructive,
    );
  }

  void _failed(ApiException error) => _toast(
    _l10n.accountDetailActionFailed,
    description: switch (error) {
      ApiProblemException(code: ProblemCode.usedByRecurrence) =>
        _l10n.accountUsedByRecurrence,
      ApiProblemException(code: ProblemCode.accountInUse) =>
        _l10n.accountInUseTitle,
      _ => _l10n.apiError(error).message,
    },
    destructive: true,
  );

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on ApiException catch (e) {
      _failed(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _archive(Account account, {required bool archived}) =>
      _run(() async {
        await ref
            .read(accountWritesProvider)
            .archive(account.id, archived: archived);
        _toast(
          archived
              ? _l10n.accountDetailArchivedToast
              : _l10n.accountDetailUnarchivedToast,
        );
      });

  Future<void> _delete(Account account) async {
    final l10n = _l10n;
    final confirmed = await showMonthraConfirm(
      context,
      title: l10n.accountDeleteTitle,
      description: l10n.accountDeleteMessage,
      confirmLabel: l10n.accountDetailDelete,
      cancelLabel: l10n.appCancel,
      barrierLabel: l10n.appClose,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(() async {
      try {
        await ref.read(accountWritesProvider).delete(account.id);
      } on ApiProblemException catch (e) {
        if (e.code != ProblemCode.accountInUse || account.archived) rethrow;
        if (!mounted) return;
        // It holds history: offer to archive it instead.
        final archive = await showMonthraConfirm(
          context,
          title: l10n.accountInUseTitle,
          description: l10n.accountInUseMessage,
          confirmLabel: l10n.accountDetailArchive,
          cancelLabel: l10n.appCancel,
          barrierLabel: l10n.appClose,
        );
        if (!archive) return;
        await ref
            .read(accountWritesProvider)
            .archive(account.id, archived: true);
        _toast(l10n.accountDetailArchivedToast);
        return;
      }
      _toast(l10n.accountDeletedToast);
      if (mounted) context.go(AppRoutes.accounts);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(accountsProvider);
    final accounts = state.value;
    final back = MonthraPageBack(
      label: l10n.accountsTitle,
      onPressed: () => context.go(AppRoutes.accounts),
    );
    if (accounts == null) {
      return MonthraPage(
        title: l10n.accountsTitle,
        back: back,
        child: switch (state) {
          AsyncError(:final error) => ErrorState(
            title: l10n.accountsLoadError,
            message: error is ApiException
                ? l10n.apiError(error).message
                : null,
            onRetry: () => ref.invalidate(accountsProvider),
            retryLabel: l10n.appRetry,
          ),
          _ => const AccountsSkeleton(),
        },
      );
    }
    final account = accounts.where((a) => a.id == widget.id).firstOrNull;
    if (account == null) {
      return MonthraPage(
        title: l10n.accountNotFoundTitle,
        back: back,
        child: EmptyState(
          icon: LucideIcons.searchX,
          title: l10n.accountNotFoundTitle,
          message: l10n.accountNotFoundMessage,
          action: ShadButton.outline(
            onPressed: back.onPressed,
            child: ButtonLabel(l10n.accountBackToAccounts),
          ),
        ),
      );
    }
    final narrow = context.monthraBreakpoint == MonthraBreakpoint.mobile;
    final gap = narrow ? MonthraSpacing.x4 : MonthraSpacing.x6;
    final card = account.card;
    return MonthraPage(
      title: account.name,
      description:
          '${accountTypeLabel(l10n, account.type)} · ${account.currency.code}',
      back: back,
      actions: [
        ShadButton.outline(
          enabled: !_busy,
          onPressed: () =>
              unawaited(showAccountForm(context, account: account)),
          leading: const Icon(LucideIcons.pencil),
          child: ButtonLabel(l10n.accountDetailEdit),
        ),
        ShadButton.outline(
          enabled: !_busy,
          onPressed: () =>
              unawaited(_archive(account, archived: !account.archived)),
          leading: Icon(
            account.archived ? LucideIcons.archiveRestore : LucideIcons.archive,
          ),
          child: ButtonLabel(
            account.archived
                ? l10n.accountDetailUnarchive
                : l10n.accountDetailArchive,
          ),
        ),
        ShadButton.ghost(
          enabled: !_busy,
          onPressed: () => unawaited(_delete(account)),
          foregroundColor: ShadTheme.of(context).colorScheme.destructive,
          hoverForegroundColor: ShadTheme.of(context).colorScheme.destructive,
          leading: const Icon(LucideIcons.trash2),
          child: ButtonLabel(l10n.accountDetailDelete),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (account.archived) ...[
            FormAlert(
              message: l10n.accountDetailArchivedNotice,
              icon: LucideIcons.archive,
            ),
            SizedBox(height: gap),
          ],
          _BalanceCard(account: account),
          if (card != null && account.isCard) ...[
            SizedBox(height: gap),
            _LimitCard(account: account, card: card),
            SizedBox(height: gap),
            _InvoicesCard(
              account: account,
              card: card,
              requested: widget.invoice,
            ),
          ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const new({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    return MonthraCard(
      child: Row(
        children: [
          AccountTypeIcon(account.type),
          const SizedBox(width: MonthraSpacing.x4),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountDetailBalance,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x1),
                  AmountText(
                    account.balance,
                    currency: account.currency,
                    size: AmountSize.title,
                  ),
                  if (account.projectedBalance != account.balance) ...[
                    const SizedBox(height: MonthraSpacing.x1),
                    Text(
                      l10n.accountDetailProjected(
                        format.money(
                          account.projectedBalance,
                          account.currency,
                        ),
                      ),
                      style: theme.textTheme.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A card's limit, how much of it the debt (installments to come
/// included) takes, and its closing and due days.
class _LimitCard extends StatelessWidget {
  const new({required this.account, required this.card});

  final Account account;
  final CardSettings card;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final limit = card.limit;
    final available = account.availableLimit;
    final muted = theme.textTheme.small.copyWith(color: scheme.mutedForeground);
    String money(int minor) => format.money(minor, account.currency);
    return MonthraCard(
      title: Text(l10n.accountCardLimit),
      trailing: limit == null
          ? null
          : AmountText(
              limit,
              currency: account.currency,
              alignment: AlignmentDirectional.centerEnd,
            ),
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (limit == null || available == null)
              Text(l10n.accountCardNoLimit, style: muted)
            else ...[
              ExcludeSemantics(
                child: ShadProgress(
                  value: limit == 0
                      ? 1
                      : (account.cardDebt / limit).clamp(0, 1).toDouble(),
                  color: available < 0 ? scheme.destructive : scheme.primary,
                ),
              ),
              const SizedBox(height: MonthraSpacing.x2),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: MonthraSpacing.x3,
                runSpacing: MonthraSpacing.x1,
                children: [
                  Text(
                    l10n.accountCardUsed(money(account.cardDebt)),
                    style: muted,
                  ),
                  Text(
                    available < 0
                        ? l10n.accountCardOverLimit(money(-available))
                        : l10n.accountsCardAvailable(money(available)),
                    style: muted.copyWith(
                      color: available < 0
                          ? scheme.destructive
                          : scheme.foreground,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: MonthraSpacing.x3),
            Text(
              l10n.accountCardCycle(card.closingDay, card.dueDay),
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}

/// A card's invoices: the one in focus in full, with the months around it
/// (five before, six after) in a list. One request per stretch of months;
/// while another stretch loads, the last one stays, dimmed.
class _InvoicesCard extends ConsumerStatefulWidget {
  const new({
    required this.account,
    required this.card,
    required this.requested,
  });

  final Account account;
  final CardSettings card;
  final YearMonth? requested;

  @override
  ConsumerState<_InvoicesCard> createState() => _InvoicesCardState();
}

class _InvoicesCardState extends ConsumerState<_InvoicesCard> {
  List<Invoice>? _shown;

  static YearMonth _clamp(YearMonth m) => m < YearMonth.min
      ? YearMonth.min
      : (m > YearMonth.max ? YearMonth.max : m);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final open = widget.card.invoiceFor(ref.watch(clockProvider)());
    final focus = widget.requested ?? open;
    final from = _clamp(focus.addMonths(-5));
    final to = _clamp(focus.addMonths(6));
    final provider = invoicesProvider(widget.account.id, from, to);
    final state = ref.watch(provider);
    final invoices = state.value;
    if (invoices != null) _shown = invoices;
    final shown = invoices ?? (state.isLoading ? _shown : null);
    final waiting = invoices == null;
    void go(YearMonth month) =>
        context.go(AccountDetailPage.location(widget.account.id, month, open));

    final Widget body;
    final focused = shown?.where((i) => i.month == focus).firstOrNull;
    if (shown != null && (focused != null || waiting)) {
      body = Semantics(
        container: true,
        label: waiting ? l10n.invoicesLoading : null,
        liveRegion: waiting,
        child: ExcludeSemantics(
          excluding: waiting,
          child: IgnorePointer(
            ignoring: waiting,
            child: AnimatedOpacity(
              opacity: waiting ? 0.5 : 1,
              duration: MonthraMotion.of(context, MonthraMotion.fast),
              curve: MonthraMotion.curve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (focused != null) InvoiceSummary(invoice: focused),
                  const SizedBox(height: MonthraSpacing.x6),
                  Text(
                    l10n.invoicesAround,
                    style: ShadTheme.of(context).textTheme.label.copyWith(
                      color: ShadTheme.of(context).colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x2),
                  InvoiceList(invoices: shown, selected: focus, onSelected: go),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (state case AsyncError(:final error)) {
      body = ErrorState(
        title: l10n.invoicesLoadError,
        message: error is ApiException ? l10n.apiError(error).message : null,
        onRetry: () => ref.invalidate(provider),
        retryLabel: l10n.appRetry,
      );
    } else {
      body = Semantics(
        container: true,
        liveRegion: true,
        label: l10n.invoicesLoading,
        child: const ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Skeleton(width: 200),
              SizedBox(height: MonthraSpacing.x4),
              Skeleton(height: 160),
            ],
          ),
        ),
      );
    }
    return MonthraCard(
      title: Text(l10n.invoicesTitle),
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              // Pinned like the dashboard's: the arrows never move.
              alignment:
                  MonthSwitcher.defaultAnchor(context) ==
                      MonthSwitcherAnchor.end
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: MonthSwitcher(
                month: focus,
                current: open,
                onChanged: go,
                labels: (
                  previous: l10n.invoicesPrevious,
                  next: l10n.invoicesNext,
                  current: l10n.invoicesOpen,
                ),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x4),
            body,
          ],
        ),
      ),
    );
  }
}
