# monthra-app

The Monthra app: personal finance for **web, Android and iOS** from a single **Flutter** codebase, built on `shadcn_ui` and Lucide icons.

> Status: design system, languages and preferences, API client. The screens arrive one pull request at a time (roadmap in [CLAUDE.md](CLAUDE.md)). Until the first screens, local and staging builds open on the design system catalog; production shows the brand page.

## Requirements

- Flutter **3.47.8** (stable; pinned in `pubspec.yaml`, CI installs the same version)
- Chrome for the web, Xcode for iOS, Android Studio or the Android SDK (JDK 17) for Android
- Docker, for the nginx image and the compose files
- [`gitleaks`](https://github.com/gitleaks/gitleaks) for `make lint`
- The API from [monthra-server](https://github.com/NickeAlves/monthra-server) running locally (`make up` there) on `localhost:8080`

```bash
make deps      # flutter pub get, exactly as locked
make help      # every target
```

## Environments and flavors

Each build reads one file of `env/` through `--dart-define-from-file` (no secrets, so they are committed):

| `APP_ENV` | File | Mobile flavor | Bundle / application id |
|---|---|---|---|
| `local` | `env/local.json` | `dev` | `com.nickealves.monthra.dev` ("Monthra Dev") |
| `staging` | `env/staging.json` | `staging` | `com.nickealves.monthra.staging` ("Monthra Staging") |
| `production` | `env/production.json` | `prod` | `com.nickealves.monthra` ("Monthra") |

Besides `APP_ENV`, `API_BASE_URL` and `SENTRY_DSN`, each file holds `APP_PUBLIC_URL` (the web app's origin, which serves the captcha page devices load) and `TURNSTILE_SITE_KEY` (Cloudflare Turnstile, public). Locally they are `http://localhost:3000` and Cloudflare's testing key `1x00000000000000000000AA`; staging and production stay empty until the Cloudflare account and the domains exist, and without them a captcha request reads as "try again later".

The app refuses to start on a mismatch (unknown `APP_ENV`, a flavor of another environment, a mobile build without `API_BASE_URL`, an address that is not an origin, a malformed site key, or http outside local).

- **Web** always calls the API on its own origin (`/api/v1`), so the auth cookies (`SameSite=Strict`) work and the CSP keeps `connect-src 'self'`. Something in front routes `/api`: `web_dev_config.yaml` under `flutter run`, nginx in Docker, the monthra-infra proxy on a deployment. `API_BASE_URL` is ignored on the web.
- **Mobile** uses `API_BASE_URL`. The staging and production values stay empty until the domains exist (step 5, infra).

## Running locally

**Web with hot reload** (port 3000, the origin the server's local `.env` allows; `/api` goes to `localhost:8080`):

```bash
make run-web
```

**Mobile** (iOS simulator or Android emulator):

```bash
make run                       # dev flavor, env/local.json
make run FLAVOR=staging        # other flavors
```

The Android emulator reaches the host as `10.0.2.2`: `flutter run --flavor dev --dart-define-from-file=env/local.json --dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=APP_PUBLIC_URL=http://10.0.2.2:3000`. Only the `dev` flavor allows cleartext http (to `localhost`, `127.0.0.1` and `10.0.2.2`).

**Docker** (the nginx image, as deployed):

```bash
make network    # once: docker network create monthra-net
make up         # http://localhost:3000, /api proxied to monthra-api:8080 on monthra-net
make smoke      # routes, CSP nonce, security headers
make logs
make down
```

## Staging

```bash
make staging-up     # the staging build (env/staging.json) on http://localhost:3000
make staging-down
```

A real staging deployment sits behind the monthra-infra proxy (TLS, `/api` routing). The server's `HTTP_TRUSTED_PROXIES` must then name that proxy, so rate limits see the client's address.

## Builds

```bash
make build-web                   # build/web for production
make build-apk FLAVOR=prod       # obfuscated release APK (symbols in build/symbols)
make build-ios FLAVOR=prod       # obfuscated release, unsigned
make build                       # nginx image (FLUTTER_ENV=local|staging|production)
```

Release builds are obfuscated (`--obfuscate --split-debug-info=build/symbols`); keep the symbols of a release to read its crash stacks. Android release builds are signed with the debug key until the store keys exist.

## The web image

`Dockerfile` builds the web app with Flutter 3.47.8 from its git tag (checked against the release commit, since no maintained image ships 3.47) and serves it with `nginxinc/nginx-unprivileged` (non-root, port 8080, read-only filesystem). `nginx/nginx.conf`:

- **CSP without `unsafe-inline`:** nginx writes a fresh nonce (the request id) on the script tags of every `index.html` (`boot.js` and the bootstrap); `web/flutter_bootstrap.js` hands it to the engine, which tags the styles and scripts it creates. CanvasKit and the fallback fonts are bundled (`--no-web-resources-cdn`), so nothing loads from another origin; `--csp` keeps the JavaScript free of `eval`; Trusted Types are enforced.
- HSTS, `nosniff`, `frame-ancestors 'none'` / `X-Frame-Options: DENY`, `Referrer-Policy`, a restrictive `Permissions-Policy`, COOP/CORP, no nginx version.
- SPA routing: paths without an extension serve the app (`/verify-email`, `/budgets`), a missing file is a 404.
- `no-cache` with ETag revalidation everywhere: Flutter 3.47 builds carry no content hash (`--web-content-hash` needs 3.50).
- Precompressed `.gz` files (`gzip_static`); a JSON access log without query strings.

## Design system

`lib/core/design_system/` (import `design_system.dart`) holds everything a screen draws with. Screens never write a color, size, radius or duration by hand.

- **Tokens** (`tokens/`): the brand palette and the color roles of both themes (`MonthraColorSchemes`, plus `income`, `expense`, `warning`, `accentText` and `skeleton` through the `MonthraColors` extension on `ShadColorScheme`), spacing on a 4 px grid (`MonthraSpacing`), radii 8 to 12 (`MonthraRadii`), barely-there shadows, motion (150 to 250 ms, `easeOutCubic`, zero when the platform asks for less motion), breakpoints (mobile < 640 <= tablet <= 1024 < desktop) and the type scale (`MonthraTypography`: Inter 400/500/600, Inter's dynamic tracking, tabular figures for amounts).
- **Theme** (`theme.dart`): `monthraTheme(brightness)` builds the light and dark `ShadThemeData`. Controls are at least 44 px tall; the `sm` button size (36 px) is for pointer layouts only. The primary button is the brand green with white text in both themes; in the dark one, links, focus rings and accent text use the lifted green `#3FA37F`.
- **Components** (`components/`): `MonthraCard` (tappable cards get keyboard focus, hover and a focus ring), `AmountText` (minor units in the locale's format, colored and signed by kind, counting to new values), `CategoryIcon`/`CategoryBadge` (a category's Lucide icon and color, with the color moved until it reads on its tint), `EmptyState`, `ErrorState`, `Skeleton`/`SkeletonText` (pulsing in step, still under reduced motion) and `ButtonLabel` (a button label that shortens instead of overflowing at large text sizes).
- **Money** (`lib/core/money/`): `Currency` (BRL, USD, EUR) and `MoneyFormat.format(minor, currency, locale)`: `R$ 1.234,56` / `US$ 1.234,56` in pt-BR, `1.234,56 €` in es-ES, `$1,234.56` in en-US, the typographic minus (U+2212), exact up to the API's 10^13 cents.
- **Accessibility**: text roles read at 4.5:1 or more on every surface of both themes (`contrast_test.dart`); the catalog passes Flutter's tap target (44 px) and label guidelines, a color-based check of every text (4.5:1) and icon (3:1) against what is painted behind it (`test/helpers/contrast.dart`), and lays out at twice the text size. An icon-only button carries a label on its `Icon` (`semanticLabel`).
- **Catalog**: `/design-system` (outside production only), with the real theme and language pickers in its header.

### Fonts

Inter 4.1, subset to Latin (latin + latin-ext, the minus sign, the currency block) with every OpenType feature kept: about 135 KB per weight instead of 410 KB. `make fonts` downloads the release, checks its hash and regenerates `assets/fonts/inter/` (needs `python3`; fonttools goes into a throwaway venv). The OFL license ships next to the fonts and in the app's license list. Nothing is fetched at runtime (CSP `font-src 'self'`).

### Golden tests

Every component has golden images in both themes (`test/core/design_system/goldens/`, `test/features/**/goldens/`). Font rasterization differs between macOS and Linux, so goldens are compared on Linux only: on a Mac, `make test` still lays every subject out (an overflow fails) and reports the comparison as skipped; CI is the reference. When a change moves pixels:

1. Push. The CI `test` job fails on the goldens, renders them again and uploads them as the `goldens` artifact (with the diff images of the failures).
2. `make goldens-pull` (or `make goldens-pull RUN=<run id>`) copies them into `test/`.
3. Look at every changed image, then commit them.

The comparison tolerates 0.1% of differing pixels (antialiasing noise between runners).

## Languages and preferences

The UI speaks pt-BR (default), es-ES and en-US (§7.6 of CLAUDE.md). No screen writes a UI string by hand.

- **Strings:** `lib/l10n/app_pt.arb`, `app_es.arb` and `app_en.arb`, one file per language. `app_en.arb` is the template: each message has an `@key` entry with a `description` (and its `placeholders`). Keys are camelCase with an area prefix (`preferencesTheme`, `themeDark`). Read them with `context.l10n.themeDark` (`lib/l10n/l10n.dart`).
- **Adding a string:** add it to the three files (description in `app_en.arb` only), run `make gen` and commit the generated `lib/l10n/generated/`. `make l10n-check` (also in `make lint` and CI) fails on a key missing from a language, a key only one language has, a missing description, a dropped placeholder or an empty message; CI also fails when the generated code is stale.
- **Language names** are written in themselves ("Português (Brasil)", "Español (España)", "English (US)") in every UI language, so they live in `AppLocale`, not in the ARB files.
- **Which language:** the one the person picked, else the first device language that is Portuguese, Spanish or English whatever the region (pt-PT -> pt-BR, es-MX -> es-ES, en-GB -> en-US, the same rule as the API's `Accept-Language` matcher), else pt-BR. A change applies at once, without a restart. Numbers, money and dates take the locale from the context (`Localizations.localeOf`), never from `Intl.defaultLocale`. On the web Flutter writes `<html lang>` itself.
- **Preferences** (`lib/features/settings/preferences/`): `preferencesProvider` (Riverpod, generated with `riverpod_generator`) holds the language (null = follow the device) and the theme (System, Light, Dark); `appLocaleProvider` is the language in effect, the one source for the UI and the API client's `Accept-Language` (read on every call). They are kept in `shared_preferences` (nothing sensitive), read in `main` before the first frame, so the app opens in the saved theme and language. The profile sync (`PATCH /me/preferences`, the server's value wins at sign-in) comes with the sign-in and settings screens.
- **Pickers:** `LanguagePicker` and `ThemePreferencePicker`, for the settings and the public landing page (today in the catalog header and the provisional start page). The sign-in pages show none: before signing in the app follows the device, after it the profile.
- **No flash on the web:** the app also saves a small hint (`localStorage` `monthra.boot`, its own key); `web/boot.js` runs before the page paints and applies the saved theme and language, so a dark choice on a light system (or the other way round) never flashes the other theme. Without a hint the splash follows `prefers-color-scheme`. The native splash screens follow the system: they cannot read the app's preferences.
- **Generated code** (`make gen`): the localizations, the Riverpod providers and the models (`*.g.dart`, `*.freezed.dart`) are committed; CI regenerates them and fails on a difference.

## API client

`lib/core/network/` talks to the API under `/api/v1` (`Env.apiRoot`). Features read `apiClientProvider` and call `get`/`post`/`patch`/`delete` with the OpenAPI paths (`/accounts`); every failure is an `ApiException`, never a dio type:

| Exception | When |
|---|---|
| `ApiProblemException` | the API answered with a problem (`application/problem+json`): branch on `code` (`ProblemCode`), map `problem.errors` to the form fields (`codesOf('name')`, `FieldCode`); `retryAfter` on a `429` |
| `NetworkException` / `ApiTimeoutException` | no connection / too slow |
| `CancelledException` | the call's `CancelToken` was cancelled |
| `UnexpectedApiException` | an error without a problem body (a proxy page), an unreadable body, a client bug |

Each one carries the `requestId` (`X-Request-ID`) to match the server's logs. Screens turn them into text with `ApiErrorText` (`l10n.apiError(e)`, `l10n.fieldError(code)`): the app's own sentence per known code, and the request id as a reference only when the failure is unexpected; never the server's `detail` as it came.

**How the session travels.** The server tells a browser from a device by the `Origin` header:

- **Web:** cookies (`HttpOnly`, `SameSite=Strict`) the app never sees. Every POST/PATCH/PUT/DELETE, sign-in and refresh included, carries `X-CSRF-Token`, fetched once from `GET /auth/csrf` and again only after a `403 csrf_invalid` (the call is then sent once more).
- **Android and iOS:** `Authorization: Bearer`, with the token pair in `flutter_secure_storage` (one entry; Keychain "after first unlock, this device only"). The client never sends `Origin`.

**Renewal.** A `401` on a route that needs a session runs `POST /auth/refresh` once for every call waiting on it (single flight: the refresh token rotates, and the server revokes the session when an old one comes back), then sends those calls again. On the web a `409 refresh_conflict` means another tab renewed first: the call just goes again. When the session cannot be renewed the tokens are cleared and `sessionEventsProvider` emits `SessionEvent.expired` (the sign-in flow listens). The public routes (`ApiRoutes.public`: login, register, password reset...) take no token, and their `401` is the answer.

**Retries.** Only GET and HEAD go again by themselves (the server takes no `Idempotency-Key`): after a connection error or timeout, a `502`/`503`/`504`, or a `429`/`503` with a `Retry-After` of 10 s or less; waits of 300 ms and 1.2 s with jitter.

**Logs.** Debug builds print one line per call (`[api] GET /api/v1/me -> 200 12 ms (<request id>)`); never headers, query strings or bodies, and nothing in release builds.

**Against the real API:** `make test-live` runs `test/live/` (sign-in, renewal, sign-out as a device) with the server up and seeded (`make up && make seed` in monthra-server; pass the printed password as `MONTHRA_DEMO_PASSWORD`). `flutter test` skips it.

**Models** use `freezed` + `json_serializable` (`build.yaml`: `checked`, `explicit_to_json`); their generated `*.freezed.dart`/`*.g.dart` are committed like the rest (`make gen`).

## Routes and sign-in

`lib/app/router.dart` (go_router). Paths are clean on the web and keep the fragment (`PathUrlStrategy` with `includeHash`), because the email links carry their token there:

| Path | Who | Page |
|---|---|---|
| `/` | signed in | the start page (a greeting and sign-out until the app shell lands) |
| `/login`, `/login/mfa`, `/register`, `/forgot-password` | signed out | sign-in, the two-step code, sign-up, the reset request |
| `/verify-email#token=…`, `/reset-password#token=…` | anyone | the links of the account emails |
| `/design-system` | anyone, outside production | the design system catalog (the route does not exist in production) |

- **Guards** (`authRedirect`, a pure function): signed out, a page that needs a session goes to `/login?from=<path>`; signed in, the signed-out pages go on to `from` or `/`. `from` is only followed when it is a path of the app (`safeReturnPath`: no scheme, host, `//`, `\`, control characters or fragment), so a crafted link cannot send anyone elsewhere after signing in.
- **Start-up:** while the app checks an earlier session (`GET /me`) only the boot screen shows, and no page is built. A device checks when it holds tokens; the web when `localStorage['monthra.session']` says it signed in here (a mark with no secret: the session stays in the `HttpOnly` cookies), so an anonymous visit costs no request. An unreachable API shows "try again".
- **Session state** (`authControllerProvider`): booting, signed in (the profile, `Me`), signed out (with a notice: session ended, password changed, two-step expired), awaiting the two-step code (the challenge lives only in memory and expires with it), unavailable. Each time the profile loads, its language and theme replace the local ones (the server wins, §7.6).
- **Email links:** `/verify-email` sends its token once when it opens; `/reset-password` asks for the new password. Both take the token out of the address bar and the browser history right after reading it (`Router.neglect`: the history entry is replaced). A dead link offers a new one.
- **Signing out:** a device always forgets its tokens, even when the server cannot be told; a browser stays signed in and says so when the call fails, because its cookies only go away through the server.
- **Captcha** (`lib/features/auth/captcha/`): after repeated failed sign-ins (3 per address, 10 per IP) or sign-ups (3 per IP and hour), a server with `TURNSTILE_SECRET` answers `captcha_required`. The sign-in and sign-up pages then show Cloudflare Turnstile above the button and send the form again by themselves once it passes (`captchaToken`). A token works once, so every later attempt takes a fresh check; after a refused token (`captcha_invalid`) the person sends again, so a server refusing every token never loops. The widget lives in a page of its own, `web/turnstile.html` (+ `turnstile.js`, `turnstile.css`), with its own CSP: Cloudflare's script and frame only, no inline code, framed by the app's origin only. The web app shows it in an iframe (the app's CSP adds `frame-src 'self'` and nothing of Cloudflare's); devices load the same page from `APP_PUBLIC_URL` in `webview_flutter`, which may only show that page and Cloudflare's frames. The page reads its settings from the query string (site key, `action` `login`/`register`, theme, language, size, background) and only posts messages to the app, never reads any. A build without a site key (staging and production for now) keeps "too many attempts, try again later".
- **Deep links on devices:** the routes already handle `/verify-email#token=…`, but App Links (Android) and Universal Links (iOS) need the domain (pending with the cloud provider). Until then an email link opens the web app in the browser.

**Try it locally:** with the server up (`make up && make seed` in monthra-server) and `make run-web` (or `flutter run -d web-server --web-port 3000 --dart-define-from-file=env/local.json`), sign up at `http://localhost:3000/register`; the confirmation and reset emails land in Mailpit (`http://localhost:8025`), and their links open the app on port 3000.

**Try the captcha:** set `TURNSTILE_SECRET=1x0000000000000000000000000000000AA` (Cloudflare's testing secret, always passes) in monthra-server's `.env` and restart it, then sign in with a wrong password three times. The check appears and, with the testing key, passes by itself. `--dart-define=TURNSTILE_SITE_KEY=3x00000000000000000000FF` forces the interactive challenge, `2x00000000000000000000AB` makes it fail, and the secret `2x0000000000000000000000000000000AA` makes the server refuse every token. `make run-web` serves `turnstile.html` without the CSP; `make up` (nginx) shows the real headers. On a device the page comes from the web app, so keep `make run-web` or `make up` running.

## Icons and splash screens

`make icons` regenerates them from `assets/brand/` (the brand pack) and `assets/icon/` (layers the pack lacks, drawn from the logo's bars: the Android adaptive foreground and monochrome, the iOS 18 dark and tinted icons, the Android 12 splash logos). The web icons in `web/icons/` and the web splash (`web/index.html`, `web/splash.css`, `web/boot.js`) are kept by hand. Every splash follows the system theme (`#F5F5F3` light, `#141414` dark), so a dark device never flashes white; the web splash follows the theme the person chose, when there is one.

## Related repositories

| Repository | Purpose |
|---|---|
| [monthra-server](https://github.com/NickeAlves/monthra-server) | Go API, MongoDB, Redis, auth, business rules, metrics and traces |
| [monthra-app](https://github.com/NickeAlves/monthra-app) | Flutter app (web, Android, iOS) |
| [monthra-infra](https://github.com/NickeAlves/monthra-infra) | Terraform, observability stack, integrated compose, CI/CD |

## Branches

- `main`: production. `staging`: homologation. `develop`: development. All three accept changes only through pull requests.
- Work on `feature/<name>` or `fix/<name>` branched from `develop`, then open a PR to `develop`.
- Promotion: PR `develop` -> `staging` -> `main`. Releases are `vX.Y.Z` tags on `main`.
- Commits follow [Conventional Commits](https://www.conventionalcommits.org/).

## Contributing

Read [CLAUDE.md](CLAUDE.md) first: it holds the product overview, the design direction and the security rules every change must follow. Before a commit: `make lint` and `make test`.
