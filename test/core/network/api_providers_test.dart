import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/overrides.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';

import '../../helpers/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer container() => ProviderContainer.test(
    overrides: appOverrides(
      env: localEnv,
      preferences: MemoryPreferencesStore(),
    ),
  );

  test('the client talks to the env API root', () {
    final dio = container().read(apiDioProvider);
    expect(dio.options.baseUrl, 'http://localhost:8080/api/v1');
    expect(localEnv.apiRoot.toString(), 'http://localhost:8080/api/v1');
  });

  test('the API language follows the UI language', () async {
    final c = container();
    expect(c.read(apiLanguageProvider), c.read(appLocaleProvider).tag);

    await c.read(preferencesProvider.notifier).setLocale(AppLocale.esEs);
    expect(c.read(apiLanguageProvider), 'es-ES');
  });

  test('tests and the VM run as a device: Bearer tokens in secure '
      'storage', () {
    final c = container();
    expect(c.read(sessionModeProvider), SessionMode.bearer);
    expect(c.read(tokenStoreProvider), isA<SecureTokenStore>());
  });

  test('the web keeps no tokens', () {
    final c = ProviderContainer.test(
      overrides: [sessionModeProvider.overrideWithValue(SessionMode.cookie)],
    );
    expect(c.read(tokenStoreProvider), isA<NoTokenStore>());
  });

  test('session events reach every listener', () async {
    final events = container().read(sessionEventsProvider);
    final seen = <SessionEvent>[];
    events.stream.listen(seen.add);

    events.add(SessionEvent.expired);
    await Future<void>.delayed(Duration.zero);

    expect(seen, [SessionEvent.expired]);
  });

  test('env and the API language must come from main', () {
    final c = ProviderContainer.test();
    for (final read in [
      () => c.read(envProvider),
      () => c.read(apiLanguageProvider),
    ]) {
      expect(
        read,
        throwsA(
          isA<ProviderException>().having(
            (e) => e.exception,
            'exception',
            isA<StateError>(),
          ),
        ),
      );
    }
  });
}
