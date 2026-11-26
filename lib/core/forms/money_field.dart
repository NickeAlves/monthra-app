import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// An amount being typed, in minor units, never negative: a form shows the
/// sign apart (a switch, the kind of a transaction). Null while the field
/// is empty.
///
/// The text is the amount in the UI locale (`1.234,56`), written by the
/// [MoneyField] that holds this controller, so set [minor], never `text`.
/// A form follows the amount through the field's `onChanged`, not as a
/// listener of the controller (the field writes the text as it builds).
final class MoneyController extends TextEditingController {
  new({int? minor}) : _initial = minor;

  // The amount until a field gives the locale to write it in.
  int? _initial;
  Currency _currency = Currency.brl;
  Locale? _locale;

  /// The amount shown, or null when the field is empty.
  int? get minor => _locale == null ? _initial : _parse(text);

  set minor(int? value) {
    assert(value == null || value >= 0, 'the sign lives outside the field');
    if (_locale == null) {
      _initial = value;
      return;
    }
    _write(value);
  }

  static final RegExp _nonDigits = RegExp('[^0-9]');

  static int? _parse(String text) {
    final digits = text.replaceAll(_nonDigits, '');
    return digits.isEmpty ? null : int.parse(digits);
  }

  bool get _attached => _locale != null;

  bool _differs(Currency currency, Locale locale) =>
      currency != _currency || locale != _locale;

  void _attach(Currency currency, Locale locale) {
    if (!_differs(currency, locale)) return;
    final amount = minor;
    _currency = currency;
    _locale = locale;
    _write(amount);
  }

  void _write(int? amount) {
    final locale = _locale!;
    final text = amount == null
        ? ''
        : MoneyFormat.number(amount, _currency, locale);
    value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Fills an amount from the right as digits are typed, the way bank apps
/// do (`1`, `2`, `3` -> `1,23`): only digits count, so the keypad never
/// needs the decimal key (whose separator follows the device's region, not
/// the app's language) and a pasted `1.234,56` or `1234.56` keeps its
/// digits. Removing a separator removes the digit before it. Refuses an
/// amount above [max]. The caret stays at the end.
final class MoneyInputFormatter extends TextInputFormatter {
  new({
    required this.currency,
    required this.locale,
    this.max = MoneyFormat.maxMinor,
  });

  final Currency currency;
  final Locale locale;
  final int max;

  // More digits than any amount up to 10^13 (and than an int holds).
  static const int _maxDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(MoneyController._nonDigits, '');
    final oldDigits = oldValue.text.replaceAll(MoneyController._nonDigits, '');
    // A separator went, not a digit: take the digit with it.
    if (newValue.text.length < oldValue.text.length &&
        digits == oldDigits &&
        digits.isNotEmpty) {
      digits = digits.substring(0, digits.length - 1);
    }
    if (digits.isEmpty) return TextEditingValue.empty;
    if (digits.length > _maxDigits) return oldValue;
    final amount = int.parse(digits);
    if (amount > max) return oldValue;
    // Deleting down to nothing empties the field (`0,0` would stay `0,00`).
    if (amount == 0 && newValue.text.length < oldValue.text.length) {
      return TextEditingValue.empty;
    }
    final text = MoneyFormat.number(amount, currency, locale);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// An amount field ([MoneyController]) in [currency]: its symbol before
/// the number, `0,00` as the placeholder, the digit keypad, the amount
/// filled from the right (see [MoneyInputFormatter]). [validator] gets the
/// amount (null when empty); [serverError] is what the server said about
/// the field.
class MoneyField extends StatefulWidget {
  const new({
    required this.id,
    required this.controller,
    required this.currency,
    required this.label,
    this.description,
    this.validator,
    this.serverError,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    super.key,
  });

  /// The field's id in its `ShadForm`.
  final String id;
  final MoneyController controller;
  final Currency currency;
  final String label;
  final String? description;
  final String? Function(int? minor)? validator;
  final String? serverError;
  final ValueChanged<int?>? onChanged;
  final ValueChanged<int?>? onSubmitted;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(MoneyField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach();
  }

  // The first write happens before the field builds, when nothing listens
  // yet; a later one (another language) waits for the frame to end, since
  // a form above may listen and cannot rebuild in the middle of a build.
  void _attach() {
    final controller = widget.controller;
    final locale = Localizations.localeOf(context);
    if (!controller._attached) {
      controller._attach(widget.currency, locale);
    } else if (controller._differs(widget.currency, locale)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.controller._attach(
          widget.currency,
          Localizations.localeOf(context),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final locale = Localizations.localeOf(context);
    final description = widget.description;
    final validator = widget.validator;
    return ShadInputFormField(
      id: widget.id,
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      label: Text(widget.label),
      description: description == null ? null : Text(description),
      forceErrorText: widget.serverError,
      validator: validator == null
          ? null
          : (_) => validator(widget.controller.minor),
      placeholder: Text(MoneyFormat.number(0, widget.currency, locale)),
      leading: Text(
        MoneyFormat.symbolIn(widget.currency, locale),
        style: theme.textTheme.muted.copyWith(
          color: theme.colorScheme.mutedForeground,
        ),
      ),
      style: theme.textTheme.amount.copyWith(
        color: theme.colorScheme.foreground,
      ),
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        MoneyInputFormatter(currency: widget.currency, locale: locale),
      ],
      onChanged: (_) => widget.onChanged?.call(widget.controller.minor),
      onSubmitted: (_) => widget.onSubmitted?.call(widget.controller.minor),
    );
  }
}
