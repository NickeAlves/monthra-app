import 'package:flutter/widgets.dart';
import 'package:monthra/l10n/generated/app_localizations.dart';

export 'package:monthra/l10n/generated/app_localizations.dart';

/// `context.l10n.themeDark`: the UI strings of the current language.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
