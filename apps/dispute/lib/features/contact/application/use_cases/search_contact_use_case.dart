import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class SearchContactUseCase {
  const SearchContactUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<ContactEntity?> execute(String identifier) =>
      contactPort.search(identifier);
}
