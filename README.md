# monthra-app

The Monthra app: personal finance for **web, Android and iOS** from a single **Flutter** codebase, built on `shadcn_ui` and Lucide icons.

> Status: bootstrapping. The Flutter project, Dockerfile and nginx config arrive with the app scaffold (step 4 of the roadmap in [CLAUDE.md](CLAUDE.md)).

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

Read [CLAUDE.md](CLAUDE.md) first: it holds the product overview, the design direction and the security rules every change must follow.
