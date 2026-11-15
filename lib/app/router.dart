import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monthra/app/not_found_page.dart';
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
import 'package:monthra/features/home/presentation/home_page.dart';
import 'package:monthra/features/settings/preferences/presentation/language_picker.dart';
import 'package:monthra/features/settings/preferences/presentation/theme_preference_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

/// A production build (`APP_ENV`): the catalog route compiles away there.
const bool productionBuild = String.fromEnvironment('APP_ENV') == 'production';

/// The app's paths. Email links point at [verifyEmail] and [resetPassword]
/// (`{APP_PUBLIC_URL}/verify-email#token=…`), budget alerts at `/budgets`.
abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const mfa = '/login/mfa';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';
  static const designSystem = '/design-system';

  /// Pages for someone signed out: a signed-in visit goes on to `from`.
  static const Set<String> signedOutOnly = {
    login,
    mfa,
    register,
    forgotPassword,
  };

  /// Pages open in either state: the email links and the catalog.
  static const Set<String> open = {resetPassword, verifyEmail, designSystem};

  /// [path] carrying [from], the page to return to after signing in.
  static String withFrom(String path, String? from) =>
      from == null || from == home
      ? path
      : Uri(path: path, queryParameters: {'from': from}).toString();
}

/// Where a visit to [uri] goes given [auth]; null stays.
///
/// - While the session is unknown nothing moves (the app shows the boot
///   screen, no page is built).
/// - Signed out, a page that needs a session goes to the sign-in page with
///   `from`; `/login/mfa` without a pending challenge goes back to it.
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
  // as the app, and the guards re-run on every change of the session.
  final auth = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref.listen(authControllerProvider, (_, next) => auth.value = next);
  final env = ref.read(envProvider);
  final catalog = !productionBuild && !env.isProduction;

  final router = GoRouter(
    refreshListenable: auth,
    redirect: (context, state) => authRedirect(auth.value, state.uri),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
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
      if (catalog)
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

String? _from(GoRouterState state) =>
    safeReturnPath(state.uri.queryParameters['from']);
