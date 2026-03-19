# ZeroStr, ZeroNet over Nostr (P2P Websites with decentralized names resolution)

> **Warning**: This is a vibecoded proof of concept designed for the [SEC-06](https://sovereignengineering.io/) cohort to demo the idea. It is not reliable, not secure, and not suitable for production use.

## Background

The original [ZeroNet](https://github.com/HelloZeroNet/ZeroNet) (18k+ stars on GitHub) was a pioneering decentralized web platform that used Bitcoin cryptography for identity and BitTorrent for P2P file distribution. It allowed anyone to publish uncensorable websites directly from their device. The project has been unmaintained since the disappearance of its creator, but its community remains active and the core idea — **websites served directly between peers with no central hosting** — is as relevant as ever.

This proof of concept attempts to port the ZeroNet vision over **Nostr**, replacing Bitcoin addresses with Nostr keypairs, BitTorrent with WebRTC DataChannels, and .bit domains with Namecoin NIP-05 resolution. The result is a modern, cross-platform take on the same fundamental idea: **censorship-resistant personal websites, hosted by the people who read them**.

## Why?

The current state of decentralized website hosting on Nostr (e.g. [nsite](https://github.com/lez/nsite)) relies on:

- **Relays** to store file metadata events (kind 34128) mapping paths to hashes
- **Blossom servers** to store the actual file blobs (HTML, CSS, images)
- **Gateways** to resolve npub addresses, query relays, fetch blobs, and serve the site

This works, but every component of the infrastructure — relays, Blossom servers, gateways — is a identifiable server operated by someone. If a website hosts political or controversial content, these operators become targets. A relay can be seized, a Blossom server can receive a takedown notice, a gateway can be blocked by ISPs. The content may be signed and authenticated, but it still depends on third parties willing to store and serve it. The more controversial the content, the fewer operators will take that risk.

**ZeroNet takes a different approach**: relays are only used as a lightweight signaling / rendezvous layer to coordinate peers. The actual website content travels directly between peers via WebRTC DataChannels. No relay ever stores or serves a single byte of website content.

## How it works

### 1. Identity Setup

The user creates a Nostr identity (keypair), selects relays, and sets a display name. This identity is used for publishing, signing, and peer discovery.

### 2. Seed a Website

The seeder picks a folder containing a static website (HTML, CSS, JS, images, etc.). ZeroNet:

- Hashes every file (SHA-256)
- Copies files to a local `seeding/` directory
- Publishes one **NIP-94 event (kind 1063)** per file to the user's relays, signaling that the file is available for P2P transfer
- Starts a **WebRTC seeder** that listens for incoming download requests via Nostr ephemeral signaling events

The relay only stores lightweight NIP-94 metadata events (~200 bytes each). The actual files are never uploaded anywhere — they are served directly from the seeder's device.

### 3. Discover & Resolve

A leecher searches for a website by entering either:

- A raw **npub** (Nostr public key in bech32 format)
- A **Namecoin name** (e.g. `alice`, `nostr/bob`) — resolved via Namecoin's blockchain using the Electrum protocol, providing decentralized NIP-05-style identity without depending on any HTTP server

The app queries the seeder's relays for NIP-94 events (kind 1063), groups them by folder name, and presents the discovered websites with file count and total size.

### 4. P2P Download via WebRTC

When the leecher selects a website to download:

- For each file, a **WebRTC PeerConnection** is established via Nostr ephemeral signaling (offer/answer/ICE exchange over kind 25050 events)
- The seeder reads the requested file from disk and streams it over a **WebRTC DataChannel**
- The leecher saves each file locally, preserving the folder structure

No relay, server, or gateway is involved in the actual data transfer. It's a direct connection between two peers.

### 5. Render Locally

Once all files are downloaded, the website is displayed in a sandboxed **WebView** with a local file URL. The leecher can browse the site offline.

## Architecture Comparison

| | **nsite** (Relay + Blossom + Gateway) | **ZeroNet** (Relay + WebRTC) |
|---|---|---|
| **Content storage** | Blossom servers | Seeder's device (local disk) |
| **Content delivery** | HTTP via gateways | WebRTC DataChannel (P2P) |
| **Relay load** | Metadata events + frequent queries per page view | Lightweight NIP-94 + ephemeral signaling only |
| **Identity resolution** | NIP-05 (HTTP-based) | Namecoin (decentralized blockchain DNS) |
| **Infrastructure needed** | Relays + Blossom + Gateways | Relays only (signaling) |
| **Offline availability** | Depends on Blossom/gateway uptime | Depends on seeder being online |
| **Censorship resistance** | Gateway can be blocked, Blossom can be taken down | Any peer with the files can seed |
| **Seeder must be online?** | No (files on Blossom) | Yes (P2P requires at least one seeder) |

## The Trade-off

ZeroNet requires the seeder to be online for others to download. This is the fundamental trade-off: **no servers means no availability without peers**. However, this is also its greatest strength for censorship resistance — any user who downloads a website can re-seed it. If the original author is disconnected, unavailable, or arrested, the content lives on through its readers. There is no single server to take down, no hosting provider to pressure, no gateway to block.

## Future: WebTorrent

The current implementation creates a new WebRTC PeerConnection per file, per peer. This works for small websites but doesn't scale — there is no swarming, no parallel downloads from multiple seeders, and no piece-based integrity verification.

[WebTorrent](https://github.com/webtorrent/webtorrent) solves exactly this by combining the BitTorrent protocol with WebRTC transport. It enables:

- **Swarming**: download pieces of the same file from multiple seeders simultaneously
- **Piece verification**: SHA-1 hash checks per piece, ensuring integrity without trusting any single peer
- **Seeding while leeching**: a peer that has downloaded 50% of a file can already serve those pieces to others
- **Tracker-less discovery**: DHT and peer exchange allow finding seeders without a central tracker

A Dart port of WebTorrent would replace our current naive one-file-one-connection model with a proper torrent-based transfer layer. Combined with Nostr for metadata discovery (NIP-94 events could include torrent infohashes), this would bring the full BitTorrent swarm model to the Nostr ecosystem — completing the original ZeroNet vision with modern tooling.

## Tech Stack

- **Flutter** (cross-platform: macOS, iOS, Android)
- **flutter_bloc** for state management
- **flutter_webrtc** for WebRTC DataChannels
- **Nostr** (NIP-94 for file metadata, ephemeral events for WebRTC signaling)
- **Namecoin** (decentralized DNS for identity resolution via Electrum protocol)
- **webview_flutter** for rendering downloaded sites
