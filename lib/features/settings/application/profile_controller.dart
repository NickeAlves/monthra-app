import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/data/models/me.dart';
import 'package:monthra/features/settings/data/me_api.dart';
import 'package:monthra/features/settings/domain/preferences_patch.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// A preference change the server refused or never got. A new one for each
/// failure, so a listener hears every one (no `==`).
final class PreferenceSaveFailure {
  // Not const: two failures with the same error are still two events.
  new(this.error);

  final ApiException error;
}

/// What the settings show beside the profile: the preference choices not
/// confirmed yet ([pending]), and the latest failure to save one.
@immutable
class ProfileEdits {
  const new({this.pending = PreferencesPatch.empty, this.failure});

  /// Every field chosen but not answered yet (queued or on its way). The
  /// currency and budget alerts show from here before the profile's value.
  final PreferencesPatch pending;

  final PreferenceSaveFailure? failure;

  ProfileEdits copyWith({
    PreferencesPatch? pending,
    PreferenceSaveFailure? failure,
  }) => ProfileEdits(
    pending: pending ?? this.pending,
    failure: failure ?? this.failure,
  );

  @override
  bool operator ==(Object other) =>
      other is ProfileEdits &&
      other.pending == pending &&
      identical(other.failure, failure);

  @override
  int get hashCode => Object.hash(pending, failure);
}

/// Changes to the signed-in profile: the name, and the preferences synced
/// with `PATCH /me/preferences` (§7.6).
///
/// - Language and theme apply (and are saved on the device) at once; the
///   request follows. Currency and budget alerts live only in the profile:
///   they show from [ProfileEdits.pending] until the answer.
/// - Requests go one at a time, in order, and the choices made while one
///   is on its way go together in the next: quick changes cost two
///   requests at most and the last choice wins.
/// - A failure puts a field back as the profile has it, unless a newer
///   choice for it is queued, and reports [ProfileEdits.failure] (the shell
///   shows it).
/// - Signed out (the catalog's pickers), the language and theme change on
///   the device only. Sign-in and start-up never come through here: the
///   profile's values replace the local ones there, so they send nothing.
/// - An answer that arrives after the person signed out, or someone else
///   signed in, is dropped.
@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  /// The choices waiting for the next request.
  PreferencesPatch _queued = PreferencesPatch.empty;

  /// The loop sending [_queued], while it runs.
  Future<void>? _drain;

  /// Bumped when the signed-in person changes: a loop of an earlier one
  /// stops at its next step.
  int _generation = 0;

  MeApi get _api => ref.read(meApiProvider);

  @override
  ProfileEdits build() {
    ref.listen(
      authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
      (_, _) => _reset(),
    );
    return const ProfileEdits();
  }

  /// Picks the theme: applied and saved on the device at once, then sent.
  Future<void> setTheme(ThemePreference theme) => Future.wait<void>([
    ref.read(preferencesProvider.notifier).setTheme(theme),
    _save(PreferencesPatch(theme: theme)),
  ]);

  /// Picks the UI language: applied and saved on the device at once, then
  /// sent (the server writes the account emails in it too).
  Future<void> setLocale(AppLocale locale) => Future.wait<void>([
    ref.read(preferencesProvider.notifier).setLocale(locale),
    _save(PreferencesPatch(locale: locale)),
  ]);

  /// The default currency of new accounts.
  Future<void> setCurrency(Currency currency) =>
      _save(PreferencesPatch(currency: currency));

  /// The budget alert emails on or off.
  Future<void> setBudgetAlerts({required bool enabled}) =>
      _save(PreferencesPatch(budgetAlerts: enabled));

  /// Changes the display name (trimmed). Throws the [ApiException] of a
  /// refusal, for the form to show.
  Future<void> rename(String name) async {
    final me = _signedInMe;
    if (me == null) return;
    final answer = await _api.updateName(name.trim());
    if (!ref.mounted) return;
    ref
        .read(authControllerProvider.notifier)
        .updateMe(me.id, (current) => current.copyWith(name: answer.name));
  }

  Me? get _signedInMe {
    final auth = ref.read(authControllerProvider);
    return auth is SignedIn ? auth.me : null;
  }

  /// Queues [change] (less what the profile already has, with nothing else
  /// pending for it) and starts the loop. Completes when the queue is
  /// empty again; never throws.
  Future<void> _save(PreferencesPatch change) {
    final me = _signedInMe;
    if (me == null) return Future.value();
    final pending = state.pending;
    final server = me.preferences;
    final unchanged = {
      if (change.locale != null && change.locale!.tag == server.locale)
        PreferenceField.locale,
      if (change.theme != null && change.theme!.wire == server.theme)
        PreferenceField.theme,
      if (change.currency != null && change.currency!.code == server.currency)
        PreferenceField.currency,
      if (change.budgetAlerts != null &&
          change.budgetAlerts == server.budgetAlerts)
        PreferenceField.budgetAlerts,
    }.where((f) => !pending.has(f));
    final send = change.without(unchanged);
    if (send.isEmpty) return _drain ?? Future.value();
    _queued = _queued.merge(send);
    state = state.copyWith(pending: pending.merge(send));
    final generation = _generation;
    // Started in a microtask, so _drain is set before the loop can end.
    return _drain ??= Future.microtask(() => _run(me.id, generation));
  }

  Future<void> _run(String userId, int generation) async {
    while (_current(userId, generation) && _queued.isNotEmpty) {
      final sent = _queued;
      _queued = PreferencesPatch.empty;
      try {
        final answer = await _api.updatePreferences(sent);
        if (!_current(userId, generation)) break;
        ref
            .read(authControllerProvider.notifier)
            .updateMe(userId, (me) => me.copyWith(preferences: answer));
        _settle(sent);
      } on ApiException catch (e) {
        if (!_current(userId, generation)) break;
        _revert(sent);
        _settle(sent);
        state = state.copyWith(failure: PreferenceSaveFailure(e));
      }
    }
    // In the same step as the last check of the queue: a choice made from
    // here on starts a new loop. A loop of an earlier person leaves the
    // current one alone.
    if (generation == _generation) _drain = null;
  }

  bool _current(String userId, int generation) =>
      ref.mounted && generation == _generation && _signedInMe?.id == userId;

  /// Drops from [ProfileEdits.pending] the fields of [sent] with no newer
  /// choice queued.
  void _settle(PreferencesPatch sent) {
    final done = sent.fields.where((f) => !_queued.has(f));
    state = state.copyWith(pending: state.pending.without(done));
  }

  /// Puts the language and theme of [sent] back as the profile has them,
  /// when no newer choice is queued and the device still shows what was
  /// sent (the currency and alerts fall back by themselves in [_settle]).
  void _revert(PreferencesPatch sent) {
    final me = _signedInMe;
    if (me == null) return;
    final server = me.preferences.app;
    final local = ref.read(preferencesProvider);
    final preferences = ref.read(preferencesProvider.notifier);
    if (sent.theme != null &&
        !_queued.has(PreferenceField.theme) &&
        local.theme == sent.theme) {
      unawaited(preferences.setTheme(server.theme));
    }
    if (sent.locale != null &&
        !_queued.has(PreferenceField.locale) &&
        local.locale == sent.locale) {
      unawaited(preferences.setLocale(server.locale));
    }
  }

  void _reset() {
    _generation++;
    _queued = PreferencesPatch.empty;
    _drain = null;
    state = const ProfileEdits();
  }
}
