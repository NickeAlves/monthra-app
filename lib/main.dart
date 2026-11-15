import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';

void main() {
  // Clean paths on the web: the email links are /verify-email#token=… and
  // /reset-password#token=…, with the token kept in the fragment.
  usePathUrlStrategy();
  LicenseRegistry.addLicense(_bundledFontLicenses);
  runApp(MonthraApp(env: Env.fromEnvironment()));
}

/// The fonts bundled in assets/fonts (OFL 1.1 asks for the notice).
Stream<LicenseEntry> _bundledFontLicenses() async* {
  final ofl = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Inter'], ofl);
}
