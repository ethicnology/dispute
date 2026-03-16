class Nip05Id {
  final String name;
  final String domain;

  const Nip05Id({required this.name, required this.domain});

  String get identifier => '$name@$domain';
}

class ContactEntity {
  final String? name;
  final String pubkey;
  final Nip05Id? nip05; // from DnsIdentifier.parse(event)
  final List<Uri> relays;

  const ContactEntity({
    this.name,
    required this.pubkey,
    this.nip05,
    this.relays = const [],
  });
}
