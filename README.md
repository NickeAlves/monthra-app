# monthra-app

The Monthra app: personal finance for **web, Android and iOS** from a single **Flutter** codebase, built on `shadcn_ui` and Lucide icons.

> Status: scaffold. The design system, i18n, API client and the screens arrive one pull request at a time (roadmap in [CLAUDE.md](CLAUDE.md)).

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

- **CSP without `unsafe-inline`:** nginx writes a fresh nonce (the request id) on the bootstrap script of every `index.html`; `web/flutter_bootstrap.js` hands it to the engine, which tags the styles and scripts it creates. CanvasKit and the fallback fonts are bundled (`--no-web-resources-cdn`), so nothing loads from another origin; `--csp` keeps the JavaScript free of `eval`; Trusted Types are enforced.
- HSTS, `nosniff`, `frame-ancestors 'none'` / `X-Frame-Options: DENY`, `Referrer-Policy`, a restrictive `Permissions-Policy`, COOP/CORP, no nginx version.
- SPA routing: paths without an extension serve the app (`/verify-email`, `/budgets`), a missing file is a 404.
- `no-cache` with ETag revalidation everywhere: Flutter 3.47 builds carry no content hash (`--web-content-hash` needs 3.50).
- Precompressed `.gz` files (`gzip_static`); a JSON access log without query strings.

## Icons and splash screens

`make icons` regenerates them from `assets/brand/` (the brand pack) and `assets/icon/` (layers the pack lacks, drawn from the logo's bars: the Android adaptive foreground and monochrome, the iOS 18 dark and tinted icons, the Android 12 splash logos). The web icons in `web/icons/` and the web splash (`web/index.html`, `web/splash.css`) are kept by hand. Every splash follows the system theme (`#F5F5F3` light, `#141414` dark), so a dark device never flashes white.

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
