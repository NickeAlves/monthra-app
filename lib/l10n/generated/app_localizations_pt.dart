// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get preferencesLanguage => 'Idioma';

  @override
  String get preferencesTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get authTagline => 'Suas finanças, mês a mês.';

  @override
  String get authSignInTitle => 'Entrar';

  @override
  String get authSignInSubtitle => 'Que bom ver você de novo.';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authNewPasswordHint => 'Pelo menos 10 caracteres.';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authForgotPasswordLink => 'Esqueceu a senha?';

  @override
  String get authSignInButton => 'Entrar';

  @override
  String get authNoAccount => 'Ainda não tem conta?';

  @override
  String get authCreateAccountLink => 'Criar conta';

  @override
  String get authHaveAccount => 'Já tem conta?';

  @override
  String get authNoticeSessionExpired => 'Sua sessão terminou. Entre de novo.';

  @override
  String get authNoticePasswordReset =>
      'Senha alterada. Entre com a nova senha.';

  @override
  String get authNoticeMfaExpired => 'A verificação expirou. Entre de novo.';

  @override
  String get authEmailNotVerified =>
      'Confirme seu e-mail antes de entrar. O link está na sua caixa de entrada.';

  @override
  String get authResendVerification => 'Reenviar e-mail';

  @override
  String authResendIn(int seconds) {
    return 'Reenviar em $seconds s';
  }

  @override
  String authVerificationSent(String email) {
    return 'Enviamos um novo link para $email.';
  }

  @override
  String get authMfaTitle => 'Verificação em duas etapas';

  @override
  String get authMfaSubtitle =>
      'Digite o código de 6 dígitos do seu app autenticador.';

  @override
  String get authMfaCodeLabel => 'Código';

  @override
  String get authMfaRecoverySubtitle =>
      'Digite um dos seus códigos de recuperação. Cada um funciona uma vez.';

  @override
  String get authMfaRecoveryLabel => 'Código de recuperação';

  @override
  String get authMfaUseRecovery => 'Usar um código de recuperação';

  @override
  String get authMfaUseApp => 'Usar o app autenticador';

  @override
  String get authMfaVerifyButton => 'Verificar';

  @override
  String get authBackToSignIn => 'Voltar para entrar';

  @override
  String get authRegisterTitle => 'Crie sua conta';

  @override
  String get authRegisterSubtitle =>
      'Gastos, entradas e investimentos num só lugar.';

  @override
  String get authNameLabel => 'Nome';

  @override
  String get authRegisterButton => 'Criar conta';

  @override
  String get authCheckInboxTitle => 'Confira sua caixa de entrada';

  @override
  String authCheckInboxMessage(String email) {
    return 'Enviamos um link de confirmação para $email. Ele vale por 30 minutos. Se não chegar, confira o spam.';
  }

  @override
  String get authForgotTitle => 'Redefinir a senha';

  @override
  String get authForgotSubtitle =>
      'Digite o e-mail da sua conta e enviaremos um link.';

  @override
  String get authForgotButton => 'Enviar link';

  @override
  String authForgotSentMessage(String email) {
    return 'Se houver uma conta para $email, o link de redefinição chega em instantes. Ele vale por 15 minutos.';
  }

  @override
  String get authResetTitle => 'Escolha uma nova senha';

  @override
  String get authResetSubtitle => 'Todos os aparelhos serão desconectados.';

  @override
  String get authResetButton => 'Alterar senha';

  @override
  String get authLinkInvalidTitle => 'Este link não funciona mais';

  @override
  String get authResetLinkInvalidMessage =>
      'Ele expirou ou já foi usado. Peça um novo.';

  @override
  String get authRequestNewLink => 'Pedir um novo link';

  @override
  String get authVerifyingTitle => 'Confirmando seu e-mail…';

  @override
  String get authVerifiedTitle => 'E-mail confirmado';

  @override
  String get authVerifiedMessage =>
      'Sua conta está pronta. Entre para começar.';

  @override
  String get authVerifyLinkInvalidMessage =>
      'Ele expirou ou já foi usado. Digite seu e-mail para receber um novo.';

  @override
  String get authContinue => 'Continuar';

  @override
  String get appUnavailableTitle => 'Não conseguimos falar com o Monthra';

  @override
  String get appRetry => 'Tentar de novo';

  @override
  String get notFoundTitle => 'Página não encontrada';

  @override
  String get notFoundMessage =>
      'O endereço pode estar errado, ou a página mudou de lugar.';

  @override
  String get notFoundHome => 'Ir para o início';

  @override
  String dashboardGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get dashboardPreviousMonth => 'Mês anterior';

  @override
  String get dashboardNextMonth => 'Próximo mês';

  @override
  String get dashboardThisMonth => 'Este mês';

  @override
  String get dashboardRefresh => 'Atualizar';

  @override
  String get dashboardLoading => 'Carregando o painel';

  @override
  String get dashboardLoadError => 'Não foi possível carregar o painel';

  @override
  String get dashboardEmptyTitle => 'Nenhuma conta ainda';

  @override
  String get dashboardEmptyMessage =>
      'Seu mês aparece aqui assim que você adicionar uma conta.';

  @override
  String get dashboardBalance => 'Saldo';

  @override
  String dashboardBalanceOn(String date) {
    return 'Em $date';
  }

  @override
  String get dashboardIncome => 'Entradas';

  @override
  String get dashboardExpenses => 'Saídas';

  @override
  String get dashboardNet => 'Resultado do mês';

  @override
  String get dashboardNetHint => 'Entradas menos saídas';

  @override
  String dashboardScheduled(String amount) {
    return '$amount ainda previsto';
  }

  @override
  String get dashboardNothingScheduled => 'Nada mais previsto';

  @override
  String get dashboardByCategory => 'Por categoria';

  @override
  String get dashboardCategoryKind => 'Mostrar';

  @override
  String get dashboardNoExpenses => 'Nenhuma saída neste mês';

  @override
  String get dashboardNoIncome => 'Nenhuma entrada neste mês';

  @override
  String get dashboardOtherCategories => 'Outras';

  @override
  String get dashboardUnknownCategory => 'Categoria';

  @override
  String dashboardEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lançamentos',
      one: '1 lançamento',
    );
    return '$_temp0';
  }

  @override
  String dashboardCategoryShare(String name, String amount, String percent) {
    return '$name: $amount, $percent';
  }

  @override
  String dashboardExpensesChart(String parts) {
    return 'Saídas por categoria: $parts';
  }

  @override
  String dashboardIncomeChart(String parts) {
    return 'Entradas por categoria: $parts';
  }

  @override
  String get dashboardCashFlow => 'Entradas e saídas';

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
    return 'Entradas e saídas de $first a $last. Em $month: entradas $income, saídas $expense.';
  }

  @override
  String get dashboardNetWorth => 'Patrimônio';

  @override
  String dashboardNetWorthChart(
    String first,
    String last,
    String start,
    String end,
  ) {
    return 'Patrimônio de $first a $last: de $start para $end.';
  }

  @override
  String get dashboardNoNetWorth =>
      'Meses que ainda não chegaram não têm patrimônio.';

  @override
  String get dashboardAccounts => 'Contas';

  @override
  String get dashboardArchived => 'Arquivada';

  @override
  String get dashboardUnknownAccount => 'Conta';

  @override
  String get accountTypeChecking => 'Conta corrente';

  @override
  String get accountTypeSavings => 'Poupança';

  @override
  String get accountTypeCreditCard => 'Cartão de crédito';

  @override
  String get accountTypeCash => 'Dinheiro';

  @override
  String get accountTypeBrokerage => 'Corretora';

  @override
  String get accountTypeOther => 'Conta';

  @override
  String get errorInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String errorRateLimited(int seconds) {
    return 'Muitas tentativas. Tente de novo em $seconds s.';
  }

  @override
  String get errorRateLimitedSoon =>
      'Muitas tentativas. Tente de novo daqui a pouco.';

  @override
  String get errorCaptcha =>
      'Muitas tentativas seguidas. Espere alguns minutos e tente de novo.';

  @override
  String get authCaptchaLabel => 'Verificação de segurança';

  @override
  String get authCaptchaPrompt =>
      'Muitas tentativas seguidas. Complete a verificação de segurança abaixo para continuar.';

  @override
  String get authCaptchaRejected =>
      'A verificação de segurança não foi aceita. Faça de novo abaixo.';

  @override
  String get authCaptchaFailed =>
      'Não foi possível carregar a verificação de segurança. Confira sua conexão e tente de novo.';

  @override
  String get authCaptchaUnsupported =>
      'Este navegador não consegue fazer a verificação de segurança. Atualize-o ou use outro.';

  @override
  String get authCaptchaHint => 'Aguardando a verificação de segurança…';

  @override
  String get errorMfaCodeInvalid =>
      'Código incorreto ou já usado. Espere o próximo.';

  @override
  String get errorOffline =>
      'Sem conexão com o servidor. Confira sua internet.';

  @override
  String get errorTimeout =>
      'O servidor demorou para responder. Tente de novo.';

  @override
  String get errorUnavailable =>
      'O serviço está indisponível agora. Tente de novo em instantes.';

  @override
  String get errorCheckFields => 'Confira os campos destacados.';

  @override
  String get errorGeneric => 'Algo deu errado. Tente de novo.';

  @override
  String errorReference(String id) {
    return 'Referência: $id';
  }

  @override
  String get errorFieldRequired => 'Obrigatório.';

  @override
  String get errorEmailInvalid => 'Digite um e-mail válido.';

  @override
  String get errorFieldInvalid => 'Valor inválido.';

  @override
  String errorTooShort(int min) {
    return 'Use pelo menos $min caracteres.';
  }

  @override
  String errorTooLong(int max) {
    return 'Use no máximo $max caracteres.';
  }

  @override
  String get errorPasswordBreached =>
      'Essa senha apareceu em vazamentos de dados. Escolha outra.';

  @override
  String get errorMfaCodeFormat => 'Digite os 6 dígitos.';

  @override
  String get appClose => 'Fechar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsProfileTitle => 'Perfil';

  @override
  String get settingsProfileDescription => 'Como o Monthra chama você.';

  @override
  String get settingsNameLabel => 'Nome';

  @override
  String get settingsSaveName => 'Salvar nome';

  @override
  String get settingsNameSaved => 'Nome salvo.';

  @override
  String get settingsEmailLabel => 'E-mail';

  @override
  String get settingsEmailHint =>
      'O endereço com que você entra. Ainda não é possível alterá-lo.';

  @override
  String get settingsPreferencesTitle => 'Preferências';

  @override
  String get settingsPreferencesDescription =>
      'Salvas na sua conta, em todos os dispositivos.';

  @override
  String get settingsLanguageDescription =>
      'O app e os e-mails que você recebe.';

  @override
  String get settingsThemeDescription => 'Sistema segue o seu dispositivo.';

  @override
  String get settingsCurrencyLabel => 'Moeda padrão';

  @override
  String get settingsCurrencyDescription =>
      'Sugerida quando você cria uma conta.';

  @override
  String get settingsBudgetAlertsLabel => 'Alertas de orçamento por e-mail';

  @override
  String get settingsBudgetAlertsDescription =>
      'Um e-mail quando um orçamento chega ao nível de aviso ou ao limite.';

  @override
  String get settingsSaveFailed => 'Sua alteração não foi salva';

  @override
  String get currencyBrl => 'Real brasileiro (BRL)';

  @override
  String get currencyUsd => 'Dólar americano (USD)';

  @override
  String get currencyEur => 'Euro (EUR)';

  @override
  String get navDashboard => 'Painel';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navMore => 'Mais';

  @override
  String get shellNavigationLabel => 'Navegação principal';

  @override
  String get shellSignOut => 'Sair';

  @override
  String get shellSignOutFailed => 'Você continua conectado';

  @override
  String get shellDesignSystem => 'Design system';

  @override
  String shellSignedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String get settingsSecurityTitle => 'Segurança';

  @override
  String get settingsSecurityDescription =>
      'Sua senha e a verificação em duas etapas.';

  @override
  String get settingsPasswordLabel => 'Senha';

  @override
  String get settingsPasswordDescription =>
      'Ao trocar, suas outras sessões são encerradas.';

  @override
  String get settingsPasswordChange => 'Alterar senha';

  @override
  String get passwordPageDescription => 'Digite a senha atual e depois a nova.';

  @override
  String get passwordCurrentLabel => 'Senha atual';

  @override
  String get passwordNewLabel => 'Nova senha';

  @override
  String get passwordSubmit => 'Salvar nova senha';

  @override
  String get passwordChanged => 'Senha alterada';

  @override
  String get passwordChangedDescription =>
      'Suas outras sessões foram encerradas.';

  @override
  String get errorPasswordIncorrect => 'Essa não é a sua senha atual.';

  @override
  String get settingsMfaLabel => 'Verificação em duas etapas';

  @override
  String get settingsMfaOn => 'Ativada';

  @override
  String get settingsMfaOff => 'Desativada';

  @override
  String get settingsMfaOnDescription =>
      'O login também pede um código do seu app autenticador.';

  @override
  String get settingsMfaOffDescription =>
      'Peça um código de um app autenticador no login, além da senha.';

  @override
  String get settingsMfaTurnOn => 'Ativar';

  @override
  String get settingsMfaTurnOff => 'Desativar';

  @override
  String get settingsRecoveryCodesLabel => 'Códigos de recuperação';

  @override
  String settingsRecoveryCodesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos restantes.',
      one: '1 código restante.',
      zero: 'Nenhum código restante.',
    );
    return '$_temp0 Cada um faz login uma vez sem o app.';
  }

  @override
  String get settingsRecoveryCodesLow => 'Gere novos antes que acabem.';

  @override
  String get settingsRecoveryCodesNew => 'Gerar novos códigos';

  @override
  String get mfaEnableTitle => 'Ativar a verificação em duas etapas';

  @override
  String get mfaEnablePasswordDescription => 'Confirme sua senha para começar.';

  @override
  String get mfaContinue => 'Continuar';

  @override
  String get mfaScanDescription =>
      'Adicione o Monthra ao seu app autenticador e digite o código que ele mostrar.';

  @override
  String get mfaScanStep => 'Escaneie este código QR com o app.';

  @override
  String get mfaQrLabel =>
      'Código QR para adicionar o Monthra ao app autenticador';

  @override
  String get mfaOpenAuthenticator => 'Abrir no app autenticador';

  @override
  String get mfaNoAuthenticator =>
      'Nenhum app autenticador abriu. Digite a chave.';

  @override
  String get mfaSecretLabel => 'Ou digite esta chave no app';

  @override
  String get mfaCopySecret => 'Copiar chave';

  @override
  String get mfaSecretCopied => 'Chave copiada.';

  @override
  String get mfaConfirmStep =>
      'Depois digite o código de 6 dígitos que o app mostrar.';

  @override
  String get mfaEnableSubmit => 'Ativar';

  @override
  String get mfaSetupExpired => 'A configuração expirou. Comece de novo.';

  @override
  String get mfaAlreadyOn => 'A verificação em duas etapas já está ativada.';

  @override
  String get mfaAlreadyOff => 'A verificação em duas etapas está desativada.';

  @override
  String get mfaEnabledToast => 'Verificação em duas etapas ativada';

  @override
  String get mfaDisableTitle => 'Desativar a verificação em duas etapas';

  @override
  String get mfaDisableDescription =>
      'O login vai pedir só o e-mail e a senha. Confirme com a sua senha e um código.';

  @override
  String get mfaDisableSubmit => 'Desativar';

  @override
  String get mfaDisabledToast => 'Verificação em duas etapas desativada';

  @override
  String get recoveryRegenerateDescription =>
      'Os códigos que você tem agora deixam de valer. Confirme com a sua senha e um código.';

  @override
  String get recoveryRegenerateSubmit => 'Gerar novos códigos';

  @override
  String get recoveryCodesTitle => 'Guarde seus códigos de recuperação';

  @override
  String get recoveryCodesDescription =>
      'Cada código faz login uma vez se você perder o app autenticador. Eles só aparecem agora: guarde-os num lugar seguro, como um gerenciador de senhas.';

  @override
  String get recoveryCodesListLabel => 'Códigos de recuperação';

  @override
  String get recoveryCodesCopy => 'Copiar todos';

  @override
  String get recoveryCodesCopied => 'Códigos copiados.';

  @override
  String get recoveryCodesSaved => 'Guardei estes códigos num lugar seguro';

  @override
  String get recoveryCodesDone => 'Concluir';

  @override
  String get recoveryCodesLeaveTitle => 'Sair sem guardar os códigos?';

  @override
  String get recoveryCodesLeaveDescription =>
      'Eles não vão aparecer de novo. Você pode gerar novos em Configurações.';

  @override
  String get recoveryCodesLeave => 'Sair mesmo assim';

  @override
  String get recoveryCodesStay => 'Ficar';

  @override
  String get recoveryCodesNewToast => 'Novos códigos de recuperação gerados';

  @override
  String get appCancel => 'Cancelar';

  @override
  String get sessionsTitle => 'Sessões';

  @override
  String get sessionsDescription =>
      'Dispositivos conectados à sua conta. Encerre os que você não reconhecer.';

  @override
  String get sessionsThisDevice => 'Este dispositivo';

  @override
  String get sessionsActiveNow => 'Em uso agora';

  @override
  String sessionsLastActive(String date) {
    return 'Ativa por último em $date';
  }

  @override
  String sessionsIp(String ip) {
    return 'IP $ip';
  }

  @override
  String sessionsDevice(String browser, String os) {
    return '$browser no $os';
  }

  @override
  String sessionsApp(String os) {
    return 'App Monthra no $os';
  }

  @override
  String get sessionsUnknownDevice => 'Dispositivo desconhecido';

  @override
  String get sessionsRevoke => 'Encerrar';

  @override
  String sessionsRevokeLabel(String device) {
    return 'Encerrar $device';
  }

  @override
  String get sessionsRevoked => 'Sessão encerrada.';

  @override
  String get sessionsRevokeOthers => 'Encerrar todas as outras sessões';

  @override
  String get sessionsRevokeOthersTitle => 'Encerrar todas as outras sessões?';

  @override
  String get sessionsRevokeOthersDescription =>
      'Os outros dispositivos vão precisar entrar de novo. Este continua conectado.';

  @override
  String get sessionsRevokeOthersConfirm => 'Encerrar as outras';

  @override
  String get sessionsOthersRevoked => 'Outras sessões encerradas.';

  @override
  String get sessionsNoOthers => 'Nenhum outro dispositivo está conectado.';

  @override
  String get sessionsLoadFailed => 'Não foi possível carregar as sessões';

  @override
  String get sessionsRevokeFailed => 'A sessão não foi encerrada';

  @override
  String get settingsDataTitle => 'Seus dados';

  @override
  String get settingsDataDescription =>
      'Baixe uma cópia de tudo o que está na sua conta ou exclua a conta.';

  @override
  String get settingsExportLabel => 'Exportar meus dados';

  @override
  String get settingsExportDescription =>
      'Um arquivo ZIP com seus registros em JSON. Avisamos por e-mail a cada exportação.';

  @override
  String get settingsExportOpen => 'Exportar';

  @override
  String get settingsDeleteLabel => 'Excluir conta';

  @override
  String get settingsDeleteDescription =>
      'Apaga a conta e todos os dados dela. Não dá para desfazer.';

  @override
  String get settingsDeleteOpen => 'Excluir minha conta';

  @override
  String get exportDataTitle => 'Exportar meus dados';

  @override
  String get exportDataDescription =>
      'Baixe uma cópia de tudo o que a sua conta guarda, para guardar ou levar para outro serviço.';

  @override
  String get exportDataContentsTitle => 'O que vai no arquivo';

  @override
  String get exportDataIncludes =>
      'Seu perfil, contas, categorias, transações, recorrências, orçamentos, investimentos e seus movimentos, sessões e eventos de segurança, em arquivos JSON.';

  @override
  String get exportDataExcludes =>
      'Nunca a sua senha, a chave da verificação em duas etapas nem os códigos de recuperação.';

  @override
  String exportDataEmail(String email) {
    return 'Cada exportação envia um e-mail para $email. Dá para exportar algumas vezes por hora.';
  }

  @override
  String get exportDataConfirmTitle => 'Confirme que é você';

  @override
  String get exportDataSubmit => 'Exportar';

  @override
  String get exportDataBusy => 'Preparando o arquivo…';

  @override
  String get exportDataReadyTitle => 'Seu arquivo está pronto';

  @override
  String exportDataReadyDescription(String name) {
    return '$name. Salve num lugar que só você acessa: ele tem seus registros financeiros.';
  }

  @override
  String get exportDataSave => 'Salvar arquivo';

  @override
  String get fileSaved => 'Arquivo salvo';

  @override
  String get fileNotSaved =>
      'O arquivo não foi salvo. Dá para salvar de novo sem exportar outra vez.';

  @override
  String get fileSaveFailed =>
      'Não foi possível salvar o arquivo. Tente de novo.';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountDescription =>
      'Isso apaga a sua conta e tudo o que há nela, em todos os aparelhos.';

  @override
  String get deleteAccountWhatTitle => 'O que acontece';

  @override
  String get deleteAccountErased =>
      'Suas contas, transações, categorias, recorrências, orçamentos e investimentos são apagados.';

  @override
  String get deleteAccountSignedOut =>
      'Todas as sessões terminam, neste aparelho e nos outros.';

  @override
  String get deleteAccountKept =>
      'Só o registro de segurança, sem endereços, fica guardado pelo prazo de retenção.';

  @override
  String deleteAccountEmail(String email) {
    return 'Enviamos uma confirmação para $email.';
  }

  @override
  String get deleteAccountFinal => 'Não dá para desfazer.';

  @override
  String get deleteAccountExportFirst => 'Exportar meus dados antes';

  @override
  String get deleteAccountConfirmTitle => 'Confirme que é você';

  @override
  String get deleteAccountSubmit => 'Excluir conta';

  @override
  String get deleteAccountDialogTitle => 'Excluir a sua conta para sempre?';

  @override
  String get deleteAccountDialogDescription =>
      'Seus dados são apagados agora e não podem ser recuperados.';

  @override
  String get deleteAccountDialogConfirm => 'Excluir para sempre';

  @override
  String get authNoticeAccountDeleted =>
      'Sua conta e os dados dela foram excluídos. Enviamos uma confirmação por e-mail.';

  @override
  String get recoveryCodesDownload => 'Baixar .txt';

  @override
  String get recoveryCodesFileTitle => 'Códigos de recuperação do Monthra';

  @override
  String recoveryCodesFileAccount(String email) {
    return 'Conta: $email';
  }

  @override
  String recoveryCodesFileCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Gerados em: $dateString';
  }

  @override
  String get recoveryCodesFileNote =>
      'Cada código faz login uma vez, no lugar de um código do app autenticador.';
}
