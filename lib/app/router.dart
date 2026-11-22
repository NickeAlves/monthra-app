import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/not_found_page.dart';
import 'package:monthra/app/routes.dart';
import 'package:monthra/app/shell/app_shell.dart';
import 'package:monthra/app/shell/shell_destinations.dart';
import 'package:monthra/core/config/env_provider.dart';
import 'package:monthra/core/design_system/catalog/design_system_catalog.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/auth/presentation/forgot_password_page.dart';
import 'package:monthra/features/auth/presentation/login_page.dart';
import 'package:monthra/features/auth/presentation/mfa_page.dart';
import 'package:monthra/features/auth/presentation/register_page.dart';
import 'package:monthra/features/auth/presentation/reset_password_page.dart';
import 'package:monthra/features/auth/presentation/verify_email_page.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:monthra/app/routes.dart';

part 'router.g.dart';

/// Where a visit to [uri] goes given [auth]; null stays.
///
/// - While the session is unknown nothing moves (the app shows the boot
///   screen, no page is built).
/// - Signed out, a page that needs a session goes to the sign-in page with
///   `from` (none after the account was deleted); `/login/mfa` without a
///   pending challenge goes back to it.
/// - Signed in, the signed-out pages go on to `from` (when it is safe, see
///   [safeReturnPath]) or home.
String? authRedirect(AuthState auth, Uri uri) {
  if (auth is AuthBooting || auth is AuthUnavailable) return null;
  final path = uri.path;
  if (AppRoutes.open.contains(path)) return null;
  final from = safeReturnPath(uri.queryParameters['from']);
  final signedOutOnly = AppRoutes.signedOutOnly.contains(path);
  if (auth is SignedIn) {
    return signedOutOnly ? from ?? AppRoutes.home : null;
  }
  if (path == AppRoutes.mfa && auth is! AwaitingMfa) {
    return AppRoutes.withFrom(AppRoutes.login, from);
  }
  if (signedOutOnly) return null;
  // A deleted account leaves nothing to come back to: whoever signs in next
  // starts on the home page, not on the deletion page.
  if (auth case SignedOut(notice: AuthNotice.accountDeleted)) {
    return AppRoutes.login;
  }
  final here = Uri(path: path, query: uri.hasQuery ? uri.query : null);
  return AppRoutes.withFrom(AppRoutes.login, here.toString());
}

/// [from] when it is a path of this app, null otherwise: never a scheme, a
/// host (`//evil.com`, `/\evil.com`), a control character or a fragment, so
/// a crafted sign-in link cannot send anyone elsewhere after signing in. A
/// signed-out page is no destination either.
String? safeReturnPath(String? from) {
  if (from == null || from.isEmpty || from.length > 2048) return null;
  if (!from.startsWith('/') || from.startsWith('//') || from.contains(r'\')) {
    return null;
  }
  if (from.codeUnits.any((c) => c < 0x20 || c == 0x7f)) return null;
  final uri = Uri.tryParse(from);
  if (uri == null || uri.hasScheme || uri.hasAuthority || uri.hasFragment) {
    return null;
  }
  return AppRoutes.signedOutOnly.contains(uri.path) ? null : from;
}

/// The `token` of an email link (`#token=…`), or null.
String? linkToken(Uri uri) {
  if (!uri.hasFragment || uri.fragment.isEmpty) return null;
  try {
    final token = Uri.splitQueryString(uri.fragment)['token'];
    return token == null || token.isEmpty ? null : token;
  } on FormatException {
    return null;
  }
}

/// Takes the email link's token out of the address bar and the browser
/// history (the entry is replaced, not pushed): it was read already and
/// must not linger where someone else could reuse it.
void dropLinkFragment(BuildContext context) {
  final uri = GoRouterState.of(context).uri;
  if (!uri.hasFragment) return;
  final clean = Uri(path: uri.path, query: uri.hasQuery ? uri.query : null);
  Router.neglect(context, () => context.go(clean.toString()));
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  // Read here and kept current by the listener: the router lives as long
  // as the app, and the guards re-run when the kind of session changes
  // (a newer profile, from a rename say, moves nothing).
  final auth = SessionKind(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => auth.update(next));
  final env = ref.read(envProvider);

  final router = GoRouter(
    refreshListenable: auth,
    redirect: (context, state) => authRedirect(auth.state, state.uri),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      // The signed-in pages, one branch per destination (its own history
      // and scroll position), inside the app shell. The branches not shown
      // keep their state and take no focus (IndexedStack excludes it).
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          for (final d in ShellDestination.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: d.path,
                  builder: (_, state) => d.page(state),
                  routes: d.routes,
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, state) => LoginPage(from: _from(state)),
      ),
      GoRoute(
        path: AppRoutes.mfa,
        builder: (_, state) => MfaPage(from: _from(state)),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, state) => ResetPasswordPage(token: linkToken(state.uri)),
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (_, state) => VerifyEmailPage(token: linkToken(state.uri)),
      ),
      // Outside the shell, above it when opened from it (back keeps the
      // branch as it was).
      if (catalogEnabled(env))
        GoRoute(
          path: AppRoutes.designSystem,
          builder: (_, _) => DesignSystemCatalog(
            env: env,
            actions: const [ThemePreferencePicker(), LanguagePicker()],
          ),
        ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    auth.dispose();
  });
  return router;
}

/// The session for the guards, notifying only when its kind changes
/// (signed in, signed out, booting...): the guards look at nothing else.
class SessionKind extends ChangeNotifier {
  new(this.state);

  AuthState state;

  void update(AuthState next) {
    final changed = next.runtimeType != state.runtimeType;
    state = next;
    if (changed) notifyListeners();
  }
}

String? _from(GoRouterState state) =>
    safeReturnPath(state.uri.queryParameters['from']);
