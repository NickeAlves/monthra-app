import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/l10n/currency_names.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Picks one of the account currencies, named in the UI language with its
/// code. Shows [value] (none when null) and follows it when it changes.
class CurrencySelect extends StatefulWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final Currency? value;
  final ValueChanged<Currency> onChanged;

  /// Read out by assistive technologies ("Default currency").
  final String label;

  @override
  State<CurrencySelect> createState() => _CurrencySelectState();
}

class _CurrencySelectState extends State<CurrencySelect> {
  // Room for the longest name (es: "Dólar estadounidense (USD)") beside
  // the chevron.
  static const double _minWidth = 280;

  late final ShadSelectController<Currency> _controller = ShadSelectController(
    initialValue: {?widget.value},
  );

  @override
  void didUpdateWidget(CurrencySelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.value = {?widget.value};
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      button: true,
      label: widget.label,
      child: ShadSelect<Currency>(
        controller: _controller,
        minWidth: _minWidth,
        options: [
          for (final currency in Currency.values)
            ShadOption(
              value: currency,
              child: Text(l10n.currencyName(currency)),
            ),
        ],
        selectedOptionBuilder: (context, currency) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.coins, size: 16),
            const SizedBox(width: MonthraSpacing.x2),
            Flexible(
              child: Text(
                l10n.currencyName(currency),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onChanged: (currency) {
          if (currency != null && currency != widget.value) {
            widget.onChanged(currency);
          }
        },
      ),
    );
  }
}
