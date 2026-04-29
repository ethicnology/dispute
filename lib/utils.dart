import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/io.dart' as io_ws;
import 'package:web_socket_channel/web_socket_channel.dart';

void displaySnackBar(BuildContext context, String content) {
  var snackBar = SnackBar(
    content: Text(content),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// Shared resolver so all `.bit` lookups across the app share one
/// ElectrumX connection pool / cache.
final NamecoinRelayResolver _bitResolver = NamecoinRelayResolver(
  client: DefaultElectrumxClient(httpClient: _bitHttpClient()),
);

/// HTTP client used by the ElectrumX WebSocket handshake.
///
/// The default public Namecoin ElectrumX servers ship self-signed
/// certs today, so we accept them here for the lookup channel only.
/// This is **separate** from the relay connection's TLS, which is
/// pinned via TLSA records when the Namecoin record advertises them.
HttpClient? _bitHttpClient() {
  if (kIsWeb) return null; // web has no dart:io HttpClient
  final c = HttpClient();
  c.badCertificateCallback = (_, __, ___) => true;
  c.connectionTimeout = const Duration(seconds: 10);
  return c;
}

/// Connects to [relayUri], resolving `.bit` hostnames through the
/// Namecoin blockchain first.
///
/// For non-`.bit` URLs this is just a thin wrapper around
/// `WebSocketChannel.connect`. For `.bit` URLs:
///
///   1. Resolves through `NamecoinRelayResolver` (one ElectrumX call,
///      cached for an hour).
///   2. Uses the returned `clearnetUrl` for the actual handshake.
///   3. If the Namecoin record published TLSA pin records, layers a
///      `badCertificateCallback` that pins the relay's cert to one of
///      them (DANE-EE / DANE-TA matches accept without system trust;
///      PKIX-* matches require both).
///
/// Web (kIsWeb) targets skip TLSA pinning since `dart:io` is
/// unavailable; the browser does its own TLS validation.
Future<WebSocketChannel> connectRelay(Uri relayUri) async {
  final urlStr = relayUri.toString();
  final resolution = NamecoinRelayResolver.isBitUrl(urlStr)
      ? await _bitResolver.resolve(urlStr)
      : null;

  final wireUri = (resolution?.clearnetUrl != null)
      ? Uri.parse(resolution!.clearnetUrl!)
      : relayUri;

  if (kIsWeb) {
    // Web: no platform TLS hooks; defer to the browser.
    return WebSocketChannel.connect(wireUri);
  }

  final tlsa = resolution?.tlsaRecords ?? const <TlsaRecord>[];
  if (tlsa.isEmpty) {
    return io_ws.IOWebSocketChannel.connect(wireUri);
  }

  // Pin the handshake to one of the published TLSA records.
  final httpClient = HttpClient();
  httpClient.badCertificateCallback = (cert, host, port) {
    return tlsa.any((t) => t.matchesCertificate(cert.der));
  };
  httpClient.connectionTimeout = const Duration(seconds: 15);
  return io_ws.IOWebSocketChannel.connect(
    wireUri,
    customClient: httpClient,
  );
}
