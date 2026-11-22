import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/app/router.dart';
import 'package:monthra/app/shell/app_shell.dart';
import 'package:monthra/app/shell/shell_bottom_bar.dart';
import 'package:monthra/app/shell/shell_sidebar.dart';
import 'package:monthra/core/config/env.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/money/currency.dart';
import 'package:monthra/core/network/session_refresher.dart';
import 'package:monthra/core/security/token_store.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/data/session_hint.dart';
import 'package:monthra/features/auth/presentation/login_page.dart';
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/features/settings/preferences/application/preferences_providers.dart';
import 'package:monthra/features/settings/preferences/data/preferences_store.dart';
import 'package:monthra/features/settings/preferences/domain/app_locale.dart';
import 'package:monthra/features/settings/preferences/domain/app_preferences.dart';
import 'package:monthra/features/settings/preferences/domain/theme_preference.dart';
import 'package:monthra/features/settings/presentation/settings_page.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../helpers/app.dart';
import '../helpers/auth_fixtures.dart';
import '../helpers/contrast.dart';
import '../helpers/fake_api.dart';
import '../helpers/frame.dart';
import '../helpers/profile_server.dart';

const Size phone = Size(390, 844);
const Size tablet = Size(800, 1024);
const Size desktop = Size(1280, 800);

/// The app signed in as [server]'s profile (pt-BR) on a [size] window,
/// opened at [location].
Future<ProfileServer> pumpShell(
  WidgetTester tester, {
  Size size = desktop,
  ProfileServer? server,
  String? location,
  Env? env,
  SessionMode mode = SessionMode.bearer,
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
    env: env,
    mode: mode,
    tokens: MemoryTokenStore(savedTokens),
    hint: MemorySessionHint(present: true),
    location: location,
    store: MemoryPreferencesStore(
      AppPreferences(
        theme: ThemePreference.fromWire(api.preferences['theme']! as String)!,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(AppShell), findsOneWidget);
  return api;
}

/// The node of the menu entry read as [label].
SemanticsNode entry(WidgetTester tester, String label) => tester.getSemantics(
  find
      .descendant(
        of: find.byWidgetPredicate(
          (w) => w is ShellSidebar || w is ShellBottomBar,
        ),
        matching: find.bySemanticsLabel(label),
      )
      .first,
);

/// The menu entry showing [label] (the page may show it too).
Finder menu(String label) =>
    find.descendant(of: find.byType(ShellSidebar), matching: find.text(label));

bool selected(WidgetTester tester, String label) =>
    entry(tester, label).flagsCollection.isSelected == Tristate.isTrue;

void main() {
  group('on a desktop', () {
    testWidgets('lists the destinations with their labels, the account and '
        'the way out', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpShell(tester);

      expect(find.byType(ShellSidebar), findsOneWidget);
      expect(find.byType(ShellBottomBar), findsNothing);
      expect(find.text('Painel'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('Design system'), findsOneWidget);
      expect(find.bySemanticsLabel('Sair'), findsOneWidget);
      expect(find.bySemanticsLabel('Monthra'), findsOneWidget);
      expect(
        find.semantics.byPredicate(
          (n) =>
              n.role == SemanticsRole.navigation &&
              n.label == 'Navegação principal',
        ),
        findsOne,
      );
      expect(
        find.semantics.byPredicate((n) => n.role == SemanticsRole.main),
        findsOne,
      );
      expect(selected(tester, 'Painel'), isTrue);
      expect(selected(tester, 'Configurações'), isFalse);
      semantics.dispose();
    });

    testWidgets('moves between destinations', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpShell(tester);

      await tester.tap(menu('Configurações'));
      await tester.pumpAndSettle();
      expect(tester.appLocation.path, '/settings');
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(selected(tester, 'Configurações'), isTrue);
      expect(selected(tester, 'Painel'), isFalse);

      await tester.tap(menu('Painel'));
      await tester.pumpAndSettle();
      expect(tester.appLocation.path, '/');
      expect(find.byType(HomePage), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('opens on the page of the address', (tester) async {
      await pumpShell(tester, location: '/settings');
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('signs out to the sign-in page', (tester) async {
      final server = await pumpShell(tester);
      await tester.tap(find.bySemanticsLabel('Sair'));
      await tester.pumpAndSettle();
      expect(server.adapter.paths.last, 'POST /api/v1/auth/logout');
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('a browser that could not sign out says so and stays', (
      tester,
    ) async {
      final server = ProfileServer(me: meJson(theme: 'light'))
        ..fail('/api/v1/auth/logout', Reply.problem(503, 'unavailable'));
      await pumpShell(tester, server: server, mode: SessionMode.cookie);

      await tester.tap(find.bySemanticsLabel('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Você continua conectado'), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
      expect(
        tester.appContainer.read(authControllerProvider).isSignedIn,
        isTrue,
      );
    });

    testWidgets('a preference the server refused is reported wherever the '
        'person is', (tester) async {
      final server = await pumpShell(tester, location: '/settings');
      server.fail('/api/v1/me/preferences', Reply.problem(503, 'unavailable'));

      await tester.tap(find.byType(ShadSelect<Currency>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Euro (EUR)').last);
      await tester.tap(menu('Painel'));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Sua alteração não foi salva'), findsOneWidget);
    });

    testWidgets('a refused theme goes back and is reported', (tester) async {
      final server = await pumpShell(tester, location: '/settings');
      server.fail('/api/v1/me/preferences', Reply.problem(503, 'unavailable'));

      await tester.tap(find.text('Escuro'));
      await tester.pumpAndSettle();

      expect(
        tester.appContainer.read(preferencesProvider).theme,
        ThemePreference.light,
      );
      expect(find.text('Sua alteração não foi salva'), findsOneWidget);
    });

    testWidgets('opens the catalog above the shell, and comes back to the '
        'page as it was', (tester) async {
      await pumpShell(tester, location: '/settings');
      await tester.enterText(find.byType(EditableText), 'Bia');

      await tester.tap(find.text('Design system'));
      await tester.pumpAndSettle();
      expect(find.byType(DesignSystemCatalog), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Bia'), findsOneWidget);
    });

    testWidgets('has no catalog link in production', (tester) async {
      await pumpShell(
        tester,
        env: Env(
          appEnv: AppEnv.production,
          apiBaseUrl: Uri.parse('https://api.example.com'),
        ),
      );
      expect(find.text('Design system'), findsNothing);
    });

    testWidgets('keeps each page as it was left', (tester) async {
      await pumpShell(tester, location: '/settings');
      await tester.enterText(find.byType(EditableText), 'Rascunho');

      await tester.tap(menu('Painel'));
      await tester.pumpAndSettle();
      await tester.tap(menu('Configurações'));
      await tester.pumpAndSettle();
      expect(find.text('Rascunho'), findsOneWidget);
    });

    testWidgets('the selected destination goes back to its first page', (
      tester,
    ) async {
      await pumpShell(tester, location: '/settings');
      final router = tester.appContainer.read(routerProvider);
      await tester.tap(menu('Configurações'));
      await tester.pumpAndSettle();
      expect(router.state.uri.path, '/settings');
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('Tab goes through the menu and never into a hidden page', (
      tester,
    ) async {
      await pumpShell(tester, location: '/settings');
      await tester.tap(menu('Painel'));
      await tester.pumpAndSettle();

      final hidden = find.byType(SettingsPage, skipOffstage: false);
      expect(hidden, findsOneWidget);
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused == null) continue;
        expect(
          find.descendant(
            of: hidden,
            matching: find.byElementPredicate(
              (e) => e == focused,
              skipOffstage: false,
            ),
            skipOffstage: false,
          ),
          findsNothing,
        );
      }

      // Enter on a focused entry activates it.
      await tester.pumpShellFocus('Configurações');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('a newer profile does not rebuild the page', (tester) async {
      await pumpShell(tester, location: '/settings');
      final page = tester.element(find.byType(SettingsPage));
      tester.appContainer
          .read(authControllerProvider.notifier)
          .updateMe('u1', (me) => me.copyWith(name: 'Bia'));
      await tester.pumpAndSettle();
      expect(tester.element(find.byType(SettingsPage)), same(page));
      expect(find.text('Bia'), findsWidgets);
    });

    testWidgets('a new language keeps the page', (tester) async {
      final server = await pumpShell(tester, location: '/settings');
      final page = tester.element(find.byType(SettingsPage));
      await tester.tap(find.byType(ShadSelect<AppLocale>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English (US)').last);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
      expect(tester.element(find.byType(SettingsPage)), same(page));
      expect(server.preferencePatches, [
        {'locale': 'en-US'},
      ]);
      expect(tester.appContainer.read(appLocaleProvider), AppLocale.enUs);
    });
  });

  group('on a tablet', () {
    testWidgets('shows the icons, with their labels in tooltips and for '
        'screen readers', (tester) async {
      await pumpShell(tester, size: tablet);

      expect(find.byType(ShellSidebar), findsOneWidget);
      expect(find.text('Painel'), findsNothing);
      expect(find.text('ana@example.com'), findsNothing);
      expect(find.bySemanticsLabel('Painel'), findsOneWidget);
      expect(find.bySemanticsLabel('Configurações'), findsOneWidget);
      expect(find.bySemanticsLabel('Conectado como Ana'), findsOneWidget);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(
        tester.getCenter(find.bySemanticsLabel('Configurações')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Configurações'), findsOneWidget);
      // Beside the rail, not over the entries.
      expect(
        tester.getTopLeft(find.text('Configurações')).dx,
        greaterThan(MonthraLayout.railWidth),
      );

      await tester.tap(
        find.descendant(
          of: find.byType(ShellSidebar),
          matching: find.byIcon(LucideIcons.settings),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('on a phone', () {
    testWidgets('the bar holds the dashboard and More', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpShell(tester, size: phone);

      expect(find.byType(ShellBottomBar), findsOneWidget);
      expect(find.byType(ShellSidebar), findsNothing);
      expect(find.text('Painel'), findsOneWidget);
      expect(find.text('Mais'), findsOneWidget);
      expect(find.text('Configurações'), findsNothing);
      expect(selected(tester, 'Painel'), isTrue);
      expect(selected(tester, 'Mais'), isFalse);
      semantics.dispose();
    });

    testWidgets('More lists the rest; a pick closes it and selects More', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpShell(tester, size: phone);

      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Design system'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);

      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();
      expect(find.text('Sair'), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      expect(tester.appLocation.path, '/settings');
      expect(selected(tester, 'Mais'), isTrue);
      expect(selected(tester, 'Painel'), isFalse);
      semantics.dispose();
    });

    testWidgets('More closes with Escape and with its button', (tester) async {
      await pumpShell(tester, size: phone);

      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Sair'), findsNothing);

      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Fechar'), findsWidgets);
      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(find.text('Sair'), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('signs out from More', (tester) async {
      final server = await pumpShell(tester, size: phone);
      await tester.tap(find.text('Mais'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(server.adapter.paths.last, 'POST /api/v1/auth/logout');
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('the bar steps aside for the keyboard', (tester) async {
      await pumpShell(tester, size: phone, location: '/settings');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byType(ShellBottomBar), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(find.byType(ShellBottomBar), findsOneWidget);
    });
  });

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phone),
      ('tablet', tablet),
      ('desktop', desktop),
    ]) {
      testWidgets('meets the guidelines on a $name, ${brightness.name}', (
        tester,
      ) async {
        await pumpShell(tester, size: size, brightness: brightness);
        Future<void> check() async {
          await expectLater(
            tester,
            meetsGuideline(
              name == 'desktop'
                  ? const MinimumTapTargetGuideline(
                      size: Size(24, 24),
                      link:
                          'https://www.w3.org/WAI/WCAG22/Understanding/'
                          'target-size-minimum',
                    )
                  : iOSTapTargetGuideline,
            ),
          );
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          expect(contrastIssues(tester), isEmpty);
        }

        await check();
        if (name == 'phone') {
          await tester.tap(find.text('Mais'));
          await tester.pumpAndSettle();
          await check();
        }
      });
    }
  }

  for (final (name, size) in [
    ('phone', phone),
    ('tablet', tablet),
    ('desktop', desktop),
  ]) {
    testWidgets('copes with twice the text size on a $name', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpShell(tester, size: size);
      expect(tester.takeException(), isNull);
      if (name == 'phone') {
        await tester.tap(find.text('Mais'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}

extension on WidgetTester {
  /// Moves the keyboard focus to the menu entry read as [label].
  Future<void> pumpShellFocus(String label) async {
    final element = this.element(
      find
          .descendant(
            of: find.byType(ShellSidebar),
            matching: find.bySemanticsLabel(label),
          )
          .first,
    );
    Focus.of(element).requestFocus();
    await pump();
  }
}
