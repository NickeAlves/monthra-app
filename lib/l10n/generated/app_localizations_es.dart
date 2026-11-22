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
  String get authCaptchaLabel => 'Verificación de seguridad';

  @override
  String get authCaptchaPrompt =>
      'Demasiados intentos seguidos. Completa la verificación de seguridad de abajo para continuar.';

  @override
  String get authCaptchaRejected =>
      'La verificación de seguridad no se aceptó. Vuelve a hacerla abajo.';

  @override
  String get authCaptchaFailed =>
      'No se pudo cargar la verificación de seguridad. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get authCaptchaUnsupported =>
      'Este navegador no puede hacer la verificación de seguridad. Actualízalo o usa otro.';

  @override
  String get authCaptchaHint => 'Esperando la verificación de seguridad…';

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

  @override
  String get appClose => 'Cerrar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsProfileTitle => 'Perfil';

  @override
  String get settingsProfileDescription => 'Cómo te llama Monthra.';

  @override
  String get settingsNameLabel => 'Nombre';

  @override
  String get settingsSaveName => 'Guardar nombre';

  @override
  String get settingsNameSaved => 'Nombre guardado.';

  @override
  String get settingsEmailLabel => 'Correo electrónico';

  @override
  String get settingsEmailHint =>
      'La dirección con la que inicias sesión. Aún no se puede cambiar.';

  @override
  String get settingsPreferencesTitle => 'Preferencias';

  @override
  String get settingsPreferencesDescription =>
      'Se guardan en tu cuenta, en todos tus dispositivos.';

  @override
  String get settingsLanguageDescription => 'La app y los correos que recibes.';

  @override
  String get settingsThemeDescription => 'Sistema sigue a tu dispositivo.';

  @override
  String get settingsCurrencyLabel => 'Moneda predeterminada';

  @override
  String get settingsCurrencyDescription => 'Se sugiere al crear una cuenta.';

  @override
  String get settingsBudgetAlertsLabel => 'Alertas de presupuesto por correo';

  @override
  String get settingsBudgetAlertsDescription =>
      'Un correo cuando un presupuesto llega a su nivel de aviso o a su límite.';

  @override
  String get settingsSaveFailed => 'Tu cambio no se guardó';

  @override
  String get currencyBrl => 'Real brasileño (BRL)';

  @override
  String get currencyUsd => 'Dólar estadounidense (USD)';

  @override
  String get currencyEur => 'Euro (EUR)';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMore => 'Más';

  @override
  String get shellNavigationLabel => 'Navegación principal';

  @override
  String get shellSignOut => 'Cerrar sesión';

  @override
  String get shellSignOutFailed => 'Sigues con la sesión iniciada';

  @override
  String get shellDesignSystem => 'Sistema de diseño';

  @override
  String shellSignedInAs(String name) {
    return 'Sesión iniciada como $name';
  }

  @override
  String get settingsSecurityTitle => 'Seguridad';

  @override
  String get settingsSecurityDescription =>
      'Tu contraseña y la verificación en dos pasos.';

  @override
  String get settingsPasswordLabel => 'Contraseña';

  @override
  String get settingsPasswordDescription =>
      'Al cambiarla, se cierran tus otras sesiones.';

  @override
  String get settingsPasswordChange => 'Cambiar contraseña';

  @override
  String get passwordPageDescription =>
      'Escribe tu contraseña actual y luego la nueva.';

  @override
  String get passwordCurrentLabel => 'Contraseña actual';

  @override
  String get passwordNewLabel => 'Nueva contraseña';

  @override
  String get passwordSubmit => 'Guardar nueva contraseña';

  @override
  String get passwordChanged => 'Contraseña cambiada';

  @override
  String get passwordChangedDescription => 'Tus otras sesiones se cerraron.';

  @override
  String get errorPasswordIncorrect => 'Esa no es tu contraseña actual.';

  @override
  String get settingsMfaLabel => 'Verificación en dos pasos';

  @override
  String get settingsMfaOn => 'Activada';

  @override
  String get settingsMfaOff => 'Desactivada';

  @override
  String get settingsMfaOnDescription =>
      'El inicio de sesión también pide un código de tu app de autenticación.';

  @override
  String get settingsMfaOffDescription =>
      'Pide un código de una app de autenticación al iniciar sesión, además de la contraseña.';

  @override
  String get settingsMfaTurnOn => 'Activar';

  @override
  String get settingsMfaTurnOff => 'Desactivar';

  @override
  String get settingsRecoveryCodesLabel => 'Códigos de recuperación';

  @override
  String settingsRecoveryCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count códigos.',
      one: 'Queda 1 código.',
      zero: 'No quedan códigos.',
    );
    return '$_temp0 Cada uno inicia sesión una vez sin la app.';
  }

  @override
  String get settingsRecoveryCodesLow =>
      'Genera nuevos antes de que se acaben.';

  @override
  String get settingsRecoveryCodesNew => 'Generar nuevos códigos';

  @override
  String get mfaEnableTitle => 'Activar la verificación en dos pasos';

  @override
  String get mfaEnablePasswordDescription =>
      'Confirma tu contraseña para empezar.';

  @override
  String get mfaContinue => 'Continuar';

  @override
  String get mfaScanDescription =>
      'Agrega Monthra a tu app de autenticación y escribe el código que muestre.';

  @override
  String get mfaScanStep => 'Escanea este código QR con la app.';

  @override
  String get mfaQrLabel =>
      'Código QR para agregar Monthra a la app de autenticación';

  @override
  String get mfaOpenAuthenticator => 'Abrir en la app de autenticación';

  @override
  String get mfaNoAuthenticator =>
      'No se abrió ninguna app de autenticación. Escribe la clave.';

  @override
  String get mfaSecretLabel => 'O escribe esta clave en la app';

  @override
  String get mfaCopySecret => 'Copiar clave';

  @override
  String get mfaSecretCopied => 'Clave copiada.';

  @override
  String get mfaConfirmStep =>
      'Luego escribe el código de 6 dígitos que muestre la app.';

  @override
  String get mfaEnableSubmit => 'Activar';

  @override
  String get mfaSetupExpired => 'La configuración caducó. Empieza de nuevo.';

  @override
  String get mfaAlreadyOn => 'La verificación en dos pasos ya está activada.';

  @override
  String get mfaAlreadyOff => 'La verificación en dos pasos está desactivada.';

  @override
  String get mfaEnabledToast => 'Verificación en dos pasos activada';

  @override
  String get mfaDisableTitle => 'Desactivar la verificación en dos pasos';

  @override
  String get mfaDisableDescription =>
      'El inicio de sesión pedirá solo el correo y la contraseña. Confirma con tu contraseña y un código.';

  @override
  String get mfaDisableSubmit => 'Desactivar';

  @override
  String get mfaDisabledToast => 'Verificación en dos pasos desactivada';

  @override
  String get recoveryRegenerateDescription =>
      'Los códigos que tienes ahora dejan de funcionar. Confirma con tu contraseña y un código.';

  @override
  String get recoveryRegenerateSubmit => 'Generar nuevos códigos';

  @override
  String get recoveryCodesTitle => 'Guarda tus códigos de recuperación';

  @override
  String get recoveryCodesDescription =>
      'Cada código inicia sesión una vez si pierdes la app de autenticación. Solo se muestran ahora: guárdalos en un lugar seguro, como un gestor de contraseñas.';

  @override
  String get recoveryCodesListLabel => 'Códigos de recuperación';

  @override
  String get recoveryCodesCopy => 'Copiar todos';

  @override
  String get recoveryCodesCopied => 'Códigos copiados.';

  @override
  String get recoveryCodesSaved => 'Guardé estos códigos en un lugar seguro';

  @override
  String get recoveryCodesDone => 'Listo';

  @override
  String get recoveryCodesLeaveTitle => '¿Salir sin guardar los códigos?';

  @override
  String get recoveryCodesLeaveDescription =>
      'No se volverán a mostrar. Puedes generar nuevos en Ajustes.';

  @override
  String get recoveryCodesLeave => 'Salir de todos modos';

  @override
  String get recoveryCodesStay => 'Quedarme';

  @override
  String get recoveryCodesNewToast =>
      'Nuevos códigos de recuperación generados';

  @override
  String get appCancel => 'Cancelar';

  @override
  String get sessionsTitle => 'Sesiones';

  @override
  String get sessionsDescription =>
      'Dispositivos con sesión iniciada en tu cuenta. Cierra los que no reconozcas.';

  @override
  String get sessionsThisDevice => 'Este dispositivo';

  @override
  String get sessionsActiveNow => 'En uso ahora';

  @override
  String sessionsLastActive(String date) {
    return 'Activa por última vez el $date';
  }

  @override
  String sessionsIp(String ip) {
    return 'IP $ip';
  }

  @override
  String sessionsDevice(String browser, String os) {
    return '$browser en $os';
  }

  @override
  String sessionsApp(String os) {
    return 'App Monthra en $os';
  }

  @override
  String get sessionsUnknownDevice => 'Dispositivo desconocido';

  @override
  String get sessionsRevoke => 'Cerrar sesión';

  @override
  String sessionsRevokeLabel(String device) {
    return 'Cerrar sesión en $device';
  }

  @override
  String get sessionsRevoked => 'Sesión cerrada.';

  @override
  String get sessionsRevokeOthers => 'Cerrar todas las demás sesiones';

  @override
  String get sessionsRevokeOthersTitle => '¿Cerrar todas las demás sesiones?';

  @override
  String get sessionsRevokeOthersDescription =>
      'Los demás dispositivos tendrán que iniciar sesión de nuevo. Este sigue conectado.';

  @override
  String get sessionsRevokeOthersConfirm => 'Cerrar las demás';

  @override
  String get sessionsOthersRevoked => 'Otras sesiones cerradas.';

  @override
  String get sessionsNoOthers =>
      'Ningún otro dispositivo tiene la sesión iniciada.';

  @override
  String get sessionsLoadFailed => 'No se pudieron cargar las sesiones';

  @override
  String get sessionsRevokeFailed => 'No se cerró la sesión';

  @override
  String get settingsDataTitle => 'Tus datos';

  @override
  String get settingsDataDescription =>
      'Descarga una copia de todo lo que hay en tu cuenta o elimínala.';

  @override
  String get settingsExportLabel => 'Exportar mis datos';

  @override
  String get settingsExportDescription =>
      'Un archivo ZIP con tus registros en JSON. Te avisamos por correo en cada exportación.';

  @override
  String get settingsExportOpen => 'Exportar';

  @override
  String get settingsDeleteLabel => 'Eliminar cuenta';

  @override
  String get settingsDeleteDescription =>
      'Borra la cuenta y todos sus datos. No se puede deshacer.';

  @override
  String get settingsDeleteOpen => 'Eliminar mi cuenta';

  @override
  String get exportDataTitle => 'Exportar mis datos';

  @override
  String get exportDataDescription =>
      'Descarga una copia de todo lo que guarda tu cuenta, para conservarla o llevarla a otro servicio.';

  @override
  String get exportDataContentsTitle => 'Qué contiene el archivo';

  @override
  String get exportDataIncludes =>
      'Tu perfil, cuentas, categorías, transacciones, recurrencias, presupuestos, inversiones y sus movimientos, sesiones y eventos de seguridad, en archivos JSON.';

  @override
  String get exportDataExcludes =>
      'Nunca tu contraseña, la clave de la verificación en dos pasos ni los códigos de recuperación.';

  @override
  String exportDataEmail(String email) {
    return 'Cada exportación envía un correo a $email. Puedes exportar algunas veces por hora.';
  }

  @override
  String get exportDataConfirmTitle => 'Confirma que eres tú';

  @override
  String get exportDataSubmit => 'Exportar';

  @override
  String get exportDataBusy => 'Preparando el archivo…';

  @override
  String get exportDataReadyTitle => 'Tu archivo está listo';

  @override
  String exportDataReadyDescription(String name) {
    return '$name. Guárdalo en un lugar al que solo tú accedas: contiene tus registros financieros.';
  }

  @override
  String get exportDataSave => 'Guardar archivo';

  @override
  String get fileSaved => 'Archivo guardado';

  @override
  String get fileNotSaved =>
      'El archivo no se guardó. Puedes guardarlo de nuevo sin exportar otra vez.';

  @override
  String get fileSaveFailed =>
      'No se pudo guardar el archivo. Inténtalo de nuevo.';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountDescription =>
      'Esto borra tu cuenta y todo lo que contiene, en todos los dispositivos.';

  @override
  String get deleteAccountWhatTitle => 'Qué ocurre';

  @override
  String get deleteAccountErased =>
      'Se borran tus cuentas, transacciones, categorías, recurrencias, presupuestos e inversiones.';

  @override
  String get deleteAccountSignedOut =>
      'Todas las sesiones terminan, en este dispositivo y en los demás.';

  @override
  String get deleteAccountKept =>
      'Solo el registro de seguridad, sin direcciones, se conserva durante su plazo de retención.';

  @override
  String deleteAccountEmail(String email) {
    return 'Enviamos una confirmación a $email.';
  }

  @override
  String get deleteAccountFinal => 'No se puede deshacer.';

  @override
  String get deleteAccountExportFirst => 'Exportar mis datos antes';

  @override
  String get deleteAccountConfirmTitle => 'Confirma que eres tú';

  @override
  String get deleteAccountSubmit => 'Eliminar cuenta';

  @override
  String get deleteAccountDialogTitle => '¿Eliminar tu cuenta para siempre?';

  @override
  String get deleteAccountDialogDescription =>
      'Tus datos se borran ahora y no se pueden recuperar.';

  @override
  String get deleteAccountDialogConfirm => 'Eliminar para siempre';

  @override
  String get authNoticeAccountDeleted =>
      'Tu cuenta y sus datos se eliminaron. Te enviamos una confirmación por correo.';
}
