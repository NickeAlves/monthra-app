/// The currencies an account can hold (server: `domain.Currency`). Each
/// account has one, fixed at creation; amounts are never converted.
enum Currency {
  brl('BRL'),
  usd('USD'),
  eur('EUR');

  new(this.code);

  /// Parses an ISO 4217 code from the API.
  factory fromCode(String code) {
    final currency = _byCode[code];
    if (currency == null) {
      throw FormatException('unsupported currency', code);
    }
    return currency;
  }

  /// The currency of [code], or null when it is not one of the three.
  static Currency? tryCode(String? code) => _byCode[code];

  static final Map<String, Currency> _byCode = {
    for (final c in values) c.code: c,
  };

  /// The ISO 4217 code, as the API sends it.
  final String code;

  /// Minor units per major unit: amounts travel in cents.
  int get minorPerMajor => 100;

  int get decimalDigits => 2;
}
