# Agent & Contributor Guide

## Project Overview

Dispute is a cross-platform Nostr ecosystem built as a **melos monorepo** with a shell + plugin architecture.

### Apps
- **shell** — The host application, buildable standalone or with any combination of plugins
- **dispute** (v2) — Cross-platform Nostr client, injected as a plugin into the shell
- **zeronet** — ZeroNet-on-Nostr experiment, injected as a plugin into the shell

### Packages
- **plugin_interface** — `AppPlugin` contract that each sub-app implements
- **nostr** — Nostr abstraction layer wrapping `dart-nostr`. Import this instead of `dart-nostr` directly.

## Tech Stack

- **Flutter** 3.41.x / **Dart** 3.11.x (pinned via FVM in `.fvmrc`)
- **Melos** 7.4+ for monorepo management (config lives in root `pubspec.yaml` under `melos:` key — no `melos.yaml`)
- **BLoC** (`flutter_bloc`) for state management
- **Drift** (encrypted) for persistence
- **Conventional Commits** for git history and automated changelogs
- All 6 platforms: Android, iOS, macOS, Windows, Linux, Web

## Monorepo Structure

```
dispute/
├── LICENSE                    # GPL-3.0
├── AGENT.md                   # this file
├── README.md
├── .fvmrc                     # Flutter version pin
├── .gitignore
├── pubspec.yaml               # workspace root + melos config
├── apps/
│   ├── shell/                 # host app (runnable, loads plugins)
│   ├── dispute/               # nostr client plugin
│   └── zeronet/               # zeronet plugin
└── packages/
    ├── plugin_interface/      # AppPlugin contract
    └── nostr/                 # Nostr abstraction layer
```

### Package Resolution

Every package in the workspace must declare `resolution: workspace` in its `pubspec.yaml`.

## Getting Started

```bash
fvm install
dart pub global activate melos
melos bootstrap
melos run analyze
melos run test
```

## Shell + Plugin Architecture

The shell is independently buildable. Sub-apps are optional and toggled at build time via `--dart-define`:

```bash
fvm flutter run --dart-define=INCLUDE_DISPUTE=true --dart-define=INCLUDE_ZERONET=true   # all plugins
fvm flutter run --dart-define=INCLUDE_DISPUTE=false --dart-define=INCLUDE_ZERONET=false  # shell only
```

Each plugin implements the `AppPlugin` interface from `plugin_interface`.

## Architecture Rules

This project follows **Clean Architecture** and **Hexagonal Architecture (Ports & Adapters)** with **feature-based organization**.

### Feature vs Package

- **Feature** — a folder inside an app's `lib/features/`. Internal to that app only. No `pubspec.yaml`.
- **Package** — a reusable module under `packages/` with its own `pubspec.yaml`. Any app can depend on it.

Rule: **start as a feature. Extract to a package only when a second consumer appears.**

Packages should not own databases or concrete infrastructure. They define **ports** (interfaces) and let the consuming app provide **adapters** (implementations).

### Feature Structure

Each feature is a self-contained module:

```
feature_name/
├── feature_name.dart              # barrel file — the ONLY public API (facade)
├── domain/
│   ├── thing_entity.dart          # domain models with business rules (not DTOs)
│   └── domain_errors.dart         # sealed error types for this layer
├── application/
│   ├── ports/
│   │   └── thing_port.dart        # outbound port interfaces
│   └── usecases/
│       └── do_thing_use_case.dart # orchestration — calls domain + ports
├── adapters/
│   └── thing_sqlite.dart          # concrete port implementations (driven adapters)
├── presentation/
│   ├── thing_bloc.dart            # thin — delegates to usecases
│   ├── thing_event.dart
│   └── thing_state.dart
└── ui/
    ├── thing_page.dart
    └── widgets/
        └── thing_widget.dart
```

**Folder rule:** only create a subfolder when it contains more than one file. Single files stay at the parent level.

### Naming Conventions

| Layer | Suffix | Example |
|---|---|---|
| Entity | `_entity.dart` | `account_entity.dart` |
| Port | `_port.dart` | `account_port.dart` |
| Use case | `_use_case.dart` | `generate_account_use_case.dart` |
| Adapter | named by impl | `account_sqlite.dart`, `account_shared_preferences.dart` |
| BLoC | `_bloc.dart` | `wizard_bloc.dart` |
| Page | `_page.dart` | `wizard_page.dart` |
| Widget | `_step.dart`, `_card.dart`, etc. | `account_step.dart` |

### Domain vs Application

**Domain** — pure business concepts. Zero dependencies (no Flutter, no packages, no IO).
- What is an account? What rules govern it?
- Entities, value objects, validation, business rules
- If you can describe it without mentioning software, it's domain

**Application** — orchestration of domain logic + coordination with external systems through ports.
- "Generate keys, build account, save it, return it"
- Usecases call domain objects and talk through ports
- If it touches a port, it's application. If it's pure computation, it's domain.

Rule: **if a usecase has zero ports and just calls domain objects, the logic should live in the entity instead.**

### Rules

1. **Feature = single owner of its domain.** No other feature may import its internals.
2. **Barrel file = the only public API.** Cross-feature interaction goes through the facade only.
3. **Dependency rule flows inward.** UI → Presentation → Application → Domain. Never the reverse.
4. **BLoCs stay thin.** They only transform between UI state and usecase calls. No business logic.
5. **Ports define needs, adapters fulfill them.** What vs how is clearly separated.
6. **Each layer owns its error types.** Map errors at layer boundaries using sealed classes.
7. **Packages are infrastructure only.** No business logic — just primitives, drivers, and interfaces.
8. **Don't over-abstract.** Skip layers if they add no value. Three lines of code > premature abstraction.
9. **Widget state vs BLoC state.** Ephemeral UI state stays in StatefulWidget. BLoC is for business state.
10. **Entities are not DTOs.** Domain models must encapsulate business rules, not mirror database schemas.

### Common Pitfalls to Avoid

- **Breaking feature boundaries** — never import another feature's internals. Use its barrel/facade.
- **Business logic in presentation** — BLoCs should not contain orchestration or complex transformations.
- **Bypassing the application layer** — adapters must go through usecases, not call other adapters directly.
- **Package bloat** — don't put feature-specific logic in packages.
- **Anemic domain models** — entities should encapsulate rules, not be plain data containers.
- **State management confusion** — don't mix ephemeral widget state with BLoC state.
- **Useless usecases** — if a usecase just delegates to one domain method with no ports, remove it.

## Git Conventions

### Conventional Commits

Format: `type(scope): description`

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `build`

**Scopes:** `shell`, `dispute`, `zeronet`, `plugin-interface`, `nostr`, `monorepo`

**Examples:**
```
feat(dispute): add relay connection management
fix(nostr): handle null key in event signing
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

1. Create the feature folder under the app's `lib/features/`
2. Follow the feature structure and naming conventions above
3. Expose the public API via the barrel file only
4. Write unit tests for usecases and domain entities
5. Run `melos run analyze` and `melos run test` before committing

## Adding a New Plugin App

1. Create a new directory under `apps/`
2. Add a `pubspec.yaml` with `resolution: workspace` and a dependency on `plugin_interface`
3. Implement the `AppPlugin` interface
4. Export the plugin via a barrel file
5. Add the dependency and `--dart-define` toggle in the shell
6. Add the workspace entry in root `pubspec.yaml`

## Adding a New Package

1. Create a new directory under `packages/`
2. Add a `pubspec.yaml` with `resolution: workspace`
3. Define ports (interfaces) — not concrete implementations
4. Export via a barrel file
5. Add the workspace entry in root `pubspec.yaml`
