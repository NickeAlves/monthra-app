import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/core/network/api_problem.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/features/settings/data/mfa_api.dart';

import '../../helpers/auth_fixtures.dart';
import '../../helpers/fake_api.dart';
import '../../helpers/profile_server.dart';

Matcher problem(ProblemCode code) =>
    throwsA(isA<ApiProblemException>().having((e) => e.code, 'code', code));

void main() {
  test('setup, then enable with a first code', () async {
    final server = ProfileServer();
    final api = MfaApi(fakeApi(server.adapter).api);

    await expectLater(
      api.setup('wrong'),
      problem(ProblemCode.passwordIncorrect),
    );
    final setup = await api.setup(testPassword);
    expect(setup.secret, testMfaSecret);
    expect(setup.otpauthUri, testOtpauthUri);
    expect(setup.expiresIn, 900);
    expect(setup.toString(), isNot(contains(testMfaSecret)));

    await expectLater(
      api.enable('000000'),
      problem(ProblemCode.mfaCodeInvalid),
    );
    final codes = await api.enable(testTotp);
    expect(codes, hasLength(10));
    expect(codes, server.recoveryCodes);

    expect(server.adapter.paths, [
      for (final path in ['setup', 'setup', 'enable', 'enable'])
        'POST /api/v1/auth/mfa/$path',
    ]);
    expect(server.adapter.sent[1].data, {'password': testPassword});
    expect(server.adapter.sent[3].data, {'code': testTotp});
    await expectLater(
      api.setup(testPassword),
      problem(ProblemCode.mfaAlreadyEnabled),
    );
  });

  test('new recovery codes and disable take the password and a code', () async {
    final server = ProfileServer(me: meJson(mfa: true));
    final api = MfaApi(fakeApi(server.adapter).api);
    final old = server.recoveryCodes;

    final codes = await api.regenerateRecoveryCodes(
      password: testPassword,
      code: old.first,
    );
    expect(codes, hasLength(10));
    expect(codes, isNot(contains(old.first)));
    expect(server.adapter.sent.single.path, '/api/v1/auth/mfa/recovery-codes');
    expect(server.adapter.sent.single.data, {
      'password': testPassword,
      'code': old.first,
    });

    await expectLater(
      api.disable(password: testPassword, code: old[1]),
      problem(ProblemCode.mfaCodeInvalid),
    );
    await api.disable(password: testPassword, code: testTotp);
    expect(server.mfaEnabled, isFalse);
    expect(server.adapter.sent.last.data, {
      'password': testPassword,
      'code': testTotp,
    });
    await expectLater(
      api.regenerateRecoveryCodes(password: testPassword, code: testTotp),
      problem(ProblemCode.mfaNotEnabled),
    );
  });

  test('a browser sends the CSRF token', () async {
    final server = ProfileServer();
    final api = MfaApi(fakeApi(server.adapter, mode: SessionMode.cookie).api);

    await api.setup(testPassword);

    expect(server.adapter.paths, [
      'GET /api/v1/auth/csrf',
      'POST /api/v1/auth/mfa/setup',
    ]);
    expect(server.adapter.sent.last.headers['x-csrf-token'], 'csrf');
  });

  test('a body the app cannot read is unexpected', () async {
    final api = MfaApi(
      fakeApi(FakeAdapter((_) => Reply.json({'recoveryCodes': 'x'}))).api,
    );
    await expectLater(
      api.enable(testTotp),
      throwsA(isA<UnexpectedApiException>()),
    );
    await expectLater(
      api.setup(testPassword),
      throwsA(isA<UnexpectedApiException>()),
    );
  });
}
