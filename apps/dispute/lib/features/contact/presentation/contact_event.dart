import 'package:dispute/features/contact/domain/contact_entity.dart';

sealed class ContactEvent {
  const ContactEvent();
}

/// User search for a new contact via identifier
class SearchContact extends ContactEvent {
  const SearchContact({required this.identifier});
  final String identifier;
}

/// User presses "Add to my list" for the found contact
final class AddContact extends ContactEvent {
  final ContactEntity contact;
  const AddContact(this.contact);
}

/// Load "my list" screen
final class LoadMyContacts extends ContactEvent {
  const LoadMyContacts();
}

/// User select a person from the list by name
final class FetchMyContactsByName extends ContactEvent {
  final String name;
  const FetchMyContactsByName(this.name);
}

/// User select a person from the list by pubkey
final class FetchMyContactsByPubkey extends ContactEvent {
  final String pubkey;
  const FetchMyContactsByPubkey(this.pubkey);
}

/// User selects a person from the list (open chat)
final class SelectContact extends ContactEvent {
  final String pubkey;
  const SelectContact(this.pubkey);
}

/// Remove person from list
final class RemoveContact extends ContactEvent {
  final String pubkey;
  const RemoveContact(this.pubkey);
}
