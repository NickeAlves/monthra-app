import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
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

  group('security', () {
    test('changePassword sends both passwords', () async {
      final server = ProfileServer();
      final api = MeApi(fakeApi(server.adapter).api);

      await api.changePassword(current: testPassword, next: 'a new password');

      final sent = server.adapter.sent.single;
      expect('${sent.method} ${sent.path}', 'POST /api/v1/me/password');
      expect(sent.data, {
        'currentPassword': testPassword,
        'newPassword': 'a new password',
      });
      expect(server.password, 'a new password');
      await expectLater(
        api.changePassword(current: 'wrong', next: 'another password'),
        throwsA(
          isA<ApiProblemException>().having(
            (e) => e.code,
            'code',
            ProblemCode.passwordIncorrect,
          ),
        ),
      );
    });

    test('listSessions reads every session', () async {
      final server = ProfileServer();
      final sessions = await MeApi(fakeApi(server.adapter).api).listSessions();

      expect(sessions.map((s) => s.id), ['s-current', 's-phone']);
      final phone = sessions.last;
      expect(phone.current, isFalse);
      expect(phone.userAgent, 'Monthra (iOS)');
      expect(phone.ip, '198.51.100.20');
      expect(phone.lastUsedAt, DateTime.utc(2026, 11, 21, 8, 15));
      expect(phone.toString(), isNot(contains('198.51')));
    });

    test('revokeSession takes a session already gone as done', () async {
      final server = ProfileServer();
      final api = MeApi(fakeApi(server.adapter).api);

      await api.revokeSession('s-phone');
      await api.revokeSession('s-phone');

      expect(server.adapter.paths, [
        'DELETE /api/v1/me/sessions/s-phone',
        'DELETE /api/v1/me/sessions/s-phone',
      ]);
      expect(server.sessions.map((s) => s['id']), ['s-current']);

      server.fail(
        '/api/v1/me/sessions/s-current',
        Reply.problem(503, 'service_unavailable'),
      );
      await expectLater(
        api.revokeSession('s-current'),
        throwsA(isA<ApiProblemException>()),
      );
    });

    test('revokeOtherSessions keeps this one; a browser sends the CSRF '
        'token', () async {
      final server = ProfileServer();
      final api = MeApi(fakeApi(server.adapter, mode: SessionMode.cookie).api);

      await api.revokeOtherSessions();

      expect(server.adapter.paths, [
        'GET /api/v1/auth/csrf',
        'DELETE /api/v1/me/sessions',
      ]);
      expect(server.adapter.sent.last.headers['x-csrf-token'], 'csrf');
      expect(server.sessions.map((s) => s['id']), ['s-current']);
    });
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
    await expectLater(
      api.listSessions(),
      throwsA(isA<UnexpectedApiException>()),
    );
  });
}
