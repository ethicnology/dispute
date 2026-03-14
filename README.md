# Dispute

A cross-platform Nostr ecosystem built as a monorepo.

## Repository Structure

```
dispute/
├── apps/
│   ├── shell/              # Host app — loads plugins via bottom nav
│   ├── dispute/            # Nostr client (v2)
│   └── zeronet/            # ZeroNet on Nostr
└── packages/
    ├── plugin_interface/   # AppPlugin contract
    └── nostr/              # Nostr abstraction layer (wraps dart-nostr)
```

## Prerequisites

- [FVM](https://fvm.app) — Flutter version management
- [Melos](https://melos.invertase.dev) — monorepo tooling

## Setup

```bash
fvm install
dart pub global activate melos
melos bootstrap
```

## Commands

```bash
melos run analyze          # Lint all packages
melos run test             # Test all packages
melos run format           # Format all packages
melos run clean            # Clean all packages

melos run run:shell        # Run shell (all plugins)
melos run run:dispute      # Run dispute standalone
melos run run:zeronet      # Run zeronet standalone
```

## Build Flags

The shell loads all plugins by default. Toggle with `--dart-define`:

```bash
cd apps/shell
fvm flutter run --dart-define=INCLUDE_DISPUTE=false   # shell without dispute
fvm flutter run --dart-define=INCLUDE_ZERONET=false    # shell without zeronet
```

## Architecture

See [AGENT.md](AGENT.md) for architecture rules, conventions, and contributor guide.

## License

[GPL-3.0](LICENSE) — ethicnology
