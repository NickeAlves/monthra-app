import 'dart:ui' show Locale;

/// The UI languages (§7.6), the same three the API answers in
/// (server: `i18n.Supported`). pt-BR is the default.
enum AppLocale {
  ptBr(Locale('pt', 'BR'), 'Português (Brasil)'),
  esEs(Locale('es', 'ES'), 'Español (España)'),
  enUs(Locale('en', 'US'), 'English (US)');

  new(this.locale, this.nativeName);

  /// The language for a device without a choice: the first of [device]
  /// (in the user's order) whose language is Portuguese, Spanish or
  /// English, whatever its region, as the server's matcher does
  /// (pt-PT → pt-BR, es-MX → es-ES, en-GB → en-US); pt-BR otherwise.
  factory resolve(Iterable<Locale> device) {
    for (final locale in device) {
      final match = _byLanguage[locale.languageCode];
      if (match != null) return match;
    }
    return fallback;
  }

  static const AppLocale fallback = ptBr;

  /// The language tag the API stores and reads (`pt-BR`), also sent as
  /// `Accept-Language`; null when [tag] is not one of the three.
  static AppLocale? fromTag(String? tag) => _byTag[tag];

  static final Map<String, AppLocale> _byTag = {
    for (final l in values) l.tag: l,
  };

  static final Map<String, AppLocale> _byLanguage = {
    for (final l in values) l.locale.languageCode: l,
  };

  /// The locale the UI formats and translates with.
  final Locale locale;

  /// The language's own name, the same in every UI language (people look
  /// for their language as they write it), so it lives here, not in the
  /// ARB files.
  final String nativeName;

  /// `pt-BR`, `es-ES` or `en-US`.
  String get tag => locale.toLanguageTag();

  /// The locales the app declares, in [values] order (pt-BR first).
  static List<Locale> get supportedLocales => [
    for (final l in values) l.locale,
  ];
}
