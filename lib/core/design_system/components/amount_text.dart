import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/tokens/colors.dart';
import 'package:monthra/core/design_system/tokens/motion.dart';
import 'package:monthra/core/design_system/tokens/typography.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// What an amount means, which sets its color and sign.
enum AmountKind {
  /// A balance or a total: the text color, a minus only when negative.
  neutral,

  /// Money in: soft green and a plus.
  income,

  /// Money out: soft red and a minus (the API sends it positive).
  expense,
}

/// The type scale of an amount (tabular figures in every size).
enum AmountSize { display, title, body, small }

/// An amount in minor units, formatted in the locale (`R$ 1.234,56`).
///
/// It never cuts digits: a value wider than its slot scales down. With
/// [animate], a new value counts from the one shown before (minor unit by
/// minor unit), unless the platform asks for less motion; assistive
/// technologies only ever read the final value.
class AmountText extends StatelessWidget {
  const new(
    this.minor, {
    required this.currency,
    this.kind = AmountKind.neutral,
    this.size = AmountSize.body,
    this.sign,
    this.animate = false,
    this.locale,
    this.alignment = AlignmentDirectional.centerStart,
    super.key,
  });

  /// The amount in cents, signed for [AmountKind.neutral]; income and
  /// expense amounts are shown by their absolute value.
  final int minor;
  final Currency currency;
  final AmountKind kind;
  final AmountSize size;

  /// Overrides the sign the [kind] implies.
  final MoneySign? sign;
  final bool animate;

  /// Defaults to the app's locale.
  final Locale? locale;
  final AlignmentGeometry alignment;

  /// The signed value shown: expenses below zero, income above.
  int get shownValue => switch (kind) {
    AmountKind.neutral => minor,
    AmountKind.income => minor.abs(),
    AmountKind.expense => -minor.abs(),
  };

  MoneySign get effectiveSign =>
      sign ?? (kind == AmountKind.neutral ? MoneySign.auto : MoneySign.always);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final style =
        switch (size) {
          AmountSize.display => text.amountDisplay,
          AmountSize.title => text.amountTitle,
          AmountSize.body => text.amount,
          AmountSize.small => text.amountSmall,
        }.copyWith(
          color: switch (kind) {
            AmountKind.neutral => scheme.foreground,
            AmountKind.income => scheme.income,
            AmountKind.expense => scheme.expense,
          },
        );
    final effectiveLocale =
        locale ??
        Localizations.maybeLocaleOf(context) ??
        const Locale('pt', 'BR');
    String format(int value) => MoneyFormat.format(
      value,
      currency,
      effectiveLocale,
      sign: effectiveSign,
    );

    final value = shownValue;
    final Widget child;
    if (animate) {
      child = Semantics(
        label: format(value),
        child: ExcludeSemantics(
          child: TweenAnimationBuilder<int>(
            tween: IntTween(begin: value, end: value),
            duration: MonthraMotion.of(context, MonthraMotion.number),
            curve: MonthraMotion.curve,
            builder: (context, shown, _) =>
                Text(format(shown), style: style, maxLines: 1),
          ),
        ),
      );
    } else {
      child = Text(format(value), style: style, maxLines: 1);
    }
    return FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: child);
  }
}
