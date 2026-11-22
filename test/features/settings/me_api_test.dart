import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/features/settings/domain/preferences_patch.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';

void main() {
  test('updateName sends the name alone and reads the profile', () async {
    final server = ProfileServer();
    final api = MeApi(fakeApi(server.adapter).api);

    final me = await api.updateName('Bia');

    final sent = server.adapter.sent.single;
    expect('${sent.method} ${sent.path}', 'PATCH /api/v1/me');
    expect(sent.data, {'name': 'Bia'});
    expect(me, Me.fromJson(meJson(name: 'Bia')));
  });

  test('updatePreferences sends only the fields set', () async {
    final server = ProfileServer();
    final api = MeApi(fakeApi(server.adapter).api);

    final answer = await api.updatePreferences(
      const PreferencesPatch(
        locale: AppLocale.esEs,
        theme: ThemePreference.light,
        currency: Currency.eur,
        budgetAlerts: false,
      ),
    );
    expect(answer.locale, 'es-ES');
    expect(answer.budgetAlerts, isFalse);

    await api.updatePreferences(
      const PreferencesPatch(theme: ThemePreference.dark),
    );
    expect(server.preferencePatches, [
      {
        'locale': 'es-ES',
        'theme': 'light',
        'currency': 'EUR',
        'budgetAlerts': false,
      },
      {'theme': 'dark'},
    ]);
  });

  test('a browser sends the CSRF token', () async {
    final server = ProfileServer();
    final api = MeApi(fakeApi(server.adapter, mode: SessionMode.cookie).api);

    await api.updatePreferences(
      const PreferencesPatch(theme: ThemePreference.dark),
    );

    expect(server.adapter.paths, [
      'GET /api/v1/auth/csrf',
      'PATCH /api/v1/me/preferences',
    ]);
    expect(server.adapter.sent.last.headers['x-csrf-token'], 'csrf');
  });

  test('a body the app cannot read is unexpected', () async {
    final api = MeApi(
      fakeApi(FakeAdapter((_) => Reply.json({'theme': 42}))).api,
    );
    await expectLater(
      api.updatePreferences(
        const PreferencesPatch(theme: ThemePreference.dark),
      ),
      throwsA(isA<UnexpectedApiException>()),
    );
    await expectLater(
      api.updateName('Bia'),
      throwsA(isA<UnexpectedApiException>()),
    );
  });
}
