import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// Label of the language picker (settings and the public landing page).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get preferencesLanguage;

  /// Label of the theme picker (System, Light or Dark).
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get preferencesTheme;

  /// Theme option that follows the device's light or dark mode.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme option: always light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option: always dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Short brand line on the green panel beside the sign-in forms (desktop).
  ///
  /// In en, this message translates to:
  /// **'Your finances, month by month.'**
  String get authTagline;

  /// Title of the sign-in page.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// Line under the sign-in title.
  ///
  /// In en, this message translates to:
  /// **'Welcome back.'**
  String get authSignInSubtitle;

  /// Label of the email address field.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Help text under a new password field (sign-up, reset).
  ///
  /// In en, this message translates to:
  /// **'At least 10 characters.'**
  String get authNewPasswordHint;

  /// Accessible label of the eye button that reveals the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Accessible label of the eye button that hides the password again.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Link from the sign-in page to the password reset request.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get authForgotPasswordLink;

  /// Button that submits the sign-in form.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// Text before the link to sign up, on the sign-in page.
  ///
  /// In en, this message translates to:
  /// **'New to Monthra?'**
  String get authNoAccount;

  /// Link from the sign-in page to the sign-up page.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get authCreateAccountLink;

  /// Text before the link to sign in, on the sign-up page.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccount;

  /// Notice on the sign-in page after the session ran out or was revoked.
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Sign in again.'**
  String get authNoticeSessionExpired;

  /// Notice on the sign-in page after a password reset (every session was signed out).
  ///
  /// In en, this message translates to:
  /// **'Password changed. Sign in with the new one.'**
  String get authNoticePasswordReset;

  /// Notice on the sign-in page when the two-step challenge expired or ran out of attempts.
  ///
  /// In en, this message translates to:
  /// **'The verification step expired. Sign in again.'**
  String get authNoticeMfaExpired;

  /// Error when signing in with the right password on an unconfirmed address.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email before signing in. The link is in your inbox.'**
  String get authEmailNotVerified;

  /// Button that sends a new confirmation link.
  ///
  /// In en, this message translates to:
  /// **'Resend the email'**
  String get authResendVerification;

  /// Disabled resend button while waiting before another email can be sent.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String authResendIn(int seconds);

  /// Confirmation that a new confirmation link was sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a new link to {email}.'**
  String authVerificationSent(String email);

  /// Title of the second sign-in step.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get authMfaTitle;

  /// Line under the two-step title when asking for an authenticator code.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get authMfaSubtitle;

  /// Label of the 6-digit code field.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authMfaCodeLabel;

  /// Line under the two-step title when asking for a recovery code.
  ///
  /// In en, this message translates to:
  /// **'Enter one of your recovery codes. Each one works once.'**
  String get authMfaRecoverySubtitle;

  /// Label of the recovery code field.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get authMfaRecoveryLabel;

  /// Switches the two-step page to a recovery code.
  ///
  /// In en, this message translates to:
  /// **'Use a recovery code'**
  String get authMfaUseRecovery;

  /// Switches the two-step page back to an authenticator code.
  ///
  /// In en, this message translates to:
  /// **'Use the authenticator app'**
  String get authMfaUseApp;

  /// Button that submits the two-step code.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authMfaVerifyButton;

  /// Link back to the sign-in page.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// Title of the sign-up page.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// Line under the sign-up title.
  ///
  /// In en, this message translates to:
  /// **'Expenses, income and investments in one place.'**
  String get authRegisterSubtitle;

  /// Label of the display name field (sign-up).
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authNameLabel;

  /// Button that submits the sign-up form.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterButton;

  /// Title after signing up or asking for a reset link.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get authCheckInboxTitle;

  /// Message after signing up.
  ///
  /// In en, this message translates to:
  /// **'We sent a confirmation link to {email}. It works for 30 minutes. If it doesn\'t arrive, check the spam folder.'**
  String authCheckInboxMessage(String email);

  /// Title of the page that asks for a reset link.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotTitle;

  /// Line under the reset request title.
  ///
  /// In en, this message translates to:
  /// **'Enter your account\'s email and we\'ll send you a link.'**
  String get authForgotSubtitle;

  /// Button that asks for a reset link.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get authForgotButton;

  /// Message after asking for a reset link (the same whether or not the account exists).
  ///
  /// In en, this message translates to:
  /// **'If there is an account for {email}, a reset link is on its way. It works for 15 minutes.'**
  String authForgotSentMessage(String email);

  /// Title of the page opened from the reset link.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get authResetTitle;

  /// Line under the new password title.
  ///
  /// In en, this message translates to:
  /// **'Every device will be signed out.'**
  String get authResetSubtitle;

  /// Button that saves the new password.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authResetButton;

  /// Title when a reset or confirmation link expired, was used or is broken.
  ///
  /// In en, this message translates to:
  /// **'This link no longer works'**
  String get authLinkInvalidTitle;

  /// Message for a reset link that no longer works.
  ///
  /// In en, this message translates to:
  /// **'It expired or was already used. Ask for a new one.'**
  String get authResetLinkInvalidMessage;

  /// Button from a dead reset link to the reset request page.
  ///
  /// In en, this message translates to:
  /// **'Ask for a new link'**
  String get authRequestNewLink;

  /// Shown while the confirmation link is checked.
  ///
  /// In en, this message translates to:
  /// **'Confirming your email…'**
  String get authVerifyingTitle;

  /// Title after the confirmation link worked.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get authVerifiedTitle;

  /// Message after the confirmation link worked.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready. Sign in to start.'**
  String get authVerifiedMessage;

  /// Message for a confirmation link that no longer works, above the resend form.
  ///
  /// In en, this message translates to:
  /// **'It expired or was already used. Enter your email to get a new one.'**
  String get authVerifyLinkInvalidMessage;

  /// Button that moves on after a confirmation.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// Title at start-up when the API cannot be reached.
  ///
  /// In en, this message translates to:
  /// **'We can\'t reach Monthra'**
  String get appUnavailableTitle;

  /// Button that tries a failed load again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get appRetry;

  /// Title of the page for an unknown address.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// Message of the page for an unknown address.
  ///
  /// In en, this message translates to:
  /// **'The address may be wrong, or the page moved.'**
  String get notFoundMessage;

  /// Button from the unknown address page to the start page.
  ///
  /// In en, this message translates to:
  /// **'Go to the start'**
  String get notFoundHome;

  /// Greeting on the start page.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// Temporary line on the start page until the dashboard lands.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard arrives in the next versions.'**
  String get homeComingSoon;

  /// Sign-in error: the email or the password is wrong (never says which).
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorInvalidCredentials;

  /// Error after too many attempts, with the wait the server asked for.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} s.'**
  String errorRateLimited(int seconds);

  /// Error after too many attempts, when the server gave no wait.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a moment.'**
  String get errorRateLimitedSoon;

  /// Error when the server asks for a captcha after repeated failures and this build has no captcha to show (no site key).
  ///
  /// In en, this message translates to:
  /// **'Too many attempts in a row. Wait a few minutes and try again.'**
  String get errorCaptcha;

  /// Label above the Cloudflare Turnstile widget, also the frame title read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Security check'**
  String get authCaptchaLabel;

  /// Alert when the server asks for a captcha; the form is sent again by itself once the check passes.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts in a row. Complete the security check below to go on.'**
  String get authCaptchaPrompt;

  /// Alert when the server refused the captcha token (captcha_invalid); a new check starts below.
  ///
  /// In en, this message translates to:
  /// **'The security check wasn\'t accepted. Try it again below.'**
  String get authCaptchaRejected;

  /// Error in place of the captcha widget when it failed to load, above a retry button.
  ///
  /// In en, this message translates to:
  /// **'The security check couldn\'t load. Check your connection and try again.'**
  String get authCaptchaFailed;

  /// Error in place of the captcha widget when the browser or webview cannot run Cloudflare Turnstile.
  ///
  /// In en, this message translates to:
  /// **'This browser can\'t run the security check. Update it or use another one.'**
  String get authCaptchaUnsupported;

  /// Note under the captcha widget while the form waits for it (the send button is off meanwhile).
  ///
  /// In en, this message translates to:
  /// **'Waiting for the security check…'**
  String get authCaptchaHint;

  /// Two-step error: the code is wrong or was already used.
  ///
  /// In en, this message translates to:
  /// **'Wrong or already used code. Wait for the next one.'**
  String get errorMfaCodeInvalid;

  /// Error when the API cannot be reached.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check your internet.'**
  String get errorOffline;

  /// Error when the API answered too late.
  ///
  /// In en, this message translates to:
  /// **'The server took too long to answer. Try again.'**
  String get errorTimeout;

  /// Error when the API is down or failed.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Try again in a moment.'**
  String get errorUnavailable;

  /// Error when the server refused some fields.
  ///
  /// In en, this message translates to:
  /// **'Check the highlighted fields.'**
  String get errorCheckFields;

  /// Error for an unexpected failure.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// Support reference under an unexpected error (the request id).
  ///
  /// In en, this message translates to:
  /// **'Reference: {id}'**
  String errorReference(String id);

  /// Field error: the field is empty.
  ///
  /// In en, this message translates to:
  /// **'Required.'**
  String get errorFieldRequired;

  /// Field error: not an email address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get errorEmailInvalid;

  /// Field error: the value is not accepted.
  ///
  /// In en, this message translates to:
  /// **'Invalid value.'**
  String get errorFieldInvalid;

  /// Field error: too short.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String errorTooShort(int min);

  /// Field error: too long.
  ///
  /// In en, this message translates to:
  /// **'Use at most {max} characters.'**
  String errorTooLong(int max);

  /// Field error: the password is in a list of breached passwords.
  ///
  /// In en, this message translates to:
  /// **'This password appeared in data breaches. Choose another one.'**
  String get errorPasswordBreached;

  /// Field error: the authenticator code needs 6 digits.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6 digits.'**
  String get errorMfaCodeFormat;

  /// Label of a button that closes a message or a panel (icon only, read by screen readers).
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get appClose;

  /// Title of the settings page (also its menu entry).
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title of the profile card on the settings page.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfileTitle;

  /// Line under the profile card title.
  ///
  /// In en, this message translates to:
  /// **'How Monthra addresses you.'**
  String get settingsProfileDescription;

  /// Label of the display name field on the settings page.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsNameLabel;

  /// Button that saves the display name.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get settingsSaveName;

  /// Message after the display name was saved.
  ///
  /// In en, this message translates to:
  /// **'Name saved.'**
  String get settingsNameSaved;

  /// Label above the account's email address (read-only) on the settings page.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmailLabel;

  /// Line under the account's email address: it cannot be changed (no email change flow yet).
  ///
  /// In en, this message translates to:
  /// **'The address you sign in with. It can\'t be changed yet.'**
  String get settingsEmailHint;

  /// Title of the preferences card on the settings page.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferencesTitle;

  /// Line under the preferences card title: the choices sync between devices.
  ///
  /// In en, this message translates to:
  /// **'Saved to your account, on every device.'**
  String get settingsPreferencesDescription;

  /// Line under the language setting: it applies to the interface and the account emails.
  ///
  /// In en, this message translates to:
  /// **'The app and the emails you get.'**
  String get settingsLanguageDescription;

  /// Line under the theme setting.
  ///
  /// In en, this message translates to:
  /// **'System follows your device.'**
  String get settingsThemeDescription;

  /// Label of the default currency setting.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsCurrencyLabel;

  /// Line under the default currency setting: amounts are never converted.
  ///
  /// In en, this message translates to:
  /// **'Suggested when you add an account.'**
  String get settingsCurrencyDescription;

  /// Label of the switch that turns the budget alert emails on or off.
  ///
  /// In en, this message translates to:
  /// **'Budget alert emails'**
  String get settingsBudgetAlertsLabel;

  /// Line under the budget alerts switch.
  ///
  /// In en, this message translates to:
  /// **'An email when a budget reaches its warning level or its limit.'**
  String get settingsBudgetAlertsDescription;

  /// Title of the message shown when a preference could not be saved (it goes back to the saved value).
  ///
  /// In en, this message translates to:
  /// **'Your change wasn\'t saved'**
  String get settingsSaveFailed;

  /// Name of the currency BRL, with its code.
  ///
  /// In en, this message translates to:
  /// **'Brazilian real (BRL)'**
  String get currencyBrl;

  /// Name of the currency USD, with its code.
  ///
  /// In en, this message translates to:
  /// **'US dollar (USD)'**
  String get currencyUsd;

  /// Name of the currency EUR, with its code.
  ///
  /// In en, this message translates to:
  /// **'Euro (EUR)'**
  String get currencyEur;

  /// Menu entry of the dashboard (the start page).
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Menu entry of the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Last entry of the phone's bottom bar: opens a list with the other pages and signing out.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Name of the app's menu for screen readers (sidebar or bottom bar).
  ///
  /// In en, this message translates to:
  /// **'Main navigation'**
  String get shellNavigationLabel;

  /// Button that signs out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get shellSignOut;

  /// Title of the message shown when signing out failed on the web (the session stays).
  ///
  /// In en, this message translates to:
  /// **'You\'re still signed in'**
  String get shellSignOutFailed;

  /// Link to the design system catalog (development and staging builds only).
  ///
  /// In en, this message translates to:
  /// **'Design system'**
  String get shellDesignSystem;

  /// Read by screen readers for the account avatar of the collapsed sidebar.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String shellSignedInAs(String name);

  /// Title of the settings card with the password and two-step verification.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurityTitle;

  /// Description of the security card in the settings.
  ///
  /// In en, this message translates to:
  /// **'Your password and two-step verification.'**
  String get settingsSecurityDescription;

  /// Title of the password row in the security settings.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsPasswordLabel;

  /// Description of the password row: a change signs out the other devices.
  ///
  /// In en, this message translates to:
  /// **'Changing it signs out your other sessions.'**
  String get settingsPasswordDescription;

  /// Button of the password row, and title of the page that changes it.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsPasswordChange;

  /// Description under the title of the change password page.
  ///
  /// In en, this message translates to:
  /// **'Type your current password, then the new one.'**
  String get passwordPageDescription;

  /// Label of the field with the password in use now.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrentLabel;

  /// Label of the field with the password to set.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordNewLabel;

  /// Button that sets the new password.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get passwordSubmit;

  /// Message after the password was changed.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// Second line of the message after the password was changed.
  ///
  /// In en, this message translates to:
  /// **'Your other sessions were signed out.'**
  String get passwordChangedDescription;

  /// Error under a password field asked again before a sensitive change, when it is wrong.
  ///
  /// In en, this message translates to:
  /// **'That is not your current password.'**
  String get errorPasswordIncorrect;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
