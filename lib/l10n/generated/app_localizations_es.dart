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
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get dashboardPreviousMonth => 'Mes anterior';

  @override
  String get dashboardNextMonth => 'Mes siguiente';

  @override
  String get dashboardThisMonth => 'Este mes';

  @override
  String get dashboardRefresh => 'Actualizar';

  @override
  String get dashboardLoading => 'Cargando el panel';

  @override
  String get dashboardLoadError => 'No se pudo cargar el panel';

  @override
  String get dashboardEmptyTitle => 'Aún no hay cuentas';

  @override
  String get dashboardEmptyMessage =>
      'Tu mes aparecerá aquí en cuanto añadas una cuenta.';

  @override
  String get dashboardBalance => 'Saldo';

  @override
  String dashboardBalanceOn(String date) {
    return 'Al $date';
  }

  @override
  String get dashboardIncome => 'Ingresos';

  @override
  String get dashboardExpenses => 'Gastos';

  @override
  String get dashboardNet => 'Resultado del mes';

  @override
  String get dashboardNetHint => 'Ingresos menos gastos';

  @override
  String dashboardScheduled(String amount) {
    return '$amount aún previsto';
  }

  @override
  String get dashboardNothingScheduled => 'Nada más previsto';

  @override
  String get dashboardByCategory => 'Por categoría';

  @override
  String get dashboardCategoryKind => 'Mostrar';

  @override
  String get dashboardNoExpenses => 'Ningún gasto este mes';

  @override
  String get dashboardNoIncome => 'Ningún ingreso este mes';

  @override
  String get dashboardOtherCategories => 'Otras';

  @override
  String get dashboardUnknownCategory => 'Categoría';

  @override
  String dashboardEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movimientos',
      one: '1 movimiento',
    );
    return '$_temp0';
  }

  @override
  String dashboardCategoryShare(String name, String amount, String percent) {
    return '$name: $amount, $percent';
  }

  @override
  String dashboardExpensesChart(String parts) {
    return 'Gastos por categoría: $parts';
  }

  @override
  String dashboardIncomeChart(String parts) {
    return 'Ingresos por categoría: $parts';
  }

  @override
  String get dashboardCashFlow => 'Ingresos y gastos';

  @override
  String get dashboardLast12Months => 'Últimos 12 meses';

  @override
  String dashboardCashFlowChart(
    String first,
    String last,
    String month,
    String income,
    String expense,
  ) {
    return 'Ingresos y gastos de $first a $last. En $month: ingresos $income, gastos $expense.';
  }

  @override
  String get dashboardNetWorth => 'Patrimonio';

  @override
  String dashboardNetWorthChart(
    String first,
    String last,
    String start,
    String end,
  ) {
    return 'Patrimonio de $first a $last: de $start a $end.';
  }

  @override
  String get dashboardNoNetWorth =>
      'Los meses que aún no llegan no tienen patrimonio.';

  @override
  String get dashboardAccounts => 'Cuentas';

  @override
  String get dashboardArchived => 'Archivada';

  @override
  String get dashboardUnknownAccount => 'Cuenta';

  @override
  String get accountTypeChecking => 'Cuenta corriente';

  @override
  String get accountTypeSavings => 'Ahorros';

  @override
  String get accountTypeCreditCard => 'Tarjeta de crédito';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeBrokerage => 'Cuenta de inversión';

  @override
  String get accountTypeOther => 'Cuenta';

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

  @override
  String get recoveryCodesDownload => 'Descargar .txt';

  @override
  String get recoveryCodesFileTitle => 'Códigos de recuperación de Monthra';

  @override
  String recoveryCodesFileAccount(String email) {
    return 'Cuenta: $email';
  }

  @override
  String recoveryCodesFileCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Generados el: $dateString';
  }

  @override
  String get recoveryCodesFileNote =>
      'Cada código inicia sesión una vez, en lugar de un código de la app de autenticación.';

  @override
  String get navAccounts => 'Cuentas';

  @override
  String get accountsTitle => 'Cuentas';

  @override
  String get accountsDescription =>
      'Cuentas, tarjetas, efectivo y brókeres, con su saldo de hoy.';

  @override
  String get accountsNew => 'Nueva cuenta';

  @override
  String get accountsEmptyTitle => 'Aún no hay cuentas';

  @override
  String get accountsEmptyMessage =>
      'Añade dónde está tu dinero: una cuenta, una tarjeta, efectivo o un bróker.';

  @override
  String get accountsCreateFirst => 'Crear cuenta';

  @override
  String get accountsLoadError => 'No se pudieron cargar tus cuentas';

  @override
  String get accountsLoading => 'Cargando las cuentas';

  @override
  String accountsGroupTotal(String currency) {
    return 'Total en $currency';
  }

  @override
  String accountsShowArchived(int count) {
    return 'Mostrar archivadas ($count)';
  }

  @override
  String get accountsHideArchived => 'Ocultar archivadas';

  @override
  String get accountsArchivedTitle => 'Archivadas';

  @override
  String get accountsArchived => 'Archivada';

  @override
  String get accountsImported => 'Importada';

  @override
  String accountsCardAvailable(String amount) {
    return '$amount disponible';
  }

  @override
  String accountsCardDue(int day) {
    return 'Vence el día $day';
  }

  @override
  String get accountFormEditTitle => 'Editar cuenta';

  @override
  String get accountFormNewDescription =>
      'El tipo y la moneda no se pueden cambiar después.';

  @override
  String get accountFormName => 'Nombre';

  @override
  String get accountFormType => 'Tipo';

  @override
  String get accountFormCurrency => 'Moneda';

  @override
  String get accountFormFixed =>
      'El tipo y la moneda de una cuenta no cambian.';

  @override
  String get accountFormInitialBalance => 'Saldo inicial';

  @override
  String get accountFormInitialBalanceHint =>
      'Lo que tiene hoy, antes de lo que registres aquí.';

  @override
  String get accountFormInitialBalanceEditHint =>
      'El saldo antes de las transacciones registradas aquí: cambiarlo mueve todos los saldos.';

  @override
  String get accountFormNegative => 'Saldo negativo (descubierto)';

  @override
  String get accountFormCardDebt => 'Deuda hoy';

  @override
  String get accountFormCardDebtHint =>
      'Lo que debes en la tarjeta hoy, antes de lo que registres aquí.';

  @override
  String get accountFormCardDebtEdit => 'Deuda inicial';

  @override
  String get accountFormCardDebtEditHint =>
      'Lo que debía la tarjeta antes de las transacciones registradas aquí: cambiarla mueve todas las facturas.';

  @override
  String get accountFormCardCredit => 'La tarjeta tiene saldo a favor';

  @override
  String get accountFormClosingDay => 'Día de cierre';

  @override
  String get accountFormDueDay => 'Día de vencimiento';

  @override
  String get accountFormDayHint => 'En los meses más cortos, el último día.';

  @override
  String accountFormDay(int day) {
    return 'Día $day';
  }

  @override
  String get accountFormLimit => 'Límite de crédito';

  @override
  String get accountFormLimitHint => 'Opcional.';

  @override
  String accountFormCyclePreview(String closing, String due) {
    return 'La próxima factura cierra el $closing y vence el $due.';
  }

  @override
  String get accountFormCreate => 'Crear cuenta';

  @override
  String get accountFormSave => 'Guardar cambios';

  @override
  String get accountFormCreated => 'Cuenta creada';

  @override
  String get accountFormSaved => 'Cambios guardados';

  @override
  String get accountFormLimitReached =>
      'Llegaste al límite de cuentas. Archiva o elimina una antes.';

  @override
  String get formDiscardTitle => '¿Descartar los cambios?';

  @override
  String get formDiscard => 'Descartar';

  @override
  String get formKeepEditing => 'Seguir editando';

  @override
  String get accountFormDayPlaceholder => 'Elige';

  @override
  String get accountDetailBalance => 'Saldo hoy';

  @override
  String accountDetailProjected(String amount) {
    return 'Con las transacciones futuras: $amount';
  }

  @override
  String get accountDetailEdit => 'Editar';

  @override
  String get accountDetailArchive => 'Archivar';

  @override
  String get accountDetailUnarchive => 'Desarchivar';

  @override
  String get accountDetailDelete => 'Eliminar';

  @override
  String get accountDetailArchivedToast => 'Cuenta archivada';

  @override
  String get accountDetailUnarchivedToast => 'Cuenta desarchivada';

  @override
  String get accountDetailArchivedNotice =>
      'Archivada: conserva su historial, fuera de tus listas y de nuevas transacciones.';

  @override
  String get accountDetailActionFailed => 'No se pudo cambiar la cuenta';

  @override
  String get accountDeleteTitle => '¿Eliminar esta cuenta?';

  @override
  String get accountDeleteMessage =>
      'Se elimina para siempre. Solo se puede eliminar una cuenta sin transacciones; archiva las que las tienen.';

  @override
  String get accountDeletedToast => 'Cuenta eliminada';

  @override
  String get accountInUseTitle => 'Esta cuenta tiene transacciones';

  @override
  String get accountInUseMessage =>
      'Archívala: conserva su historial y sale de tus listas.';

  @override
  String get accountUsedByRecurrence =>
      'Una transacción recurrente usa esta cuenta. Termínala o muévela a otra cuenta antes.';

  @override
  String get accountNotFoundTitle => 'Cuenta no encontrada';

  @override
  String get accountNotFoundMessage => 'Puede que se haya eliminado.';

  @override
  String get accountBackToAccounts => 'Volver a las cuentas';

  @override
  String get accountCardLimit => 'Límite de la tarjeta';

  @override
  String accountCardUsed(String amount) {
    return '$amount usado';
  }

  @override
  String accountCardOverLimit(String amount) {
    return '$amount por encima del límite';
  }

  @override
  String get accountCardNoLimit => 'Sin límite definido';

  @override
  String accountCardCycle(int closing, int due) {
    return 'Cierra el día $closing, vence el día $due';
  }

  @override
  String get invoicesTitle => 'Facturas';

  @override
  String get invoicesPrevious => 'Factura anterior';

  @override
  String get invoicesNext => 'Factura siguiente';

  @override
  String get invoicesOpen => 'Factura abierta';

  @override
  String get invoicesAround => 'Meses alrededor';

  @override
  String get invoicesLoadError => 'No se pudieron cargar las facturas';

  @override
  String get invoicesLoading => 'Cargando las facturas';

  @override
  String get invoiceStatusUpcoming => 'Próxima';

  @override
  String get invoiceStatusOpen => 'Abierta';

  @override
  String get invoiceStatusClosed => 'Cerrada';

  @override
  String get invoiceStatusPaid => 'Pagada';

  @override
  String get invoiceStatusOverdue => 'Vencida';

  @override
  String get invoiceStatusCarriedOver => 'Pasada a la siguiente';

  @override
  String get invoiceStatusUnknown => 'Otro';

  @override
  String invoiceDates(String closing, String due) {
    return 'Cierra el $closing · vence el $due';
  }

  @override
  String get invoicePreviousBalance => 'Saldo anterior';

  @override
  String get invoiceCharges => 'Compras y cargos';

  @override
  String get invoiceCredits => 'Reembolsos y créditos';

  @override
  String get invoiceTotal => 'Total de la factura';

  @override
  String get invoicePaid => 'Pagado';

  @override
  String get invoiceRemaining => 'Por pagar';

  @override
  String get invoiceCredit => 'Crédito para la siguiente factura';
}
