# monthra-app - instructions for Claude Code

> Built from the Monthra master guide (`MONTHRA_CLAUDE.md`) following its §10.6: sections 1-3, this repo's section, all of §6 and §9-10. When the guide changes, update this file too.

## Project decisions

- **Branches:** `main` (production), `staging` (homologation), `develop` (development), all protected (PR only). Work happens on `feature/<name>` or `fix/<name>` branched from `develop`, with a PR back to `develop`. Promotion: PR `develop` -> `staging` -> `main`.
- **Language:** code, comments, README and commits in English (Conventional Commits). UI text only through i18n (pt-BR default, es-ES, en-US). The guide sections below stay in Portuguese, as in the master guide.
- **Shared Docker network:** `monthra-net` (external), created once with `docker network create monthra-net`.
- **Pending decisions (ask before implementing):** cloud provider (Terraform), Open Finance aggregator, transactional email service for staging/production, alert channel. Ask about the 3D icons (art direction, source, format, scope) before their PR.
- **Brand pack** (`~/Downloads/monthra`, copied to `assets/brand/`): accent `#1E6B52`, ink `#161616`, dark background `#141414`, off-white `#F5F5F3`, white `#FFFFFF`. No brand guide or font in the pack.
- **UI font (user decision of 2026-11-15):** Inter, bundled in the assets (400/500/600, tabular figures for amounts); never Google Fonts at runtime (CSP `font-src 'self'`, works offline). Inter 4.1 static cuts subset to Latin by `scripts/subset-inter.sh` (`make fonts`: release hash checked, fonttools pinned, every OpenType feature kept; ~135 KB per weight); the OFL goes to the `LicenseRegistry` at boot. shadcn_ui still bundles Geist (unused).
- **Design system (`lib/core/design_system/`, import `design_system.dart`):** screens never hard-code colors, sizes, radii or durations. Color roles live in `MonthraColorSchemes` (shadcn roles plus `income`, `expense`, `warning`, `accentText`, `skeleton` in `ShadColorScheme.custom`, read through the `MonthraColors` extension, so they animate with the theme); every text role reads at 4.5:1+ on background, card and muted in both themes (`contrast_test.dart`). **Dark primary (user decision of 2026-11-15):** the button stays `#1E6B52` with white text; links, focus ring and accent text use `#3FA37F`. Dark destructive is the soft red `#F28B82` with dark text (no red reads at 4.5:1 both under white text and on graphite). shadcn paints outline/ghost/link buttons in `primary`, so the theme overrides them (`foreground`, links `accentText`); shadcn card titles are h3, `MonthraCard` sets `large`. Type: Inter only at 400/500/600, Inter's dynamic tracking, styles without color (like shadcn's), amounts in tabular figures (`amountDisplay`/`amountTitle`/`amount`/`amountSmall`). Controls >= 44 px (buttons, icon buttons, inputs, select; switch and checkbox labels padded to 44); the `sm` button (36 px) is for pointer layouts only. Motion 150/200/250 ms `easeOutCubic`, totals count in 400 ms, `MonthraMotion.of` returns zero under reduced motion. Breakpoints via `context.monthraBreakpoint` (shadcn's `breakpoint` uses other widths). Button labels go through `ButtonLabel` (Flexible, one line); icon-only buttons label their `Icon` (`semanticLabel`). Category colors pass through `CategoryColors.of` (icon 3:1 and label 4.7:1 on the tint, lightness moved in HSL); `CategoryIcons` is a const map of Lucide names (the 22 defaults now, the picker set in the categories PR, the 3D icons later behind the same API).
- **Money formatting (`lib/core/money/`):** amounts stay in minor units (`int`) up to the widget; `MoneyFormat.format` follows the UI locale whatever the currency, with CLDR symbols (`US$` outside en-US, since intl writes a bare `$`), the typographic minus U+2212, sign modes `auto`/`always`/`never`, exact up to the API's 10^13. `AmountText` signs and colors by kind (income +green, expense −red, neutral minus only when negative), never cuts digits (scales down) and reads only the final value while counting.
- **Catalog:** `DesignSystemCatalog` is the route `/design-system` of local and staging builds (open signed in or out); in production the route does not exist (`productionBuild`, a `const String.fromEnvironment('APP_ENV')`, compiles it away, and `env.isProduction` drops it too). A development tool: fixed English labels, outside the i18n files; samples that name no locale follow the UI language. Its header shows the `actions` the app passes in (the real theme and language pickers), so `core/` never imports `features/`. Its tests run Flutter's tap target (44 px on a phone, scrolled screen by screen; 24 px on a desktop) and label guidelines in both themes, twice the text size, and `contrastIssues` (test/helpers/contrast.dart): every text 4.5:1 and icon 3:1 against the opaque color painted behind it, by color. Flutter's `textContrastGuideline` samples screenshot pixels and fails small text on Linux (FreeType's thin antialiasing), so it is not used. A Linux check locally: `docker build --target build -t monthra-app:linux-sdk .` and run `flutter test` in a copy of the repo inside it.
- **Languages (§7.6, PR i18n-preferences):** `lib/l10n/app_{pt,es,en}.arb`, one file per language; `app_en.arb` is the template (English `@key` descriptions, required for every key). The app declares the full locales (`AppLocale`: pt_BR, es_ES, en_US; the API tags `pt-BR`...) and the generated delegate matches them by language. Generated code is committed (`lib/l10n/generated/`, Riverpod `*.g.dart`; `make gen`) and CI fails when it is stale; `tool/check_l10n.dart` (`make l10n-check`, CI) fails on a missing or extra key, a missing description, a dropped placeholder, an empty message or metadata outside the template. Keys camelCase with an area prefix. Language names are endonyms in `AppLocale.nativeName`, the same in every language (the one accepted exception to "no hard-coded UI strings"). Without a choice the app takes the first device language that is pt, es or en whatever the region, else pt-BR: the same answers as the server's `i18n.FromAcceptLanguage`. Formatters take the locale from the context, never `Intl.defaultLocale`. Flutter writes `<html lang>` on the web itself (`Localizations` -> `setApplicationLocale`). shadcn_ui loads its strings for every language but English from deferred libraries: on the web a pt-BR or es-ES first frame waits for one small same-origin chunk (CSP `trusted-types dart.deferred-loading`), and a switch keeps the old language until the new one is loaded (no blank frame).
- **Preferences (`lib/features/settings/preferences/`):** Riverpod 3 with `riverpod_generator`; `preferencesProvider` (`AppPreferences {AppLocale? locale, ThemePreference theme}`, values in the API format; locale null = follow the device) and `appLocaleProvider` (choice or device match: the one source for the UI locale and, from the API client on, `Accept-Language`). `PreferencesStore` on `SharedPreferencesWithCache` (allowList `prefs.locale`/`prefs.theme`), opened in `main` before `runApp` and passed with `preferencesStoreProvider.overrideWithValue`, so the first frame has the saved theme and language; a store that fails to open falls back to memory, a failed save is reported, never thrown. `replaceAll` applies the profile's language and theme whenever `Me` loads (sign-in and start-up: the server wins, and nothing is sent back); a change made in the app goes to the profile through `ProfileController` (see Shell and settings). The default currency and `budgetAlerts` live only in the profile (`Me.preferences`). Web: the app saves `localStorage['monthra.boot']` (`{lang, theme}`, its own key, never the shared_preferences format) and `web/boot.js`, a synchronous head script with the page nonce, applies `data-theme`/`lang` before the first paint (`splash.css` honors `data-theme` over `prefers-color-scheme`, the symbol is a CSS background so only one is fetched); native splash screens follow the system.
- **API client (`lib/core/network/`, PR api-client):** features call `apiClientProvider` (`ApiClient.get/post/patch/delete`, paths as in the OpenAPI, under `Env.apiRoot` = origin + `/api/v1`) and only ever catch `ApiException` (sealed: `ApiProblemException` with the `ApiProblem` (`code` -> `ProblemCode`, `errors` -> `FieldCode`, both enums mirror the server's lists and keep unknown wire values), `NetworkException`, `ApiTimeoutException`, `CancelledException`, `UnexpectedApiException`), each with the `requestId`. `createApiDio` sets the interceptors in order: request id (`X-Request-ID`, 32 hex, kept across retries), debug log (`kDebugMode` only: method, path, status, ms, id; never headers, query or bodies), `Accept-Language` (read per call from `apiLanguageProvider`), CSRF (cookie mode only), auth, retry. A retried call goes through the whole chain again (`dio.fetch`), so its error is `reject`ed, never `next`ed (it already passed the later interceptors); `extra` flags stop loops (one CSRF retry, one auth retry, two transient retries). No `QueuedInterceptor` (it would serialize every error). **Session mode** (`sessionModeProvider`): the server treats any request with `Origin` (or an auth cookie) as a browser, so web = cookies (`NoTokenStore`; `BrowserHttpClientAdapter(withCredentials: true)`), devices = Bearer (`SecureTokenStore` on `flutter_secure_storage` 11: one JSON entry `auth.tokens`, iOS `first_unlock_this_device`, not synchronizable; in-memory cache; an unreadable entry is reported and dropped) and never an `Origin`. **CSRF:** `X-CSRF-Token` on every mutating browser call including login/register/refresh; fetched once (single flight), kept across sign-in (not session-bound), dropped and refetched after `403 csrf_invalid` with one resend. **Auth:** `ApiRoutes.public` (csrf, refresh, register, verify-email(+resend), login, forgot/reset-password, mfa/verify) get no Bearer and their 401 is the answer; any other 401 (logout and mfa setup/enable/disable included) runs `SessionRefresher.refresh` (one shared future; `generation` counts renewals so a 401 for a request sent before the latest renewal just goes again), then resends once. Native refresh sends `{refreshToken}` and saves the new pair before anything else; web sends no body. `409 refresh_conflict`: web = another tab renewed, resend; native = the rotated pair was lost, session over. A lost session clears the store and emits `SessionEvent.expired` on `sessionEventsProvider` (`SessionEvents.stream`); a refresh that failed for a transient reason keeps the tokens and the call fails with that reason. **Retry:** GET/HEAD only (the server has no `Idempotency-Key`): connection error/timeout, 502/503/504, 429/503 with `Retry-After` <= 10 s; 300 ms then 1.2 s (±20%), honours the `CancelToken`. Core never imports features: `appOverrides` (`lib/app/overrides.dart`, used by `main` and `pumpMonthraApp`) passes `envProvider`, `preferencesStoreProvider` and `apiLanguageProvider` (-> `appLocaleProvider.tag`). Models: `freezed` 4 + `json_serializable` (`build.yaml`: `checked`, `explicit_to_json`), Dart 3.13 syntax (`const factory({...}) = _X;`, `const new _();`, `factory fromJson(...)`); `Session`/`AuthTokens` override `toString` so tokens never print. Hand-written models for now; the OpenAPI (3.1, `oneOf`, nullable unions) is not generated. Tests: `test/helpers/fake_api.dart` (`FakeAdapter`, `Reply`, `fakeApi` with instant retry waits); `test/live/` (tag `live`, skipped by default; `make test-live` against the seeded local server, three sign-in calls of the 5/min budget, unknown emails for the failures so the demo account never locks). `flutter_test` stubs every HTTP call with a 400: a live test sets `HttpOverrides.global = null`.
- **Routes and sign-in (`lib/app/router.dart`, `lib/features/auth/`, PR auth):** go_router 18 through `routerProvider` (keepAlive; `SessionKind` mirrors `authControllerProvider` as `refreshListenable` and notifies only when the kind of session changes, so a newer profile, a rename say, re-runs no guard). `AppRoutes`, `productionBuild` and `catalogEnabled` live in `lib/app/routes.dart` (re-exported by `router.dart`). The signed-in pages are the branches of a `StatefulShellRoute.indexedStack` (see Shell and settings); the sign-in pages and the catalog sit outside it. `main` sets `PathUrlStrategy(BrowserPlatformLocation(), true)`: `usePathUrlStrategy()` drops the `#fragment` the email links carry their token in (and the web `PathUrlStrategy` has no const constructor, unlike the stub the analyzer reads). Guards in the pure `authRedirect(state, uri)`: nothing moves while booting/unavailable; signed out, a page that needs a session goes to `/login?from=<path+query>`; signed in, `AppRoutes.signedOutOnly` goes to `safeReturnPath(from)` (a path of the app only: no scheme, host, `//`, `\`, control characters, fragment or signed-out page) or `/`; `/login/mfa` without `AwaitingMfa` goes back to `/login`; `AppRoutes.open` (`/verify-email`, `/reset-password`, `/design-system`) in either state; anything else is `NotFoundPage` (go_router reports no address for an unmatched location, so a redirect to a 404 leaves the old URL). `MonthraApp` = `ShadApp.router` whose `builder` shows `BootScreen` (booting) or `BootUnavailable` (retry) instead of the router, so no page builds before its guard. `AuthController` (`AuthState`: `AuthBooting`, `AuthUnavailable(ApiException)`, `SignedIn(Me)`, `SignedOut({AuthNotice? notice})`, `AwaitingMfa(MfaChallenge)`): boots with `GET /me` only when a session may exist (device: `TokenStore` has tokens; web: the `SessionHint`, `localStorage['monthra.session']`, set at sign-in and cleared at sign-out/expiry, no secret), else signed out with no request; `SessionEvent.expired` -> `SignedOut(sessionExpired)`; the challenge stays in memory with a timer of `expiresIn` (-> `mfaExpired`); `mfa_challenge_invalid` -> `mfaExpired`; sign-out on a device clears the tokens even when the call fails, on the web it rethrows (cookies only leave through the server); `sessionEnded(passwordReset)` after a reset. `AuthApi` saves a native `Session` in the `TokenStore` before returning (as the refresh does) and reads unexpected bodies as `UnexpectedApiException`. Email-link pages read `linkToken(state.uri)` once, then `dropLinkFragment` (`Router.neglect` + `go`: the history entry is replaced); verify sends once on open. Screens: `AuthLayout` (desktop: `primary` brand panel with the white symbol and `authTagline`, form max 400 px; tablet/phone: one column, symbol on top; **no theme or language picker on the sign-in pages**, user decision of 2026-11-15 overriding §7.6's language picker on login: before signing in the app follows the device, after it the profile), `AuthHeading`, `AuthSwitchLink`, `EmailField`/`PasswordField` (show/hide 44 px button inside, so auth fields share `authFieldConstraints` = `MonthraLayout.fieldWithButtonHeight` 46), `FormAlert` (live region; `FormAlert.error(ApiErrorMessage)`), `Countdown` (429 lock, 60 s `resendCooldown`), `AuthValidators` (the server's bounds from `internal/domain/user.go`). MFA uses one `ShadInputFormField` (digits only, `oneTimeCode` autofill, sends at the 6th digit), not `ShadInputOTP` (no autofill, no semantics). `AutofillGroup(onDisposeAction: cancel)` + `TextInput.finishAutofillContext()` after a sign-in that worked; a failed sign-in puts the focus back in the password (Enter with `done` unfocuses). Errors through `ApiErrorText` (`lib/core/network/api_error_text.dart`): app sentences per code, request id only for unexpected failures, never the server's `detail`. `captcha_*` reads "try again later" only in a build without a captcha page (see Captcha). No terms checkbox yet (the privacy policy comes with the landing PR). Tests: `pumpMonthraApp` takes `api` (`FakeAdapter` through `httpAdapterProvider`), `mode`, `tokens`, `hint`, `location` (the platform's initial route); `appLocation`; dio runs on timers, so a test starts an API call, pumps, then awaits it.
- **Captcha (`lib/features/auth/captcha/`, PR captcha; user decisions of 2026-11-15: our own page in an iframe on the web and in the official `webview_flutter` on devices, which load the **hosted** page):** the server answers `captcha_required` after repeated failures and checks the token before anything else, keeping on asking while the failures last; tokens work once and expire in 300 s. `CaptchaGate` (one per form, a `ChangeNotifier`): `onError` turns a `captcha_required`/`captcha_invalid` into `needed` (the widget starts over; after `captcha_required` the form resends by itself once it passes, and that resend carries a token so it never meets `captcha_required` again; after `captcha_invalid` the person sends again, so a server refusing every token, a wrong `TURNSTILE_HOSTNAMES` say, never loops against a widget that passes by itself), `take()` hands the token to one request and starts a new widget (`attempt`, the view's key), the send button waits while `waitingForToken`; status loading (skeleton) / ready / solved / failed (retry) / unsupported. `CaptchaField` sits above the button of the sign-in and sign-up pages (`CaptchaAction.login`/`register`, the server's `captcha.ActionLogin`/`ActionRegister`), `captchaAlert` replaces the error alert. The page `web/turnstile.html` + `turnstile.js` + `turnstile.css` (no inline code) reads `?sitekey&action&theme&lang&size&bg` against closed patterns, renders Turnstile explicitly (`response-field: false`, `refresh-expired: auto`), paints `bg` itself (an iframe whose color scheme differs from the app's gets an opaque backdrop in Chrome) and only posts `{source: "monthra-turnstile", type: ready|token|expired|error|unsupported}`: through the `MonthraTurnstile` channel in a webview, `parent.postMessage(msg, location.origin)` in the iframe; it never listens, so a reset is a new load. `CaptchaMessage.parse` is strict (the iOS channel is reachable from every frame, Cloudflare's included; token 1-2048 chars). Web (`captcha_view_web.dart`): `HtmlElementView.fromTagName('iframe')`, messages only from this origin and this frame's window (`strictEquals`). Devices (`captcha_view_io.dart`): the page from `APP_PUBLIC_URL`, the main frame held to it and subframes to `https://challenges.cloudflare.com`, `about:blank`, `about:srcdoc` (`allowCaptchaNavigation`); a failed main-frame load is `CaptchaFailed('network')`. nginx: `/turnstile.html` has its own CSP (`script-src 'self' https://challenges.cloudflare.com; frame-src https://challenges.cloudflare.com; style-src 'self'; frame-ancestors 'self'`, no Trusted Types) and `X-Frame-Options: SAMEORIGIN` (`$frame_options`); the app's CSP only adds `frame-src 'self'`. `Env`: `TURNSTILE_SITE_KEY` + `APP_PUBLIC_URL` (devices; the page origin on the web) -> `Env.captchaPage`, null without either (then "try again later"); local uses Cloudflare's testing key, staging/production stay empty until the Cloudflare account and the domains. Tests replace the view through `captchaViewBuilderProvider` (`FakeCaptcha` in `test/helpers/captcha.dart`, `captchaEnv`, `pumpMonthraApp(captcha:)`) with motion off (the skeleton pulses). Follow-up: open the widget's privacy/terms links in the external browser (refused in the webview now).
- **Shell and settings (`lib/app/shell/`, `lib/features/settings/`, PR shell; user decisions of 2026-11-22: the old shell-settings item split in three PRs, shell -> settings-security -> settings-data; the menu lists only pages that exist):** `ShellDestination` (an enum: path, Lucide icon, `ShellPlacement.bar`/`more` on a phone, `label`, `page`, sub-`routes`) is the one place a feature adds its page; its order is the sidebar's and the bar's. One branch per destination (`StatefulShellRoute.indexedStack`: own history and scroll position; Flutter's `IndexedStack` already takes focus away from the hidden branches, which a test guards). `AppShell` by breakpoint: desktop = `ShellSidebar` (256 px: logo, destinations, catalog link outside production, `AccountSummary` and sign-out), tablet = the same collapsed to icons (72 px, `ShadTooltip` sharing the button's focus node, so hover, long press and keyboard focus show the label; avatar read as `shellSignedInAs`), phone = `ShellBottomBar` in its final shape (bar destinations, a `centerAction` slot for the new-transaction button of the transactions PR, More; entries capped at 120 px and centered, labels up to 1.5x). More is a bottom `ShadSheet` (`showMoreSheet`, not a page: it gathers destinations of several branches) with the account, the `more` destinations, the catalog and sign-out; it pops a `MoreChoice` and the shell acts after (a branch change would leave a sheet over the shell); labeled barrier and 44 px close; More reads selected while a `more` destination shows. Landmarks: `navigation` (labeled `shellNavigationLabel`) around the destinations, `main` around the branch. No `Scaffold`: with the keyboard up the bar hides and the content is padded by the inset. Sign-out lives in the shell (a browser that could not sign out gets a destructive toast and stays signed in). Tapping the destination shown goes back to its first page. `MonthraPage` (title as a heading, description, actions, gutter 16/24/32, max width) frames every page; `showMonthraToast` (core takes the close label from the caller) is the one toast. Settings: `SettingsPage` (`MonthraLayout.maxFormWidth`) shows `settingsSections` in order (profile, preferences, security, sessions; data comes next); a flow with its own screen becomes a sub-route of `ShellDestination.settings`. Profile: the name (trimmed, `AuthValidators.validateName` from `core/forms`, the server's field errors under the field, others in a `FormAlert`, a toast when saved), the email read-only (no email change on the server). Preferences: `LanguagePicker`, `ThemePreferencePicker`, `CurrencySelect` (the default currency suggested for new accounts; nothing converts) and the budget alert emails switch, in `SettingsRow`s. **Sync (`ProfileController`, keepAlive):** language and theme apply and save on the device at once, then go to `PATCH /me/preferences`; currency and alerts show from `ProfileEdits.pending` until answered. One request at a time; choices made meanwhile merge into the next (`PreferencesPatch`), so the last choice wins and quick changes cost two requests; a value the profile already has, with nothing pending for it, sends nothing. A refusal puts each field back as the profile has it, unless a newer choice is queued or the device moved on, and sets `ProfileEdits.failure` (a new object each time), which the shell shows as a toast wherever the person is. The loop clears itself in the same step as its last queue check; answers after a sign-out or for another person (generation and id) are dropped. Signed out (the catalog's pickers) changes stay on the device. `AuthController.updateMe(userId, update)` applies an answer to `SignedIn` for the same person only, changing only what the call answered (rename: the name; preferences: the preferences), never the local language and theme. `MeApi` (`lib/features/settings/data/me_api.dart`) holds the `/me/*` calls (`readJson` from `core/network/api_body.dart` reads every answer); `GET /me` stays in `AuthApi`. **Dependency rule:** `features/auth` imports only the leaf `settings/preferences/{domain,data,application}`; the rest of `settings/` sits above auth (picker -> `ProfileController` -> `AuthController`). Branch widget state goes with a sign-out, provider state does not: a feature's providers holding user data must reset when the signed-in id changes (as `ProfileController` does). Tests: `pumpFrame` takes `auth` (a `StubAuthController` state, no start-up check) and `api`; `ProfileServer` (`test/helpers/profile_server.dart`) is a stateful fake of the profile routes with `hold()` gates and `fail()`; the shell tests run the tap target, label and contrast guidelines at the three sizes in both themes (the More sheet open too) and twice the text size.
- **Security settings (`lib/features/settings/presentation/security/`, PR settings-security; user decisions of 2026-11-22: QR with the `qr` package and our own painter, not `qr_flutter`; new recovery codes through a server endpoint (monthra-server PR #19) rather than off-and-on; "Open in the authenticator app" on devices with `url_launcher`; recovery codes = copy all + an "I saved them" checkbox, a `.txt` download waits for settings-data):** the account form widgets live in `lib/core/forms/` (`FormAlert`, `AuthValidators`/`AuthLimits`, `Countdown`, `EmailField`/`PasswordField` with `id` and `label`, `SecondFactorField` + `SecondFactorController` + `SecondFactorToggle`: the 6-digit code or a recovery code, shared with the sign-in MFA page). Sub-routes of `ShellDestination.settings` (paths in `AppRoutes`, relative through `_under`): `/settings/password` (`ChangePasswordPage`, `POST /me/password`; the server signs the other sessions out, so it invalidates `sessionsControllerProvider`), `/settings/mfa/enable` (`EnableMfaPage`: password -> `MfaSetup` QR + key + code -> codes; a `Timer` of `expiresIn` or a `409 mfa_setup_required` starts over), `/settings/mfa/disable`, `/settings/mfa/recovery-codes`. `StepUpForm` is the password(+code) form: `password_incorrect` under the password, selected (an emptied field would read "required" over the server's word), `mfa_code_invalid` empties the code with an alert, a `429` holds the button (the address lockout counts step-up failures). `RecoveryCodesView` shows codes once; while unsaved (`UnsavedRecoveryCodes`, keepAlive, reset with the signed-in id) the routes' `onExit` (`confirmLeavingRecoveryCodes`) asks before any way out (back link, platform back, the menu) and lets a sign-out or an expired session through. A `409` saying MFA changed elsewhere calls `AuthController.refreshProfile` (`GET /me`, applied like `updateMe`); answers apply with `updateMe(copyWith(mfa:))`. The secret and the codes live in page state only, never in a provider or a log; `SessionInfo`/`MfaSetup` keep the address and the secret out of `toString`. `QrCodeView` (design system) paints ink on white in both themes (the one component reading the palette), quiet zone 4, whole-pixel modules. `AuthenticatorLauncher` (`authenticatorLauncherProvider`, faked in tests) uses `canLaunchUrl`, which needs `otpauth` in the Android `<queries>` and the iOS `LSApplicationQueriesSchemes`; always false on the web. Sessions: `SessionsController` (`@Riverpod(retry: noProviderRetry)`: the client already resends transient reads, Riverpod 3 would also repeat refusals), this device first; `describeUserAgent` names the device; native clients send `User-Agent: Monthra (iOS|Android)` (`nativeUserAgent`, bearer mode only). `showMonthraConfirm` (design system) asks before signing out every other session. Tests: `ProfileServer` fakes the password, sessions (`holdReads()`) and MFA routes (password `testPassword`, the app's code `testTotp`, deterministic recovery codes); `pumpMonthraApp(overrides:)`; a platform back that hits `onExit` waits for the dialog, so start `handlePopRoute()` without awaiting it; toasts sit at the bottom right on a desktop over what is below (`waitOutToasts`); a test that awaits a dio call must pump before awaiting.
- **Golden tests:** rendered and compared on Linux only (font rasterization differs on macOS; emulating amd64 changes Skia's SIMD paths), laid out everywhere (an overflow fails on a Mac too) with the comparison skipped off Linux (`test/helpers/golden.dart`, tag `golden`). CI is the reference: a failed `test` job renders them again and uploads the `goldens` artifact; `make goldens-pull` copies it into `test/`; look at every image before committing. The comparator tolerates 0.1% of differing pixels. Tests load the app fonts from `FontManifest.json` (`test/flutter_test_config.dart`), which also preloads shadcn_ui's deferred pt/es strings. `TestFrame`/`pumpFrame` default to pt-BR with an in-memory preferences store and pump until the localizations are in (`pumpUntilLocalized`: the VM's `loadLibrary` waits on a zero-length timer, so `pump(Duration.zero)`, never a bare `pump()`); the whole app goes through `pumpMonthraApp` (`test/helpers/app.dart`). The test device speaks en-US.
- **Bundle ID / application id (user decision of 2026-11-15):** `com.nickealves.monthra`. Flavors: `dev` (`.dev`, "Monthra Dev") = `APP_ENV=local` (`env/local.json`), `staging` (`.staging`, "Monthra Staging") = `staging`, `prod` (no suffix, "Monthra") = `production`. `default-flavor: dev`. Android: `productFlavors` with a `manifestPlaceholders["appName"]`; iOS: build configurations `{Debug,Profile,Release}-{flavor}` with `PRODUCT_BUNDLE_IDENTIFIER` and `APP_DISPLAY_NAME` in the Runner target, shared schemes named after the flavors. iOS plugins come through Swift Package Manager only (no Podfile).
- **Build configuration:** `lib/core/config/env.dart` (`Env.fromEnvironment`) validates the defines at boot: unknown `APP_ENV`, a flavor of another environment, a mobile build without `API_BASE_URL`, an address that is not an origin (`API_BASE_URL`, `APP_PUBLIC_URL`), a malformed `TURNSTILE_SITE_KEY`, http outside local all stop the app. `SENTRY_DSN` is read but unused until a provider is wired.
- **Web calls its own origin:** the web app always uses `/api/v1` on the page origin (`Uri.base`) and ignores `API_BASE_URL`, so the `SameSite=Strict` cookies work and the CSP stays at `connect-src 'self'`. Locally `web_dev_config.yaml` (port 3000, the origin the server's local `.env` allows) proxies `/api` to `localhost:8080`; in Docker nginx proxies it to `monthra-api:8080` on `monthra-net` (Docker DNS, resolved per request); on a deployment the monthra-infra proxy routes it. Mobile uses `API_BASE_URL` (empty for staging/production until the domains exist). Only the Android `dev` flavor allows cleartext (`localhost`, `127.0.0.1`, `10.0.2.2`, network security config in `src/dev`); dart:io HTTP ignores iOS ATS, so iOS needs no exception. Android: `allowBackup=false` plus data extraction rules excluding everything.
- **Web image and CSP:** the build stage clones Flutter's git tag and checks the release commit (no maintained image ships 3.47; `ghcr.io/cirruslabs/flutter` stops at 3.44), then `flutter build web --release --csp --no-web-resources-cdn` (CanvasKit and fallback fonts bundled, no gstatic.com, no eval). Runtime: `nginxinc/nginx-unprivileged` pinned by digest plus `apk upgrade` (Trivy fails on fixed HIGH/CRITICAL), our whole `nginx/nginx.conf`, read-only filesystem. The image pins nginx.org's nginx (and its modules) in `/etc/apk/world`, so `apk upgrade` never moves nginx itself: when an nginx fix lands in Alpine before a new base image, the Dockerfile swaps in Alpine's package (`apk del` the modules, `apk add 'nginx>=x.y.z'`; the configuration loads no module and moves pid, temp paths and logs to `/tmp` and stdio, so either build runs read-only). Since 2026-11-22 it does so for nginx 1.30.7 (six CVEs in 1.30.6): drop the swap with the next base image bump. CSP without `unsafe-inline`: nginx replaces every `__CSP_NONCE__` in `index.html` (`boot.js` and the bootstrap script) with `$request_id` (`sub_filter`, `sub_filter_once off`), and `web/flutter_bootstrap.js` passes `document.currentScript.nonce` to `_flutter.loader.load({config: {nonce}})`. Trusted Types are enforced (`flutter-js`, `dart.deferred-loading`). `base-uri 'self'`, never `'none'` (it voids `<base href="/">` and deep routes break). `index.html` has no inline style or script (web splash in `splash.css`, removed on `flutter-first-frame`). SVGs get a CSP of their own (the favicon's inline dark-mode style). Paths without an extension serve `index.html`; a missing file is a 404. `no-cache` + ETag everywhere until Flutter 3.50 (`--web-content-hash`). A new third-party origin (Turnstile, the Open Finance widget) goes in the CSP map, for its directives only.
- **Icons and splash:** `flutter_launcher_icons.yaml` and `flutter_native_splash.yaml` (one config for every flavor, `make icons`). `assets/icon/` holds layers drawn from the logo's bars: the Android adaptive foreground and monochrome (scaled by 2/3 to match iOS), the iOS 18 dark and tinted icons and the Android 12 splash logos. The web icons, favicon (SVG with a dark-mode style) and web splash are kept by hand.
- **Lint:** `very_good_analysis` (without `public_member_api_docs`) plus `strict-casts`, `strict-inference`, `strict-raw-types`, and the `riverpod_lint` analyzer plugin (`plugins:` in `analysis_options.yaml`); `dart analyze --fatal-infos`, because `flutter analyze` does not run analyzer plugins. Dart 3.13 constructor syntax (`const new(...)`, `factory parse(...)`). The analyzer sees compile-time defines as empty, so a function taking them has required parameters, never defaults that equal them.
- **CI** (`.github/workflows/ci.yml`): gitleaks, analyze (ARB check, generated code current, format, `dart analyze`, `pub outdated`), test (coverage summary), web image (build `FLUTTER_ENV=staging`, Trivy, `scripts/smoke-web.sh` against the read-only container), android (debug `dev` and obfuscated release `prod`, application ids checked with `aapt`), ios (`macos-latest`, obfuscated unsigned `prod`, bundle id checked). Flutter comes from `pubspec.yaml` (`environment.flutter`).
- **Step 4 roadmap (one PR per item, each with its own plan):** scaffold -> design-system (tokens, Inter, light/dark `ShadThemeData`, `MonthraCard`/`AmountText`/`CategoryBadge`/`EmptyState`/`Skeleton`, goldens on Linux) -> i18n-preferences (ARB pt/es/en, CI key check, `preferencesProvider`, `lang` attribute) -> api-client (dio, CSRF, single-flight refresh with `409 refresh_conflict`, problem+json, secure storage) -> auth (go_router guards, `/verify-email` and `/reset-password` read the fragment token, MFA) -> captcha (Turnstile, user decision of 2026-11-15: its own PR, our own static `web/turnstile.html` with its own CSP, in an iframe on the web and in the official `webview_flutter` on devices loading the hosted page; not the `cloudflare_turnstile` package; the server checks `action` and `hostname` since monthra-server PR #17) -> shell (responsive shell, profile, preferences sync; user decision of 2026-11-22: the old shell-settings item split in three) -> settings-security (password, MFA with QR and recovery codes, sessions; new recovery codes need monthra-server PR #19) -> settings-data (export the ZIP, delete the account) -> dashboard -> accounts (+ invoices) -> categories -> transactions -> recurrences -> budgets (`/budgets?month=`) -> investments -> reports (PDF in the app) -> mobile-security (biometrics, `FLAG_SECURE`, inactivity logout, pinning) -> landing -> 3D icons. Bank connections (§7.7) wait for the Open Finance aggregator.

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
