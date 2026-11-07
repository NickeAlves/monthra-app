# monthra-app - instructions for Claude Code

> Built from the Monthra master guide (`MONTHRA_CLAUDE.md`) following its §10.6: sections 1-3, this repo's section, all of §6 and §9-10. When the guide changes, update this file too.

## Project decisions

- **Branches:** `main` (production), `staging` (homologation), `develop` (development), all protected (PR only). Work happens on `feature/<name>` or `fix/<name>` branched from `develop`, with a PR back to `develop`. Promotion: PR `develop` -> `staging` -> `main`.
- **Language:** code, comments, README and commits in English (Conventional Commits). UI text only through i18n (pt-BR default, es-ES, en-US). The guide sections below stay in Portuguese, as in the master guide.
- **Shared Docker network:** `monthra-net` (external), created once with `docker network create monthra-net`.
- **Pending decisions (ask before implementing):** cloud provider (Terraform), Open Finance aggregator, transactional email service for staging/production, alert channel, Flutter bundle ID.
- **Brand pack** (`~/Downloads/monthra`): accent `#1E6B52`, ink `#161616`, dark background `#141414`, off-white `#F5F5F3`, white `#FFFFFF`. No brand guide or font in the pack; the logo text is outlined, so the UI font (Inter or Geist) is still to be chosen.
- **Not scaffolded yet:** `flutter create`, Dockerfile, `nginx.conf` and compose arrive in step 4 of §10.1, after the bundle ID is chosen.

---

## 1. Visão geral do produto

**Monthra** é uma plataforma de finanças pessoais para gerenciar:

- **Gastos** (despesas): categorizadas, recorrentes ou avulsas, com método de pagamento.
- **Entradas** (receitas): salário, freelas, reembolsos, recorrentes ou avulsas.
- **Investimentos**: aportes, resgates, tipo de ativo (renda fixa, ações, FIIs, cripto, fundos, previdência), rentabilidade e evolução patrimonial.

Funcionalidades centrais:

1. Autenticação segura (cadastro, login, verificação de e-mail, recuperação de senha, MFA/TOTP opcional).
2. Dashboard mensal: saldo do mês, entradas x saídas, gastos por categoria, evolução do patrimônio.
3. CRUD de transações (gasto/entrada) com filtros por período, categoria, conta, tags.
4. Contas/carteiras (conta corrente, cartão de crédito, dinheiro, corretora).
5. Categorias personalizáveis (com ícone e cor).
6. Orçamentos mensais por categoria com alertas de limite.
7. Carteira de investimentos com histórico de aportes e posição consolidada.
8. Relatórios e exportação (CSV/PDF).
9. Preferências do perfil: moeda (padrão BRL), **idioma (Português pt-BR, Español es-ES, English en-US)** e **tema (Sistema, Claro ou Escuro)**. Detalhes em §7.6.
10. **Open Finance**: o usuário conecta suas contas de bancos, cartões e corretoras (Open Finance Brasil, via agregador regulado) e o Monthra importa automaticamente contas, saldos, transações, faturas e investimentos. Detalhes em §5.6, §6.9 e §7.7.

Plataformas: **Web (desktop/laptop), Android e iOS** — um único código Flutter.

---

## 2. Repositórios e responsabilidades

| Repositório | Responsabilidade |
|---|---|
| [`monthra-server`](https://github.com/NickeAlves/monthra-server) | API em **Go**, banco **MongoDB**, cache (**Redis**), autenticação, rate limit, regras de negócio, migrations/índices, métricas e traces da API. |
| [`monthra-app`](https://github.com/NickeAlves/monthra-app) | App **Flutter** (Web + Android + iOS), design system, integração com a API. |
| [`monthra-infra`](https://github.com/NickeAlves/monthra-infra) | **Terraform** (deploy/IaC), observabilidade (**Prometheus, Grafana, Loki, Tempo, Alertmanager, OpenTelemetry Collector**), compose de orquestração de todo o ambiente, versionamento/release, CI/CD compartilhado. |

Regras gerais:

- Nunca misture responsabilidades entre repos. Ex.: dashboards do Grafana ficam no `monthra-infra`, mas o endpoint `/metrics` é implementado no `monthra-server`.
- Todos os repos usam **Conventional Commits** (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:`) e **SemVer** com tags `vX.Y.Z`.
- Branches fixas: `main` (produção), `staging` (homologação) e `develop` (desenvolvimento) — as três protegidas, só recebem código por PR (sem push direto, sem force-push).
- Branches de trabalho saem **sempre da `develop`** e voltam para ela por PR: `feature/<nome>` (ex.: `feature/new-service`) e `fix/<nome>`.
- Promoção entre ambientes por PR: `develop` → `staging` → `main`. Hotfix urgente: `fix/<nome>` a partir da `main`, PR para `main` e depois back-merge para `staging` e `develop`.
- Idioma: código, comentários, README e commits em **inglês**; textos da interface via i18n (§7.6).
- Cada repo deve ter: `README.md`, `CLAUDE.md`, `.editorconfig`, `.gitignore`, `.env.example` (nunca `.env` commitado), `Dockerfile`, `docker-compose.yml`, `Makefile` e workflow de CI em `.github/workflows/`.

---

## 3. Ambientes

| Ambiente | Nome | Como sobe | Observações |
|---|---|---|---|
| Local | `local` | `docker compose up` em cada repo, ou tudo junto via `monthra-infra` | Hot reload, dados fake (seed), Mailpit para e-mails. |
| Homologação | `staging` | `docker compose -f docker-compose.yml -f docker-compose.staging.yml` localmente **ou** deploy via Terraform | Espelho de produção, dados anonimizados, TLS. |
| Produção | `production` | Terraform + CI/CD a partir de tags | Somente via pipeline, nunca deploy manual. |

Variável `APP_ENV` (`local` | `staging` | `production`) controla comportamentos em todos os serviços.

Mapeamento branch → ambiente: `develop` (e PRs) ⇒ só CI; `staging` ⇒ deploy em **staging**; tag `vX.Y.Z` na `main` ⇒ deploy em **produção** (com aprovação).

**Rede Docker compartilhada:** todos os composes usam a rede externa `monthra-net` para que os repos se comuniquem quando executados separadamente:

```bash
docker network create monthra-net
```

---

## 4. Identidade visual e design (monthra-app)

### 4.1 Assets
O pack de logos está em **`~/Downloads/monthra`**. Antes de começar o app:

1. Liste o conteúdo de `~/Downloads/monthra` e me mostre o que encontrou.
2. Copie os arquivos para `monthra-app/assets/brand/` (logos SVG/PNG, ícone do app, favicon, splash).
3. Gere ícones de app com `flutter_launcher_icons` e splash com `flutter_native_splash` a partir desses arquivos.
4. Use o favicon e os ícones PWA em `web/` (`favicon.png`, `icons/Icon-192.png`, `Icon-512.png`, maskable).
5. Extraia a paleta de cores principal do logo e use como cor primária/accent do tema. Se houver um guia de marca no pack (PDF, cores, fontes), siga-o como fonte da verdade.

### 4.2 Direção de arte — inspirada no Lightfield
Referência: visual do **Lightfield** (lightfield.app) — moderno, leve e minimalista. Não copie o site; capture a estética:

- **Muito espaço em branco**, layout arejado, grid com respiro generoso (múltiplos de 4/8px).
- **Fundo claro e neutro** (off-white / cinza muito claro) no tema claro; tema escuro com cinza-grafite profundo (não preto puro).
- **Tipografia como protagonista**: sans-serif limpa e geométrica (ex.: *Inter* ou *Geist*), títulos grandes com tracking levemente negativo, hierarquia clara, pesos 400/500/600.
- **Cores contidas**: paleta neutra + **uma** cor de destaque da marca Monthra. Verde/vermelho suaves apenas para semântica de entrada/saída.
- **Bordas finas** (1px, baixa opacidade), **raios suaves** (8–12px), **sombras quase imperceptíveis**.
- **Microinterações fluidas**: transições de 150–250ms, curvas `easeOutCubic`, hover states sutis, skeleton loaders em vez de spinners, animações de números nos totais.
- Gráficos limpos, sem grid pesado, linhas finas, tooltips discretos.
- Landing page pública (web) com hero, seções de features, prints do app e CTA — no mesmo estilo.

### 4.3 Componentes e ícones — shadcn
- Use **[`shadcn_ui`](https://pub.dev/packages/shadcn_ui)** (port do shadcn/ui para Flutter) como base do design system: `ShadButton`, `ShadInput`, `ShadCard`, `ShadDialog`, `ShadSheet`, `ShadSelect`, `ShadTable`, `ShadToast`, `ShadTabs`, `ShadCalendar`, `ShadPopover`, etc.
- **Ícones: Lucide** (os mesmos do shadcn), via `LucideIcons` incluído no `shadcn_ui`. Não misturar com Material Icons.
- Crie um wrapper `lib/core/design_system/` com tokens (cores, espaçamentos, raios, tipografia, durações de animação) e componentes próprios (`MonthraCard`, `AmountText`, `CategoryBadge`, `TransactionTile`, `EmptyState`...) sobre o shadcn — telas nunca usam valores mágicos.
- Gráficos: `fl_chart` estilizado com os tokens.

### 4.4 Responsividade
- Breakpoints: `mobile < 640`, `tablet 640–1024`, `desktop > 1024`.
- Desktop/web: sidebar fixa à esquerda + conteúdo central com largura máxima (~1200px).
- Mobile: bottom navigation + FAB para "nova transação".
- Acessibilidade: contraste AA, tamanhos de toque ≥ 44px, `Semantics`, suporte a fonte do sistema maior, navegação por teclado na web.

---

## 6. Segurança (obrigatório — aplicar em todos os repos)

> Segurança não é opcional. Ao implementar qualquer feature, verifique esta lista. Siga **OWASP ASVS nível 2** e **OWASP API Security Top 10**.

### 6.1 Senhas e identidade
- Hash com **Argon2id** (`golang.org/x/crypto/argon2`) com parâmetros robustos (ex.: m=64MB, t=3, p=2) e salt aleatório.
- Política: mínimo 10 caracteres, checagem contra senhas vazadas (k-anonymity HIBP opcional), sem regras de composição absurdas.
- Verificação de e-mail obrigatória antes de usar a conta.
- Mensagens genéricas em login/recuperação ("credenciais inválidas") — **sem enumeração de usuários**.
- **MFA TOTP** opcional (RFC 6238) com códigos de recuperação (armazenados com hash).
- Bloqueio progressivo após tentativas falhas (por conta e por IP) + backoff.
- Tokens de reset/verificação: aleatórios (32 bytes, `crypto/rand`), armazenados **com hash**, uso único, expiração curta (15–30 min).

### 6.2 Tokens (JWT + refresh)
- **Access token JWT** curto (**10–15 min**), assinado com **EdDSA (Ed25519)** ou RS256, com `kid` para rotação de chaves. Claims: `sub`, `iat`, `exp`, `nbf`, `iss`, `aud`, `jti`. Validar **todas** as claims e fixar o algoritmo (rejeitar `none`/troca de alg).
- **Refresh token opaco** (não JWT), longo (ex.: 30 dias), armazenado com hash no Redis/Mongo, com **rotação a cada uso** e **detecção de reuso** (reuso ⇒ revoga toda a família e força novo login).
- Logout revoga refresh token e adiciona `jti` do access à denylist até expirar.
- Lista de sessões/dispositivos ativos com opção de revogar.
- **Armazenamento no cliente:**
  - **Web:** access e refresh em **cookies `HttpOnly`, `Secure`, `SameSite=Strict`** (refresh com `Path=/api/v1/auth/refresh`), prefixo `__Host-`. Nunca em `localStorage`.
  - **Mobile:** tokens no **`flutter_secure_storage`** (Keychain no iOS / Keystore no Android), enviados via header `Authorization: Bearer`.

### 6.3 CSRF
- Como a web usa cookies, aplicar **double-submit token assinado** (HMAC) ou synchronizer token: `GET /auth/csrf` devolve token em cookie não-HttpOnly + o cliente envia em `X-CSRF-Token` em todo método mutável (POST/PUT/PATCH/DELETE).
- Somado a `SameSite=Strict` e validação de **`Origin`/`Referer`** contra allowlist.
- Requisições com `Authorization: Bearer` (mobile) não dependem de cookie e ficam isentas do CSRF, mas o middleware deve garantir que cookie **e** header nunca sejam aceitos misturados de forma insegura.

### 6.4 Rate limiting e abuso
- Rate limit distribuído no **Redis** (sliding window ou token bucket), por **IP** e por **usuário**:
  - Auth (login, register, forgot): ex.: 5 req/min por IP e por e-mail.
  - API autenticada: ex.: 100 req/min por usuário.
  - Export/relatórios: limites mais baixos.
- Respostas `429` com `Retry-After` e headers `RateLimit-*`.
- Atrás de proxy, confiar em `X-Forwarded-For` **apenas** de proxies conhecidos.
- CAPTCHA (ex.: Cloudflare Turnstile) após falhas repetidas no login/cadastro.

### 6.5 Headers e transporte
- **TLS 1.2+ obrigatório** em staging/produção (Traefik/Caddy com Let's Encrypt), **HSTS** (`max-age=63072000; includeSubDomains; preload`).
- Headers: `Content-Security-Policy` estrita (sem `unsafe-inline` onde possível; o build web do Flutter deve ser compatível), `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` / `frame-ancestors 'none'`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` restritiva, `Cross-Origin-Opener-Policy: same-origin`.
- **CORS** com allowlist explícita de origens por ambiente, `AllowCredentials: true` só para essas origens, nunca `*`.
- Remover header `Server`/versões.

### 6.6 Autorização e dados
- Autorização em toda rota: o recurso pertence ao `user_id` do token (prevenir **IDOR/BOLA**).
- Validação e sanitização de toda entrada; whitelist de campos (prevenir **mass assignment**); impedir **NoSQL injection** (nunca montar filtros a partir de JSON cru do cliente, rejeitar chaves começando com `$`).
- Dados sensíveis (segredo MFA, eventualmente descrições) criptografados em repouso com **AES-256-GCM** (chave via secret manager); MongoDB com autenticação, usuário de menor privilégio, sem exposição pública, TLS e backups criptografados.
- Respostas nunca expõem stack traces, hashes ou campos internos.
- **LGPD:** exportação e exclusão de dados do usuário, política de retenção, consentimento, logs sem PII.
- Audit log de eventos sensíveis.

### 6.7 Segredos e supply chain
- Nenhum segredo no código ou em imagens Docker. Local: `.env` (gitignored). Staging/prod: secret manager do provedor (ou Docker secrets/SOPS), injetado via Terraform.
- Rotação de chaves JWT suportada (JWKS interno com múltiplos `kid`).
- CI com: `govulncheck`, `gosec`, `golangci-lint`, `flutter analyze`, `dart pub outdated`, **Trivy** (imagens e IaC), **gitleaks** (segredos), **tfsec/checkov** (Terraform), Dependabot/Renovate.
- Imagens Docker: multi-stage, base **distroless** ou `alpine` mínima, **usuário não-root**, `read_only` filesystem, `no-new-privileges`, healthcheck, versões fixas (digest).

### 6.8 App Flutter
- Certificate pinning opcional no mobile (configurável), ofuscação no build release (`--obfuscate --split-debug-info`).
- Bloquear screenshots em telas sensíveis no Android (`FLAG_SECURE`) — opcional por preferência.
- Biometria (`local_auth`) para desbloquear o app no mobile.
- Auto-logout por inatividade configurável.
- Nunca logar tokens; desabilitar logs verbosos em release.

### 6.9 Open Finance
- Credenciais do agregador (client id/secret, segredo de webhook) **só no server**, via secret manager; nunca no app, em imagens ou em logs.
- Webhook: validar assinatura/segredo do provedor (e allowlist de IP, se o provedor publicar), limitar tamanho do body, responder 2xx rápido e processar assíncrono, idempotência por id de evento, e **nunca confiar no payload** — rebuscar os dados na API do provedor.
- Webhook isento de CSRF (não é chamado pelo navegador), mas com rate limit próprio.
- `provider_connection_id` tratado como segredo: criptografado em repouso e nunca exposto em respostas (a API usa o id interno).
- Toda operação sobre conexão checa o `user_id` do token (IDOR/BOLA).
- Sandbox do provedor em `local`/`staging`; chaves de produção só em `production`.
- Audit log de conectar, reconectar, sincronizar manualmente e desconectar.

---

## 7. monthra-app (Flutter)

### 7.1 Stack
- Flutter estável mais recente, Dart null-safe, alvos **web, android, ios**.
- Estado: **Riverpod** (`flutter_riverpod` + `riverpod_generator`).
- Rotas: **go_router** (com guards de autenticação e deep links; URLs limpas na web — `usePathUrlStrategy`).
- HTTP: **dio** com interceptors (auth, refresh automático com fila para requisições concorrentes, CSRF na web, retry com backoff, tratamento de problem+json).
- Modelos: `freezed` + `json_serializable`.
- UI: `shadcn_ui` + Lucide + `fl_chart` + `google_fonts` (ou fonte local da marca).
- Storage seguro: `flutter_secure_storage` (mobile). Web: cookies via `withCredentials` (`BrowserHttpClientAdapter`).
- i18n: `flutter_localizations` + `intl` com arquivos ARB para **pt-BR (padrão), es-ES e en-US** (ver §7.6).
- Formatação de moeda e datas com `intl` por locale.
- Testes: unit, widget e golden tests; `integration_test` para fluxos principais.

### 7.2 Estrutura (feature-first)
```
monthra-app/
├── assets/brand/
├── lib/
│   ├── main.dart
│   ├── app/                 # MonthraApp, router, theme
│   ├── core/
│   │   ├── design_system/   # tokens + componentes sobre shadcn
│   │   ├── network/         # dio, interceptors, api client
│   │   ├── security/        # storage seguro, biometria, csrf
│   │   ├── config/          # env por flavor (--dart-define)
│   │   └── utils/
│   ├── features/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── transactions/
│   │   ├── accounts/
│   │   ├── categories/
│   │   ├── budgets/
│   │   ├── investments/
│   │   ├── open_finance/    # conexões bancárias (§7.7)
│   │   ├── reports/
│   │   ├── settings/
│   │   └── landing/         # página pública (web)
│   │       └── (data/ domain/ presentation/)
│   └── l10n/
├── web/
├── android/ ios/
├── test/ integration_test/
├── Dockerfile               # build web + nginx
├── nginx.conf               # headers de segurança, SPA fallback, gzip/brotli, cache de assets
├── docker-compose.yml
└── Makefile
```

### 7.3 Configuração por ambiente
- `--dart-define-from-file=env/local.json|staging.json|production.json` com `API_BASE_URL`, `APP_ENV`, `SENTRY_DSN` (opcional).
- Flavors Android/iOS: `dev`, `staging`, `prod` (bundle IDs distintos).

### 7.4 Docker do app
- Dockerfile multi-stage: estágio `ghcr.io/cirruslabs/flutter` → `flutter build web --release` → `nginx:alpine` (não-root, porta 8080) com `nginx.conf` contendo CSP, HSTS e demais headers.
- No compose local, o nginx pode fazer proxy de `/api` para `monthra-server` (mesma origem ⇒ cookies `SameSite=Strict` funcionam sem dor de CORS).

### 7.5 Telas mínimas
Landing (web) · Login · Cadastro · Verificar e-mail · Esqueci/Redefinir senha · MFA · Dashboard · Transações (lista + filtros + formulário em sheet/dialog) · Contas · Conexões bancárias (Open Finance) · Categorias · Orçamentos · Investimentos (carteira + detalhe do ativo) · Relatórios · Configurações (perfil, **preferências: idioma e tema**, segurança, sessões, exportar/excluir conta).
Sempre com estados de **loading (skeleton)**, **vazio** e **erro**.

### 7.6 Idioma e tema (preferências do perfil)
Dentro do módulo de **Perfil → Preferências** (`features/settings/preferences/`), o usuário escolhe:

**Idioma**
- Opções: **Português (pt-BR)**, **Español (es-ES)**, **English (en-US)**.
- Todo texto da interface vem de `lib/l10n/app_pt.arb`, `app_es.arb` e `app_en.arb` (gerados com `flutter gen-l10n`). **Nenhuma string fixa nas telas.** O CI falha se faltar chave em algum dos três ARB.
- Formatação de moeda, números e datas segue o locale escolhido (`intl`: `NumberFormat.currency`, `DateFormat`), independente da moeda do usuário.
- Primeiro acesso / antes do login: usa o idioma do dispositivo/navegador se for um dos três suportados; senão, pt-BR.
- Na tela de login/landing também há um seletor de idioma.
- A troca é aplicada **na hora**, sem reiniciar o app, e o `Accept-Language` do dio é atualizado.
- Na web, atualizar o atributo `lang` do documento.

**Tema**
- Opções: **Sistema** (segue o modo claro/escuro do SO/navegador e reage a mudanças em tempo real), **Claro** e **Escuro**.
- Implementar com `ThemeMode.system | light | dark` no `ShadApp`, com `ShadThemeData` claro e escuro derivados dos mesmos tokens do design system (§4.3). Todo componente deve ser testado nos dois temas (golden tests).
- Transição suave entre temas (animação de cor ~200ms), sem flash branco ao abrir o app em modo escuro (inclusive na splash e no `index.html` da web, usando `prefers-color-scheme`).

**Persistência e sincronização**
- Preferências ficam salvas no perfil via `PATCH /me/preferences` (sincronizam entre web, Android e iOS).
- Também ficam em cache local (`shared_preferences`; não é dado sensível) para aplicar imediatamente na abertura do app, antes da resposta da API.
- Ao fazer login, o valor do servidor prevalece sobre o local.
- Estado gerenciado por um `preferencesProvider` (Riverpod) observado pelo widget raiz.

### 7.7 Open Finance (conexões bancárias)
- Em **Contas → Conexões bancárias** (`features/open_finance/`): lista de conexões com logo da instituição, status, última sincronização e ações **sincronizar**, **reconectar** e **desconectar** (perguntando se mantém ou apaga os dados importados).
- Banner quando o consentimento estiver perto de expirar ou a conexão precisar de reautenticação, com renovação em 1 clique.
- Widget do provedor: na **web** via script/iframe do provedor — a CSP do `nginx.conf` libera **somente** os domínios do provedor em `script-src`/`frame-src`/`connect-src`; no **mobile** via SDK oficial do provedor (se houver para Flutter) ou `webview_flutter` com allowlist de domínios.
- Contas e transações importadas mostram o badge da instituição; valor e data não são editáveis.
- Onboarding pós-cadastro: "Conectar meu banco" ou "Começar manualmente".
- Estados de loading/vazio/erro e todas as strings nos três ARB.

---

## 9. Docker e Docker Compose

### 9.1 Por repositório (rodar isolado)
- **monthra-server/docker-compose.yml:** `api` (com hot reload via `air` em local), `mongo` (com usuário/senha e volume), `redis` (com senha), `mongo-express` opcional (só local), `mailpit` (e-mails locais).
- **monthra-app/docker-compose.yml:** `web` (nginx servindo o build), apontando para a API via `monthra-net`.
- **monthra-infra/compose/docker-compose.yml:** sobe tudo, incluindo `prometheus`, `grafana`, `loki`, `tempo`, `alertmanager`, `otel-collector`/`alloy`, exporters e `traefik`/`caddy`.

### 9.2 Regras
- Healthchecks em todos os serviços e `depends_on: condition: service_healthy`.
- Volumes nomeados para dados; `restart: unless-stopped`.
- Limites de CPU/memória definidos.
- Portas de banco/cache **não** expostas no host em staging.
- `docker-compose.staging.yml` como override: TLS, sem hot reload, sem ferramentas de debug, `APP_ENV=staging`.

### 9.3 Comandos padrão (Makefile em cada repo)
```
make up          # sobe ambiente local
make down        # derruba
make logs        # logs agregados
make test        # testes
make lint        # lint + security scan
make build       # build da imagem
make seed        # dados fake (server)
make staging-up  # sobe homologação local
```

---

## 10. Como trabalhar (regras para o Claude Code)

1. **Ordem de implementação sugerida:**
   1. `monthra-server`: esqueleto, config, logger, health, Docker/compose, Mongo/Redis, índices.
   2. Autenticação completa + todos os middlewares de segurança (§6) + testes.
   3. Domínio: accounts → categories → transactions → dashboard → budgets → investments → **open finance** (§5.6, após eu escolher o agregador) → reports.
   4. `monthra-app`: design system e tema a partir do pack de marca → auth → dashboard → demais features → conexões bancárias (§7.7).
   5. `monthra-infra`: compose integrado + observabilidade → Terraform (após eu escolher o provedor) → CI/CD.
2. Trabalhe em **pequenos incrementos**, um PR por feature (`feature/<nome>` a partir da `develop`, PR para `develop`), com testes. Rode `make lint` e `make test` antes de commitar.
3. Cobertura mínima: **80%** em `domain`/`usecase`/`auth` do server; testes de widget para componentes do design system.
4. Mantenha o **OpenAPI** sincronizado com o código; o app consome os contratos dele.
5. Atualize o `README.md` de cada repo com como rodar localmente e em staging.
6. Ao criar o `CLAUDE.md` de cada repo, inclua: as §1–3, a seção específica do repo (§5, §7 ou §8), a §6 completa e a §9–10.
7. Se uma decisão não estiver coberta aqui (ex.: provedor de cloud, agregador de Open Finance, serviço de e-mail, canal de alertas, bundle ID do app), **pergunte antes** de implementar.
8. Nunca commite segredos, `.env`, chaves, `terraform.tfstate` ou `*.tfvars` reais.
9. Código, comentários, README e commits em **inglês** (commits em Conventional Commits); textos da interface via i18n (pt-BR padrão, es-ES, en-US).
10. Priorize: **segurança > corretude > clareza > performance > conveniência**.
