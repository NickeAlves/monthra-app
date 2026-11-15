import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/app.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

import 'frame.dart';

/// A boot hint the app saved (see `PumpMonthraApp.pumpMonthraApp`).
typedef SavedBootHint = ({String languageTag, String? theme});

final Env localEnv = Env(
  appEnv: AppEnv.local,
  apiBaseUrl: Uri.parse('http://localhost:8080'),
);

extension PumpMonthraApp on WidgetTester {
  /// Pumps the whole app as `main` does, with [store] in place of the
  /// device's preferences; the web boot hints it saves go to [bootHints].
  Future<void> pumpMonthraApp({
    Env? env,
    PreferencesStore? store,
    List<SavedBootHint>? bootHints,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [
          preferencesStoreProvider.overrideWithValue(
            store ?? MemoryPreferencesStore(),
          ),
        ],
        child: MonthraApp(
          env: env ?? localEnv,
          saveBootHint: ({required languageTag, theme}) =>
              bootHints?.add((languageTag: languageTag, theme: theme)),
        ),
      ),
    );
    await pumpUntilLocalized(appHome, appContainer.read(appLocaleProvider));
  }

  /// The home page: the catalog, or the brand page in production.
  Finder get appHome => find.byWidgetPredicate(
    (w) => w is DesignSystemCatalog || w is PlaceholderPage,
  );

  /// The app's provider container.
  ProviderContainer get appContainer =>
      ProviderScope.containerOf(element(find.byType(MonthraApp)));
}
