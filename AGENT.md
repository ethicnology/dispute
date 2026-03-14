# Agent & Contributor Guide

## Project Overview

Dispute is a cross-platform Nostr ecosystem built as a **melos monorepo** with a shell + plugin architecture.

### Apps
- **shell** — The host application, buildable standalone or with any combination of plugins
- **dispute** (v2) — Cross-platform Nostr client, injected as a plugin into the shell
- **zeronet** — ZeroNet-on-Nostr experiment, injected as a plugin into the shell

### Packages
- **core** — Shared infrastructure: plugin interface, Nostr primitives, theming, common widgets. No business logic.

## Tech Stack

- **Flutter** 3.41.x / **Dart** 3.11.x (pinned via FVM in `.fvmrc`)
- **Melos** 7.4+ for monorepo management (config lives in root `pubspec.yaml` under `melos:` key — no `melos.yaml`)
- **BLoC** (`flutter_bloc`) for state management
- **Conventional Commits** for git history and automated changelogs
- All 6 platforms: Android, iOS, macOS, Windows, Linux, Web

## Monorepo Structure

```
dispute/
├── LICENSE                    # GPL-3.0
├── AGENT.md                   # this file
├── .fvmrc                     # Flutter version pin
├── .gitignore
├── pubspec.yaml               # workspace root + melos config
├── apps/
│   ├── shell/                 # host app (only runnable target)
│   ├── dispute/               # nostr client plugin package
│   └── zeronet/               # zeronet plugin package
└── packages/
    └── core/                  # shared infrastructure
```

### Package Resolution

Every package in the workspace must declare `resolution: workspace` in its `pubspec.yaml`.

## Getting Started

```bash
# Use the pinned Flutter version
fvm install
fvm use

# Install melos
dart pub global activate melos

# Bootstrap the workspace
melos bootstrap

# Run analysis
melos run analyze

# Run tests
melos run test

# Format code
melos run format
```

## Shell + Plugin Architecture

The shell is independently buildable. Sub-apps are optional and toggled at build time via `--dart-define`:

```bash
# Full build with all plugins
fvm flutter run --dart-define=INCLUDE_DISPUTE=true --dart-define=INCLUDE_ZERONET=true

# Shell only
fvm flutter run --dart-define=INCLUDE_DISPUTE=false --dart-define=INCLUDE_ZERONET=false
```

Each plugin implements the `AppPlugin` interface from `core`.

## Architecture Rules

This project follows **Clean Architecture** and **Hexagonal Architecture (Ports & Adapters)** with **feature-based organization**.

### Feature Structure

Each feature is a self-contained module:

```
feature_name/
├── feature_name.dart              # barrel file — the ONLY public API (facade)
├── domain/
│   ├── entities/                  # domain models with business rules (not DTOs)
│   ├── domain_errors.dart         # sealed error types for this layer
│   └── value_objects/
├── application/
│   ├── ports/                     # inbound & outbound port interfaces
│   ├── usecases/                  # orchestration of business operations
│   ├── services/                  # shared logic across usecases (optional)
│   └── application_errors.dart    # sealed error types for this layer
├── interface_adapters/
│   ├── repositories/              # secondary/driven adapters (outbound port impls)
│   └── mappers/                   # data <-> domain mapping
├── frameworks/
│   ├── datasources/               # external deps (DB, API clients, drivers)
│   └── models/                    # DTOs, persistence models
├── presentation/
│   ├── bloc/                      # BLoCs/Cubits — thin, delegate to usecases
│   └── presentation_errors.dart   # sealed error types for this layer
└── ui/
    ├── pages/
    └── widgets/
```

### Rules

1. **Feature = single owner of its domain.** No other feature may import its internals.
2. **Barrel file = the only public API.** Cross-feature interaction goes through the facade only.
3. **Dependency rule flows inward.** UI → Presentation → Application → Domain. Never the reverse.
4. **BLoCs stay thin.** They only transform between UI state and usecase calls. No business logic.
5. **Ports define needs, adapters fulfill them.** What vs how is clearly separated.
6. **Each layer owns its error types.** Map errors at layer boundaries using sealed classes.
7. **Core is infrastructure only.** No business logic — just primitives, drivers, and helpers.
8. **Don't over-abstract.** Skip the datasource layer if a repository alone suffices.
9. **Widget state vs BLoC state.** Ephemeral UI state stays in StatefulWidget. BLoC is for business state.
10. **Entities are not DTOs.** Domain models must encapsulate business rules, not mirror database schemas.

### Common Pitfalls to Avoid

- **Breaking feature boundaries** — never import another feature's internals. Use its barrel/facade.
- **Business logic in presentation** — BLoCs should not contain orchestration or complex transformations.
- **Bypassing the application layer** — watchers/adapters must go through usecases, not call repositories directly.
- **Core module bloat** — don't put feature-specific logic in core.
- **Anemic domain models** — entities should encapsulate rules, not be plain data containers.
- **State management confusion** — don't mix ephemeral widget state with BLoC state.

## Git Conventions

### Conventional Commits

Format: `type(scope): description`

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `build`

**Scopes:** `shell`, `dispute`, `zeronet`, `core`, `monorepo`

**Examples:**
```
feat(dispute): add relay connection management
fix(core): handle null key in event signing
refactor(shell): extract plugin registry into separate class
chore(monorepo): update melos scripts
```

**Version bump rules (via melos):**
- Breaking changes (`feat!:`, `fix!:`, or `BREAKING CHANGE` in body) → major
- `feat` → minor
- `fix`, `refactor`, `perf`, `docs` → patch
- `chore`, `ci`, `build`, `test` → no bump

## Testing

- **Minimum:** unit tests for usecases and entities that contain business rules.
- Each package's tests run independently via `melos run test`.

## Adding a New Feature

1. Create the feature folder under the appropriate app's `lib/src/features/`
2. Follow the feature structure above
3. Expose the public API via the barrel file only
4. Write unit tests for usecases and domain entities
5. Run `melos run analyze` and `melos run test` before committing

## Adding a New Plugin App

1. Create a new directory under `apps/`
2. Add a `pubspec.yaml` with `resolution: workspace` and a dependency on `core`
3. Implement the `AppPlugin` interface from `core`
4. Export the plugin via a barrel file
5. Add the dependency and `--dart-define` toggle in the shell
6. Add the workspace entry in root `pubspec.yaml` if not covered by the `apps/*` glob
