import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/dates/clock.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/core/forms/currency_select.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/money_field.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/features/accounts/application/accounts_provider.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/domain/card_cycle.dart';
import 'package:monthra/features/accounts/presentation/account_labels.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Opens the account form over the page: a new account, or [account]'s
/// changes. Answers the account as the server saved it (and shows a
/// toast), or null when the form was closed.
Future<Account?> showAccountForm(
  BuildContext context, {
  Account? account,
}) async {
  final l10n = context.l10n;
  final saved = await showMonthraFormSheet<Account>(
    context,
    barrierLabel: l10n.appClose,
    builder: (_) => AccountForm(account: account),
  );
  if (saved != null && context.mounted) {
    showMonthraToast(
      context,
      title: account == null ? l10n.accountFormCreated : l10n.accountFormSaved,
      closeLabel: l10n.appClose,
    );
  }
  return saved;
}

/// The fields of an account (`POST /accounts`, `PATCH /accounts/{id}`):
/// its name, type and currency (fixed once created), what it held before
/// any transaction and, for a credit card, the closing and due days and
/// the limit. The server stays the judge: its field errors show under the
/// fields.
class AccountForm extends ConsumerStatefulWidget {
  const new({this.account, super.key});

  /// The account being changed; null for a new one.
  final Account? account;

  @override
  ConsumerState<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<AccountForm> {
  final _form = GlobalKey<ShadFormState>();
  late final Account? _before = widget.account;
  late final TextEditingController _name = TextEditingController(
    text: _before?.name ?? '',
  );
  late AccountType _type = _before?.type ?? AccountType.checking;
  late Currency _currency = _before?.currency ?? _preferredCurrency;
  late final MoneyController _amount = MoneyController(
    minor: (_before?.initialBalance ?? 0).abs(),
  );

  /// A balance below zero for a checking account (an overdraft), above
  /// zero for a card (a credit): the uncommon sign of the type.
  late bool _flipped = switch (_before) {
    null => false,
    final a when a.type == AccountType.creditCard => a.initialBalance > 0,
    final a => a.initialBalance < 0,
  };
  late int? _closingDay = _before?.card?.closingDay;
  late int? _dueDay = _before?.card?.dueDay;
  late final MoneyController _limit = MoneyController(
    minor: _before?.card?.limit,
  );

  // What the form held when it opened, to tell a change.
  late final _Snapshot _opened = _snapshot();

  bool _busy = false;
  ApiException? _error;

  bool get _editing => _before != null;

  bool get _isCard => _type == AccountType.creditCard;

  Currency get _preferredCurrency =>
      switch (ref.read(authControllerProvider)) {
        SignedIn(:final me) => me.preferences.currencyValue,
        _ => null,
      } ??
      Currency.brl;

  /// The initial balance the form says, signed as the API keeps it.
  int get _initialBalance {
    final amount = _amount.minor ?? 0;
    if (_isCard) return _flipped ? amount : -amount;
    return _flipped ? -amount : amount;
  }

  CardSettings? get _card {
    final closing = _closingDay;
    final due = _dueDay;
    if (!_isCard || closing == null || due == null) return null;
    return CardSettings(closingDay: closing, dueDay: due, limit: _limit.minor);
  }

  _Snapshot _snapshot() => (
    name: _name.text.trim(),
    type: _type,
    currency: _currency,
    initialBalance: _initialBalance,
    closingDay: _closingDay,
    dueDay: _dueDay,
    limit: _limit.minor,
  );

  bool get _dirty => _snapshot() != _opened;

  ApiProblem? get _problem => switch (_error) {
    ApiProblemException(:final problem) => problem,
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    _name.addListener(_changed);
  }

  @override
  void dispose() {
    _name
      ..removeListener(_changed)
      ..dispose();
    _amount.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    final before = _before;
    final writes = ref.read(accountWritesProvider);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final Account saved;
      if (before == null) {
        saved = await writes.create(
          AccountDraft(
            name: _name.text.trim(),
            type: _type,
            currency: _currency,
            initialBalance: _initialBalance,
            card: _card,
          ),
        );
      } else {
        final changes = AccountChanges.between(
          before: before,
          name: _name.text.trim(),
          initialBalance: _initialBalance,
          card: _card,
        );
        saved = changes.isEmpty
            ? before
            : await writes.update(before.id, changes);
      }
      if (mounted) setState(() => _busy = false);
      navigator.pop(saved);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  /// The server's word on [field], until the field changes.
  String? _fieldError(String field, {int? max}) {
    final problem = _problem;
    if (problem == null) return null;
    return context.l10n.serverFieldError(problem, field, max: max);
  }

  static const List<String> _fields = [
    'name',
    'type',
    'currency',
    'initialBalance',
    'card',
    'card.closingDay',
    'card.dueDay',
    'card.limit',
  ];

  Widget? _alert(AppLocalizations l10n) {
    final error = _error;
    if (error == null) return null;
    if (error case ApiProblemException(code: ProblemCode.limitReached)) {
      return FormAlert(
        message: l10n.accountFormLimitReached,
        destructive: true,
        icon: LucideIcons.circleAlert,
      );
    }
    final problem = _problem;
    // Errors the fields below show need no alert.
    if (problem != null &&
        problem.errors.isNotEmpty &&
        problem.errors.every((e) => _fields.contains(e.field))) {
      return null;
    }
    return FormAlert.error(l10n.apiError(error));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = ShadTheme.of(context);
    final alert = _alert(l10n);
    const gap = SizedBox(height: MonthraSpacing.x4);
    return MonthraFormSheet(
      title: _editing ? l10n.accountFormEditTitle : l10n.accountsNew,
      description: _editing ? null : l10n.accountFormNewDescription,
      labels: (
        close: l10n.appClose,
        discardTitle: l10n.formDiscardTitle,
        discard: l10n.formDiscard,
        keepEditing: l10n.formKeepEditing,
      ),
      dirty: _dirty,
      busy: _busy,
      actions: [
        MonthraTapTarget(
          child: ShadButton.outline(
            enabled: !_busy,
            onPressed: () => Navigator.of(context).maybePop(),
            child: ButtonLabel(l10n.appCancel),
          ),
        ),
        MonthraTapTarget(
          child: ShadButton(
            enabled: !_busy,
            onPressed: _submit,
            child: ButtonLabel(
              _editing ? l10n.accountFormSave : l10n.accountFormCreate,
            ),
          ),
        ),
      ],
      child: ShadForm(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (alert != null) ...[alert, gap],
            ShadInputFormField(
              id: 'name',
              controller: _name,
              autofocus: !_editing,
              label: Text(l10n.accountFormName),
              validator: l10n.validateName,
              forceErrorText: _fieldError('name', max: AuthLimits.nameMax),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLength: AuthLimits.nameMax,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              onChanged: (_) {
                if (_fieldError('name') != null) {
                  setState(() => _error = null);
                }
              },
            ),
            gap,
            if (_editing)
              _FixedFacts(account: _before!)
            else ...[
              _Label(l10n.accountFormType),
              _TypeSelect(
                value: _type,
                onChanged: (type) => setState(() {
                  if ((type == AccountType.creditCard) != _isCard) {
                    _flipped = false;
                  }
                  _type = type;
                }),
              ),
              gap,
              _Label(l10n.accountFormCurrency),
              CurrencySelect(
                value: _currency,
                label: l10n.accountFormCurrency,
                onChanged: (currency) => setState(() => _currency = currency),
              ),
            ],
            gap,
            MoneyField(
              id: 'initialBalance',
              controller: _amount,
              currency: _currency,
              label: switch ((_isCard, _editing)) {
                (true, false) => l10n.accountFormCardDebt,
                (true, true) => l10n.accountFormCardDebtEdit,
                (false, _) => l10n.accountFormInitialBalance,
              },
              description: switch ((_isCard, _editing)) {
                (true, false) => l10n.accountFormCardDebtHint,
                (true, true) => l10n.accountFormCardDebtEditHint,
                (false, false) => l10n.accountFormInitialBalanceHint,
                (false, true) => l10n.accountFormInitialBalanceEditHint,
              },
              serverError: _fieldError('initialBalance'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: MonthraSpacing.x2),
            ShadSwitch(
              value: _flipped,
              onChanged: (value) => setState(() => _flipped = value),
              label: Text(
                _isCard ? l10n.accountFormCardCredit : l10n.accountFormNegative,
              ),
            ),
            if (_isCard) ...[
              gap,
              _CardFields(
                closingDay: _closingDay,
                dueDay: _dueDay,
                limit: _limit,
                currency: _currency,
                closingError:
                    _fieldError('card.closingDay') ?? _fieldError('card'),
                dueError: _fieldError('card.dueDay'),
                limitError: _fieldError('card.limit'),
                onClosingDay: (day) => setState(() => _closingDay = day),
                onDueDay: (day) => setState(() => _dueDay = day),
                onLimit: () => setState(() {}),
              ),
            ],
            if (_editing && _before!.archived) ...[
              gap,
              Text(
                l10n.accountsArchived,
                style: theme.textTheme.muted.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

typedef _Snapshot = ({
  String name,
  AccountType type,
  Currency currency,
  int initialBalance,
  int? closingDay,
  int? dueDay,
  int? limit,
});

/// A field's label above a control that has none of its own.
class _Label extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: MonthraSpacing.x2),
        child: Text(
          text,
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}

/// The type of a new account, each with its icon.
class _TypeSelect extends StatelessWidget {
  const new({required this.value, required this.onChanged});

  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget option(AccountType type) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(accountTypeIcon(type), size: 16),
        const SizedBox(width: MonthraSpacing.x2),
        Flexible(
          child: Text(
            accountTypeLabel(l10n, type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return Semantics(
      container: true,
      button: true,
      label: l10n.accountFormType,
      child: ShadSelect<AccountType>(
        initialValue: value,
        options: [
          for (final type in AccountType.creatable)
            ShadOption(value: type, child: option(type)),
        ],
        selectedOptionBuilder: (_, type) => option(type),
        onChanged: (type) {
          if (type != null && type != value) onChanged(type);
        },
      ),
    );
  }
}

/// What an account keeps for life, shown while it is edited.
class _FixedFacts extends StatelessWidget {
  const new({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    return MergeSemantics(
      child: Row(
        children: [
          Icon(
            accountTypeIcon(account.type),
            size: 16,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: MonthraSpacing.x2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${accountTypeLabel(l10n, account.type)} · '
                  '${account.currency.code}',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.foreground,
                  ),
                ),
                Text(
                  l10n.accountFormFixed,
                  style: theme.textTheme.muted.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A card's closing and due days, its limit and what they mean for the
/// next invoice.
class _CardFields extends ConsumerWidget {
  const new({
    required this.closingDay,
    required this.dueDay,
    required this.limit,
    required this.currency,
    required this.closingError,
    required this.dueError,
    required this.limitError,
    required this.onClosingDay,
    required this.onDueDay,
    required this.onLimit,
  });

  final int? closingDay;
  final int? dueDay;
  final MoneyController limit;
  final Currency currency;
  final String? closingError;
  final String? dueError;
  final String? limitError;
  final ValueChanged<int?> onClosingDay;
  final ValueChanged<int?> onDueDay;
  final VoidCallback onLimit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ShadTheme.of(context);
    final closing = closingDay;
    final due = dueDay;
    String? preview;
    if (closing != null && due != null) {
      final cycle = CardSettings(closingDay: closing, dueDay: due);
      final invoice = cycle.invoiceFor(ref.watch(clockProvider)());
      final format = DisplayFormat.of(context);
      preview = l10n.accountFormCyclePreview(
        format.day(cycle.closingDate(invoice)),
        format.day(cycle.dueDate(invoice)),
      );
    }
    final days = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DaySelect(
            id: 'closingDay',
            label: l10n.accountFormClosingDay,
            value: closingDay,
            serverError: closingError,
            onChanged: onClosingDay,
          ),
        ),
        const SizedBox(width: MonthraSpacing.x4),
        Expanded(
          child: _DaySelect(
            id: 'dueDay',
            label: l10n.accountFormDueDay,
            value: dueDay,
            serverError: dueError,
            onChanged: onDueDay,
          ),
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        days,
        const SizedBox(height: MonthraSpacing.x1),
        Text(
          preview ?? l10n.accountFormDayHint,
          style: theme.textTheme.muted.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: MonthraSpacing.x4),
        MoneyField(
          id: 'limit',
          controller: limit,
          currency: currency,
          label: l10n.accountFormLimit,
          description: l10n.accountFormLimitHint,
          serverError: limitError,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onLimit(),
        ),
      ],
    );
  }
}

/// A day of the month, 1 to 31.
class _DaySelect extends StatelessWidget {
  const new({
    required this.id,
    required this.label,
    required this.value,
    required this.serverError,
    required this.onChanged,
  });

  final String id;
  final String label;
  final int? value;
  final String? serverError;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The form field loosens the width it gets: fill the half of the row
    // (never under the room "Día 31" and the chevron need).
    return LayoutBuilder(
      builder: (context, constraints) => Semantics(
        container: true,
        button: true,
        label: label,
        child: ShadSelectFormField<int>(
          id: id,
          label: Text(label),
          initialValue: value,
          minWidth: constraints.maxWidth < 120 ? 120 : constraints.maxWidth,
          placeholder: Text(l10n.accountFormDayPlaceholder),
          forceErrorText: serverError,
          validator: (day) =>
              day == null ? l10n.fieldError(FieldCode.required) : null,
          options: [
            for (
              var day = CardSettings.minDay;
              day <= CardSettings.maxDay;
              day++
            )
              ShadOption(value: day, child: Text(l10n.accountFormDay(day))),
          ],
          selectedOptionBuilder: (_, day) => Text(l10n.accountFormDay(day)),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
