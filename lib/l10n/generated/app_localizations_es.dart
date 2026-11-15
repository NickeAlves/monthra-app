// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get preferencesLanguage => 'Idioma';

  @override
  String get preferencesTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get authTagline => 'Tus finanzas, mes a mes.';

  @override
  String get authSignInTitle => 'Iniciar sesión';

  @override
  String get authSignInSubtitle => 'Qué bueno verte de nuevo.';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authNewPasswordHint => 'Al menos 10 caracteres.';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authForgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get authSignInButton => 'Iniciar sesión';

  @override
  String get authNoAccount => '¿Aún no tienes cuenta?';

  @override
  String get authCreateAccountLink => 'Crear cuenta';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authNoticeSessionExpired =>
      'Tu sesión terminó. Vuelve a iniciar sesión.';

  @override
  String get authNoticePasswordReset =>
      'Contraseña cambiada. Inicia sesión con la nueva.';

  @override
  String get authNoticeMfaExpired =>
      'La verificación caducó. Vuelve a iniciar sesión.';

  @override
  String get authEmailNotVerified =>
      'Confirma tu correo antes de iniciar sesión. El enlace está en tu bandeja de entrada.';

  @override
  String get authResendVerification => 'Reenviar correo';

  @override
  String authResendIn(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String authVerificationSent(String email) {
    return 'Enviamos un nuevo enlace a $email.';
  }

  @override
  String get authMfaTitle => 'Verificación en dos pasos';

  @override
  String get authMfaSubtitle =>
      'Introduce el código de 6 dígitos de tu app de autenticación.';

  @override
  String get authMfaCodeLabel => 'Código';

  @override
  String get authMfaRecoverySubtitle =>
      'Introduce uno de tus códigos de recuperación. Cada uno funciona una vez.';

  @override
  String get authMfaRecoveryLabel => 'Código de recuperación';

  @override
  String get authMfaUseRecovery => 'Usar un código de recuperación';

  @override
  String get authMfaUseApp => 'Usar la app de autenticación';

  @override
  String get authMfaVerifyButton => 'Verificar';

  @override
  String get authBackToSignIn => 'Volver a iniciar sesión';

  @override
  String get authRegisterTitle => 'Crea tu cuenta';

  @override
  String get authRegisterSubtitle =>
      'Gastos, ingresos e inversiones en un solo lugar.';

  @override
  String get authNameLabel => 'Nombre';

  @override
  String get authRegisterButton => 'Crear cuenta';

  @override
  String get authCheckInboxTitle => 'Revisa tu bandeja de entrada';

  @override
  String authCheckInboxMessage(String email) {
    return 'Enviamos un enlace de confirmación a $email. Es válido durante 30 minutos. Si no llega, revisa la carpeta de spam.';
  }

  @override
  String get authForgotTitle => 'Restablecer la contraseña';

  @override
  String get authForgotSubtitle =>
      'Introduce el correo de tu cuenta y te enviaremos un enlace.';

  @override
  String get authForgotButton => 'Enviar enlace';

  @override
  String authForgotSentMessage(String email) {
    return 'Si existe una cuenta para $email, el enlace llegará en breve. Es válido durante 15 minutos.';
  }

  @override
  String get authResetTitle => 'Elige una nueva contraseña';

  @override
  String get authResetSubtitle =>
      'Se cerrará la sesión en todos los dispositivos.';

  @override
  String get authResetButton => 'Cambiar contraseña';

  @override
  String get authLinkInvalidTitle => 'Este enlace ya no funciona';

  @override
  String get authResetLinkInvalidMessage =>
      'Caducó o ya se usó. Pide uno nuevo.';

  @override
  String get authRequestNewLink => 'Pedir un nuevo enlace';

  @override
  String get authVerifyingTitle => 'Confirmando tu correo…';

  @override
  String get authVerifiedTitle => 'Correo confirmado';

  @override
  String get authVerifiedMessage =>
      'Tu cuenta está lista. Inicia sesión para empezar.';

  @override
  String get authVerifyLinkInvalidMessage =>
      'Caducó o ya se usó. Introduce tu correo para recibir uno nuevo.';

  @override
  String get authContinue => 'Continuar';

  @override
  String get appUnavailableTitle => 'No podemos conectar con Monthra';

  @override
  String get appRetry => 'Reintentar';

  @override
  String get notFoundTitle => 'Página no encontrada';

  @override
  String get notFoundMessage =>
      'La dirección puede ser incorrecta, o la página cambió de lugar.';

  @override
  String get notFoundHome => 'Ir al inicio';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get homeComingSoon => 'Tu panel llega en las próximas versiones.';

  @override
  String get homeSignOut => 'Cerrar sesión';

  @override
  String get homeDesignSystem => 'Sistema de diseño';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String errorRateLimited(int seconds) {
    return 'Demasiados intentos. Vuelve a intentarlo en $seconds s.';
  }

  @override
  String get errorRateLimitedSoon =>
      'Demasiados intentos. Vuelve a intentarlo en un momento.';

  @override
  String get errorCaptcha =>
      'Demasiados intentos seguidos. Espera unos minutos y vuelve a intentarlo.';

  @override
  String get errorMfaCodeInvalid =>
      'Código incorrecto o ya usado. Espera al siguiente.';

  @override
  String get errorOffline =>
      'Sin conexión con el servidor. Revisa tu conexión a internet.';

  @override
  String get errorTimeout =>
      'El servidor tardó demasiado en responder. Vuelve a intentarlo.';

  @override
  String get errorUnavailable =>
      'El servicio no está disponible ahora. Vuelve a intentarlo en un momento.';

  @override
  String get errorCheckFields => 'Revisa los campos resaltados.';

  @override
  String get errorGeneric => 'Algo salió mal. Vuelve a intentarlo.';

  @override
  String errorReference(String id) {
    return 'Referencia: $id';
  }

  @override
  String get errorFieldRequired => 'Obligatorio.';

  @override
  String get errorEmailInvalid => 'Introduce un correo válido.';

  @override
  String get errorFieldInvalid => 'Valor no válido.';

  @override
  String errorTooShort(int min) {
    return 'Usa al menos $min caracteres.';
  }

  @override
  String errorTooLong(int max) {
    return 'Usa como máximo $max caracteres.';
  }

  @override
  String get errorPasswordBreached =>
      'Esta contraseña apareció en filtraciones de datos. Elige otra.';

  @override
  String get errorMfaCodeFormat => 'Introduce los 6 dígitos.';
}
