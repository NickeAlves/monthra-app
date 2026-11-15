import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';

/// The values `main` reads before `runApp` and the wiring between core and
/// the features: the one list the app and its tests start from.
List<Override> appOverrides({
  required Env env,
  required PreferencesStore preferences,
}) => [
  envProvider.overrideWithValue(env),
  preferencesStoreProvider.overrideWithValue(preferences),
  // The API answers in the UI language (§7.6).
  apiLanguageProvider.overrideWith((ref) => ref.watch(appLocaleProvider).tag),
];
