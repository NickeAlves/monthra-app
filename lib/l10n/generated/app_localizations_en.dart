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
  String get authCaptchaLabel => 'Security check';

  @override
  String get authCaptchaPrompt =>
      'Too many attempts in a row. Complete the security check below to go on.';

  @override
  String get authCaptchaRejected =>
      'The security check wasn\'t accepted. Try it again below.';

  @override
  String get authCaptchaFailed =>
      'The security check couldn\'t load. Check your connection and try again.';

  @override
  String get authCaptchaUnsupported =>
      'This browser can\'t run the security check. Update it or use another one.';

  @override
  String get authCaptchaHint => 'Waiting for the security check…';

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

  @override
  String get appClose => 'Close';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfileTitle => 'Profile';

  @override
  String get settingsProfileDescription => 'How Monthra addresses you.';

  @override
  String get settingsNameLabel => 'Name';

  @override
  String get settingsSaveName => 'Save name';

  @override
  String get settingsNameSaved => 'Name saved.';

  @override
  String get settingsEmailLabel => 'Email';

  @override
  String get settingsEmailHint =>
      'The address you sign in with. It can\'t be changed yet.';

  @override
  String get settingsPreferencesTitle => 'Preferences';

  @override
  String get settingsPreferencesDescription =>
      'Saved to your account, on every device.';

  @override
  String get settingsLanguageDescription => 'The app and the emails you get.';

  @override
  String get settingsThemeDescription => 'System follows your device.';

  @override
  String get settingsCurrencyLabel => 'Default currency';

  @override
  String get settingsCurrencyDescription =>
      'Suggested when you add an account.';

  @override
  String get settingsBudgetAlertsLabel => 'Budget alert emails';

  @override
  String get settingsBudgetAlertsDescription =>
      'An email when a budget reaches its warning level or its limit.';

  @override
  String get settingsSaveFailed => 'Your change wasn\'t saved';

  @override
  String get currencyBrl => 'Brazilian real (BRL)';

  @override
  String get currencyUsd => 'US dollar (USD)';

  @override
  String get currencyEur => 'Euro (EUR)';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMore => 'More';

  @override
  String get shellNavigationLabel => 'Main navigation';

  @override
  String get shellSignOut => 'Sign out';

  @override
  String get shellSignOutFailed => 'You\'re still signed in';

  @override
  String get shellDesignSystem => 'Design system';

  @override
  String shellSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get settingsSecurityTitle => 'Security';

  @override
  String get settingsSecurityDescription =>
      'Your password and two-step verification.';

  @override
  String get settingsPasswordLabel => 'Password';

  @override
  String get settingsPasswordDescription =>
      'Changing it signs out your other sessions.';

  @override
  String get settingsPasswordChange => 'Change password';

  @override
  String get passwordPageDescription =>
      'Type your current password, then the new one.';

  @override
  String get passwordCurrentLabel => 'Current password';

  @override
  String get passwordNewLabel => 'New password';

  @override
  String get passwordSubmit => 'Save new password';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get passwordChangedDescription =>
      'Your other sessions were signed out.';

  @override
  String get errorPasswordIncorrect => 'That is not your current password.';

  @override
  String get settingsMfaLabel => 'Two-step verification';

  @override
  String get settingsMfaOn => 'On';

  @override
  String get settingsMfaOff => 'Off';

  @override
  String get settingsMfaOnDescription =>
      'Signing in also asks for a code from your authenticator app.';

  @override
  String get settingsMfaOffDescription =>
      'Ask for a code from an authenticator app when signing in, besides the password.';

  @override
  String get settingsMfaTurnOn => 'Turn on';

  @override
  String get settingsMfaTurnOff => 'Turn off';

  @override
  String get settingsRecoveryCodesLabel => 'Recovery codes';

  @override
  String settingsRecoveryCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes left.',
      one: '1 code left.',
      zero: 'No codes left.',
    );
    return '$_temp0 Each one signs you in once without the app.';
  }

  @override
  String get settingsRecoveryCodesLow => 'Create new ones before they run out.';

  @override
  String get settingsRecoveryCodesNew => 'Create new codes';

  @override
  String get mfaEnableTitle => 'Turn on two-step verification';

  @override
  String get mfaEnablePasswordDescription => 'Confirm your password to start.';

  @override
  String get mfaContinue => 'Continue';

  @override
  String get mfaScanDescription =>
      'Add Monthra to your authenticator app, then type the code it shows.';

  @override
  String get mfaScanStep => 'Scan this QR code with the app.';

  @override
  String get mfaQrLabel => 'QR code to add Monthra to your authenticator app';

  @override
  String get mfaOpenAuthenticator => 'Open in the authenticator app';

  @override
  String get mfaNoAuthenticator =>
      'No authenticator app opened. Type the key instead.';

  @override
  String get mfaSecretLabel => 'Or type this key in the app';

  @override
  String get mfaCopySecret => 'Copy key';

  @override
  String get mfaSecretCopied => 'Key copied.';

  @override
  String get mfaConfirmStep => 'Then type the 6-digit code the app shows.';

  @override
  String get mfaEnableSubmit => 'Turn on';

  @override
  String get mfaSetupExpired => 'The setup expired. Start again.';

  @override
  String get mfaAlreadyOn => 'Two-step verification is already on.';

  @override
  String get mfaAlreadyOff => 'Two-step verification is off.';

  @override
  String get mfaEnabledToast => 'Two-step verification turned on';

  @override
  String get mfaDisableTitle => 'Turn off two-step verification';

  @override
  String get mfaDisableDescription =>
      'Signing in will ask only for your email and password. Confirm with your password and a code.';

  @override
  String get mfaDisableSubmit => 'Turn off';

  @override
  String get mfaDisabledToast => 'Two-step verification turned off';

  @override
  String get recoveryRegenerateDescription =>
      'The codes you have now stop working. Confirm with your password and a code.';

  @override
  String get recoveryRegenerateSubmit => 'Create new codes';

  @override
  String get recoveryCodesTitle => 'Save your recovery codes';

  @override
  String get recoveryCodesDescription =>
      'Each code signs you in once if you lose the authenticator app. They are shown only now: keep them somewhere safe, like a password manager.';

  @override
  String get recoveryCodesListLabel => 'Recovery codes';

  @override
  String get recoveryCodesCopy => 'Copy all';

  @override
  String get recoveryCodesCopied => 'Codes copied.';

  @override
  String get recoveryCodesSaved => 'I saved these codes somewhere safe';

  @override
  String get recoveryCodesDone => 'Done';

  @override
  String get recoveryCodesLeaveTitle => 'Leave without saving the codes?';

  @override
  String get recoveryCodesLeaveDescription =>
      'They will not be shown again. You can create new ones in Settings.';

  @override
  String get recoveryCodesLeave => 'Leave';

  @override
  String get recoveryCodesStay => 'Stay';

  @override
  String get recoveryCodesNewToast => 'New recovery codes created';

  @override
  String get appCancel => 'Cancel';

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String get sessionsDescription =>
      'Devices signed in to your account. Sign out any you don\'t recognize.';

  @override
  String get sessionsThisDevice => 'This device';

  @override
  String get sessionsActiveNow => 'In use now';

  @override
  String sessionsLastActive(String date) {
    return 'Last active $date';
  }

  @override
  String sessionsIp(String ip) {
    return 'IP $ip';
  }

  @override
  String sessionsDevice(String browser, String os) {
    return '$browser on $os';
  }

  @override
  String sessionsApp(String os) {
    return 'Monthra app on $os';
  }

  @override
  String get sessionsUnknownDevice => 'Unknown device';

  @override
  String get sessionsRevoke => 'Sign out';

  @override
  String sessionsRevokeLabel(String device) {
    return 'Sign out $device';
  }

  @override
  String get sessionsRevoked => 'Session signed out.';

  @override
  String get sessionsRevokeOthers => 'Sign out of all other sessions';

  @override
  String get sessionsRevokeOthersTitle => 'Sign out of every other session?';

  @override
  String get sessionsRevokeOthersDescription =>
      'The other devices will have to sign in again. This one stays signed in.';

  @override
  String get sessionsRevokeOthersConfirm => 'Sign out others';

  @override
  String get sessionsOthersRevoked => 'Other sessions signed out.';

  @override
  String get sessionsNoOthers => 'No other device is signed in.';

  @override
  String get sessionsLoadFailed => 'Couldn\'t load the sessions';

  @override
  String get sessionsRevokeFailed => 'The session was not signed out';

  @override
  String get settingsDataTitle => 'Your data';

  @override
  String get settingsDataDescription =>
      'Take a copy of everything in your account, or delete it.';

  @override
  String get settingsExportLabel => 'Export my data';

  @override
  String get settingsExportDescription =>
      'A ZIP file with your records in JSON. We email you after each export.';

  @override
  String get settingsExportOpen => 'Export';

  @override
  String get settingsDeleteLabel => 'Delete account';

  @override
  String get settingsDeleteDescription =>
      'Erases the account and all its data. This cannot be undone.';

  @override
  String get settingsDeleteOpen => 'Delete my account';

  @override
  String get exportDataTitle => 'Export my data';

  @override
  String get exportDataDescription =>
      'Download a copy of everything your account holds, to keep or to take to another service.';

  @override
  String get exportDataContentsTitle => 'What the file holds';

  @override
  String get exportDataIncludes =>
      'Your profile, accounts, categories, transactions, recurrences, budgets, investments and their movements, sessions and security events, as JSON files.';

  @override
  String get exportDataExcludes =>
      'Never your password, the two-step verification key or the recovery codes.';

  @override
  String exportDataEmail(String email) {
    return 'Each export sends an email to $email. You can export a few times per hour.';
  }

  @override
  String get exportDataConfirmTitle => 'Confirm it\'s you';

  @override
  String get exportDataSubmit => 'Export';

  @override
  String get exportDataBusy => 'Preparing the file…';

  @override
  String get exportDataReadyTitle => 'Your file is ready';

  @override
  String exportDataReadyDescription(String name) {
    return '$name. Save it somewhere only you can open: it holds your financial records.';
  }

  @override
  String get exportDataSave => 'Save file';

  @override
  String get fileSaved => 'File saved';

  @override
  String get fileNotSaved =>
      'The file was not saved. You can save it again without a new export.';

  @override
  String get fileSaveFailed => 'The file could not be saved. Try again.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountDescription =>
      'This erases your account and everything in it, on every device.';

  @override
  String get deleteAccountWhatTitle => 'What happens';

  @override
  String get deleteAccountErased =>
      'Your accounts, transactions, categories, recurrences, budgets and investments are erased.';

  @override
  String get deleteAccountSignedOut =>
      'Every session ends, on this device and the others.';

  @override
  String get deleteAccountKept =>
      'Only the security log is kept, without addresses, for its retention period.';

  @override
  String deleteAccountEmail(String email) {
    return 'We email $email to confirm.';
  }

  @override
  String get deleteAccountFinal => 'This cannot be undone.';

  @override
  String get deleteAccountExportFirst => 'Export my data first';

  @override
  String get deleteAccountConfirmTitle => 'Confirm it\'s you';

  @override
  String get deleteAccountSubmit => 'Delete account';

  @override
  String get deleteAccountDialogTitle => 'Delete your account for good?';

  @override
  String get deleteAccountDialogDescription =>
      'Your data is erased now and cannot be recovered.';

  @override
  String get deleteAccountDialogConfirm => 'Delete for good';

  @override
  String get authNoticeAccountDeleted =>
      'Your account and its data were deleted. We sent you a confirmation email.';

  @override
  String get recoveryCodesDownload => 'Download .txt';

  @override
  String get recoveryCodesFileTitle => 'Monthra recovery codes';

  @override
  String recoveryCodesFileAccount(String email) {
    return 'Account: $email';
  }

  @override
  String recoveryCodesFileCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Created: $dateString';
  }

  @override
  String get recoveryCodesFileNote =>
      'Each code signs you in once, in place of a code from the authenticator app.';
}
