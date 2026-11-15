// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get preferencesLanguage => 'Language';

  @override
  String get preferencesTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get authTagline => 'Your finances, month by month.';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignInSubtitle => 'Welcome back.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNewPasswordHint => 'At least 10 characters.';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authForgotPasswordLink => 'Forgot your password?';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authNoAccount => 'New to Monthra?';

  @override
  String get authCreateAccountLink => 'Create an account';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authNoticeSessionExpired => 'Your session ended. Sign in again.';

  @override
  String get authNoticePasswordReset =>
      'Password changed. Sign in with the new one.';

  @override
  String get authNoticeMfaExpired =>
      'The verification step expired. Sign in again.';

  @override
  String get authEmailNotVerified =>
      'Confirm your email before signing in. The link is in your inbox.';

  @override
  String get authResendVerification => 'Resend the email';

  @override
  String authResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String authVerificationSent(String email) {
    return 'We sent a new link to $email.';
  }

  @override
  String get authMfaTitle => 'Two-step verification';

  @override
  String get authMfaSubtitle =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String get authMfaCodeLabel => 'Code';

  @override
  String get authMfaRecoverySubtitle =>
      'Enter one of your recovery codes. Each one works once.';

  @override
  String get authMfaRecoveryLabel => 'Recovery code';

  @override
  String get authMfaUseRecovery => 'Use a recovery code';

  @override
  String get authMfaUseApp => 'Use the authenticator app';

  @override
  String get authMfaVerifyButton => 'Verify';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Expenses, income and investments in one place.';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authRegisterButton => 'Create account';

  @override
  String get authCheckInboxTitle => 'Check your inbox';

  @override
  String authCheckInboxMessage(String email) {
    return 'We sent a confirmation link to $email. It works for 30 minutes. If it doesn\'t arrive, check the spam folder.';
  }

  @override
  String get authForgotTitle => 'Reset your password';

  @override
  String get authForgotSubtitle =>
      'Enter your account\'s email and we\'ll send you a link.';

  @override
  String get authForgotButton => 'Send link';

  @override
  String authForgotSentMessage(String email) {
    return 'If there is an account for $email, a reset link is on its way. It works for 15 minutes.';
  }

  @override
  String get authResetTitle => 'Choose a new password';

  @override
  String get authResetSubtitle => 'Every device will be signed out.';

  @override
  String get authResetButton => 'Change password';

  @override
  String get authLinkInvalidTitle => 'This link no longer works';

  @override
  String get authResetLinkInvalidMessage =>
      'It expired or was already used. Ask for a new one.';

  @override
  String get authRequestNewLink => 'Ask for a new link';

  @override
  String get authVerifyingTitle => 'Confirming your email…';

  @override
  String get authVerifiedTitle => 'Email confirmed';

  @override
  String get authVerifiedMessage => 'Your account is ready. Sign in to start.';

  @override
  String get authVerifyLinkInvalidMessage =>
      'It expired or was already used. Enter your email to get a new one.';

  @override
  String get authContinue => 'Continue';

  @override
  String get appUnavailableTitle => 'We can\'t reach Monthra';

  @override
  String get appRetry => 'Try again';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'The address may be wrong, or the page moved.';

  @override
  String get notFoundHome => 'Go to the start';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeComingSoon => 'Your dashboard arrives in the next versions.';

  @override
  String get homeSignOut => 'Sign out';

  @override
  String get homeDesignSystem => 'Design system';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String errorRateLimited(int seconds) {
    return 'Too many attempts. Try again in $seconds s.';
  }

  @override
  String get errorRateLimitedSoon =>
      'Too many attempts. Try again in a moment.';

  @override
  String get errorCaptcha =>
      'Too many attempts in a row. Wait a few minutes and try again.';

  @override
  String get errorMfaCodeInvalid =>
      'Wrong or already used code. Wait for the next one.';

  @override
  String get errorOffline =>
      'No connection to the server. Check your internet.';

  @override
  String get errorTimeout => 'The server took too long to answer. Try again.';

  @override
  String get errorUnavailable =>
      'The service is unavailable right now. Try again in a moment.';

  @override
  String get errorCheckFields => 'Check the highlighted fields.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String errorReference(String id) {
    return 'Reference: $id';
  }

  @override
  String get errorFieldRequired => 'Required.';

  @override
  String get errorEmailInvalid => 'Enter a valid email.';

  @override
  String get errorFieldInvalid => 'Invalid value.';

  @override
  String errorTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String errorTooLong(int max) {
    return 'Use at most $max characters.';
  }

  @override
  String get errorPasswordBreached =>
      'This password appeared in data breaches. Choose another one.';

  @override
  String get errorMfaCodeFormat => 'Enter the 6 digits.';
}
