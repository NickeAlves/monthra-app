import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/format/display_format.dart';
import 'package:monthra/features/accounts/data/models/account.dart';
import 'package:monthra/features/accounts/presentation/account_labels.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The icon of an account type on a muted square, as lists show it.
class AccountTypeIcon extends StatelessWidget {
  const new(this.type, {super.key});

  final AccountType type;

  @override
  Widget build(BuildContext context) {
    final scheme = ShadTheme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.muted,
        borderRadius: MonthraRadii.mdAll,
      ),
      child: SizedBox.square(
        dimension: CategoryIconSize.md.box,
        child: Icon(
          accountTypeIcon(type),
          size: CategoryIconSize.md.glyph,
          color: scheme.mutedForeground,
        ),
      ),
    );
  }
}

/// One account in a list: its type's icon, name, type (and, for a card,
/// the due day and the limit left), badges, and its balance on `asOf`. A
/// tap (or Enter) opens it.
class AccountTile extends StatelessWidget {
  const new({required this.account, required this.onPressed, super.key});

  final Account account;
  final VoidCallback onPressed;

  /// The row's width (at 1x text) under which the balance goes below the
  /// name.
  static const double stackBelow = 300;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final format = DisplayFormat.of(context);
    final card = account.card;
    final available = account.availableLimit;
    final details = [
      accountTypeLabel(l10n, account.type),
      if (card != null) l10n.accountsCardDue(card.dueDay),
      if (available != null)
        l10n.accountsCardAvailable(format.money(available, account.currency)),
    ].join(' · ');
    final caption = theme.textTheme.caption.copyWith(
      color: scheme.mutedForeground,
    );
    final amount = AmountText(
      account.balance,
      currency: account.currency,
      alignment: AlignmentDirectional.centerEnd,
    );
    return TappableRow(
      onPressed: onPressed,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A large text size on a narrow screen puts the balance under
          // the name rather than squeeze both.
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final stacked = constraints.maxWidth < stackBelow * scale;
          return Row(
            children: [
              AccountTypeIcon(account.type),
              const SizedBox(width: MonthraSpacing.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      maxLines: stacked ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.label.copyWith(
                        color: scheme.foreground,
                      ),
                    ),
                    Wrap(
                      spacing: MonthraSpacing.x2,
                      runSpacing: MonthraSpacing.x1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(details, style: caption),
                        if (account.archived)
                          ShadBadge.outline(child: Text(l10n.accountsArchived)),
                        if (account.source == AccountSource.openFinance)
                          ShadBadge.secondary(
                            child: Text(l10n.accountsImported),
                          ),
                      ],
                    ),
                    if (stacked) ...[
                      const SizedBox(height: MonthraSpacing.x1),
                      amount,
                    ],
                  ],
                ),
              ),
              if (!stacked) ...[
                const SizedBox(width: MonthraSpacing.x3),
                amount,
              ],
              const SizedBox(width: MonthraSpacing.x2),
              ExcludeSemantics(
                child: Icon(
                  LucideIcons.chevronRight300,
                  size: 16,
                  color: scheme.mutedForeground,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
