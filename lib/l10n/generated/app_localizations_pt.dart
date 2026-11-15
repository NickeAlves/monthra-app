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
  String homeGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get homeComingSoon => 'Seu painel chega nas próximas versões.';

  @override
  String get homeSignOut => 'Sair';

  @override
  String get homeDesignSystem => 'Design system';

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
}
