import 'package:monthra/core/config/env.dart';

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
  static const settings = '/settings';
  static const settingsPassword = '/settings/password';
  static const settingsMfaEnable = '/settings/mfa/enable';
  static const settingsMfaDisable = '/settings/mfa/disable';
  static const settingsRecoveryCodes = '/settings/mfa/recovery-codes';

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

/// The design system catalog exists outside production only.
bool catalogEnabled(Env env) => !productionBuild && !env.isProduction;
