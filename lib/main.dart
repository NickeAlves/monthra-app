import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Clean paths on the web: the email links are /verify-email#token=… and
  // /reset-password#token=…, with the token kept in the fragment.
  usePathUrlStrategy();
  LicenseRegistry.addLicense(_bundledFontLicenses);
  final env = Env.fromEnvironment();
  // Read while the splash shows, so the first frame already has the saved
  // theme and language.
  final store = await PreferencesStore.open();
  runApp(
    ProviderScope(
      overrides: appOverrides(env: env, preferences: store),
      child: MonthraApp(env: env),
    ),
  );
}

/// The fonts bundled in assets/fonts (OFL 1.1 asks for the notice).
Stream<LicenseEntry> _bundledFontLicenses() async* {
  final ofl = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
  yield LicenseEntryWithLineBreaks(const ['Inter'], ofl);
}
