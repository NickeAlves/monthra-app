# monthra-app

The Monthra app: personal finance for **web, Android and iOS** from a single **Flutter** codebase, built on `shadcn_ui` and Lucide icons.

> Status: design system. i18n, the API client and the screens arrive one pull request at a time (roadmap in [CLAUDE.md](CLAUDE.md)). Until the first screens, local and staging builds open on the design system catalog; production shows the brand page.

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

The app refuses to start on a mismatch (unknown `APP_ENV`, a flavor of another environment, a mobile build without `API_BASE_URL`, or http outside local).

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

The Android emulator reaches the host as `10.0.2.2`: `flutter run --flavor dev --dart-define-from-file=env/local.json --dart-define=API_BASE_URL=http://10.0.2.2:8080`. Only the `dev` flavor allows cleartext http (to `localhost`, `127.0.0.1` and `10.0.2.2`).

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
- **Catalog**: `make run-web` opens on it (outside production only), with the real theme and language pickers in its header.

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
- **Preferences** (`lib/features/settings/preferences/`): `preferencesProvider` (Riverpod, generated with `riverpod_generator`) holds the language (null = follow the device) and the theme (System, Light, Dark); `appLocaleProvider` is the language in effect, the one source for the UI and, with the API client, `Accept-Language`. They are kept in `shared_preferences` (nothing sensitive), read in `main` before the first frame, so the app opens in the saved theme and language. The profile sync (`PATCH /me/preferences`, the server's value wins at sign-in) comes with the API client and the settings screen.
- **Pickers:** `LanguagePicker` and `ThemePreferencePicker`, for the login and landing screens and the settings (today in the catalog header).
- **No flash on the web:** the app also saves a small hint (`localStorage` `monthra.boot`, its own key); `web/boot.js` runs before the page paints and applies the saved theme and language, so a dark choice on a light system (or the other way round) never flashes the other theme. Without a hint the splash follows `prefers-color-scheme`. The native splash screens follow the system: they cannot read the app's preferences.
- **Generated code** (`make gen`): the localizations and the Riverpod providers (`*.g.dart`) are committed; CI regenerates them and fails on a difference.

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
