import 'package:nostr_wrapper/nostr.dart';

class AccountEntity {
  final Keys keys;
  final String name;
  final List<RelayEntity> relays;

  String get npub => keys.npub;
  String get nsec => keys.nsec;

  const AccountEntity({
    required this.keys,
    required this.name,
    required this.relays,
  });

  factory AccountEntity.generate({
    required String name,
    required List<RelayEntity> relays,
  }) {
    return AccountEntity(keys: Keys.generate(), name: name, relays: relays);
  }
}

class RelayEntity {
  final Uri url;
  final bool read;
  final bool write;

  const RelayEntity({
    required this.url,
    required this.read,
    required this.write,
  });
}
