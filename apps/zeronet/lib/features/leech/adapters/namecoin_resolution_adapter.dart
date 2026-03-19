import 'dart:convert';

import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:namecoin/namecoin.dart';

class NamecoinResolutionAdapter {
  static const _host = 'namecoin.stackwallet.com';
  static const _port = 57002;

  Future<String> resolve(String name) async {
    print('[namecoin] resolving "$name"');
    final client = await ElectrumClient.connect(host: _host, port: _port);
    await client.request('server.version', ['zeronet', '1.4']);
    try {
      final scriptHash = nameIdentifierToScriptHash(name);
      print('[namecoin] scriptHash for "$name": $scriptHash');
      final historyRaw = (await client.request(
        'blockchain.scripthash.get_history',
        [scriptHash],
      )) as List<dynamic>;
      if (historyRaw.isEmpty) throw Exception('Namecoin name not found: $name');
      final latest = historyRaw.last as Map<String, dynamic>;
      final txData = Map<String, dynamic>.from(
        (await client.request('blockchain.transaction.get', [latest['tx_hash'] as String, true])) as Map,
      );
      final nameData = OpNameData.fromTx(txData, latest['height'] as int);
      final value = nameData.value.trim();
      print('[namecoin] "$name" → $value');
      final map = jsonDecode(value) as Map<String, dynamic>;
      final nostrField = map['nostr'];
      // Format A: {"nostr":"hexPubkey",...}
      if (nostrField is String) return nostrField;
      // Format B: {"nostr":{"names":{"bob":"hexPubkey",...},...}}
      if (nostrField is Map) {
        final names = nostrField['names'] as Map<String, dynamic>?;
        if (names != null && names.isNotEmpty) {
          return names.values.first as String;
        }
      }
      throw Exception('Cannot extract pubkey from Namecoin value: $value');
    } finally {
      await client.close();
    }
  }
}
