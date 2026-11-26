import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/money/money_format.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/l10n/generated/app_localizations_pt.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/app.dart';
import '../../helpers/auth_fixtures.dart';
import '../../helpers/frame.dart';
import '../../helpers/profile_server.dart';

final pt = AppLocalizationsPt();
const ptBR = Locale('pt', 'BR');

/// An amount as pt-BR writes it (with a plain space after the symbol).
String brl(int minor, [Currency currency = Currency.brl]) =>
    MoneyFormat.format(minor, currency, ptBR).replaceAll(' ', ' ');

/// The text of [finder] with intl's no-break spaces as plain ones.
String shown(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).data!.replaceAll(' ', ' ');

/// Finds a text that reads [text] once intl's no-break spaces are plain.
Finder findAmount(String text) => find.byWidgetPredicate(
  (w) => w is Text && w.data?.replaceAll(' ', ' ') == text,
);

const desktop = Size(1280, 900);
const phone = Size(390, 844);

/// The app signed in at [location] (the accounts page by default) on a
/// [size] window, in pt-BR with motion off, with [server] (the demo data by
/// default) answering.
Future<ProfileServer> pumpAccounts(
  WidgetTester tester, {
  ProfileServer? server,
  String location = '/accounts',
  Size size = desktop,
  Brightness brightness = Brightness.light,
}) async {
  final api = server ?? ProfileServer(me: meJson(theme: brightness.name));
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.reduceMotion();
  await tester.pumpMonthraApp(
    api: api.adapter,
    tokens: MemoryTokenStore(savedTokens),
    location: location,
    store: MemoryPreferencesStore(
      AppPreferences(
        locale: AppLocale.ptBr,
        theme: ThemePreference.fromWire(brightness.name)!,
      ),
    ),
  );
  await tester.settle();
  return api;
}

/// How many times [server] was asked for [method] [path].
int calls(ProfileServer server, String method, String path) =>
    server.adapter.count(method, path);

extension AccountsTester on WidgetTester {
  /// Settles, then lets the calls a last frame started finish: dio runs on
  /// timers, and with motion off no frame follows the build that starts a
  /// read, so `pumpAndSettle` alone stops before they land.
  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpAndSettle();
      await pump(Duration.zero);
    }
  }

  /// Taps the widget [label] names (a text or a semantics label).
  Future<void> tapLabel(String label) async {
    final finder = find.bySemanticsLabel(label);
    await ensureVisible(finder.last);
    await tap(finder.last);
    await settle();
  }

  /// Opens [select] and picks [option] in it.
  Future<void> pick(Finder select, String option) async {
    await ensureVisible(select);
    await tap(select);
    await pumpAndSettle();
    final choice = find.text(option).last;
    await ensureVisible(choice);
    await tap(choice);
    await pumpAndSettle();
  }

  /// Types [text] in the field labeled [label].
  Future<void> type(String label, String text) async {
    final field = find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(ShadInputFormField),
      ),
      matching: find.byType(EditableText),
    );
    await ensureVisible(field);
    await enterText(field, text);
    await pump();
  }
}
