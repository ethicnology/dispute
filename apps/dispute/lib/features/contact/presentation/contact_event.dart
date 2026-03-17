import 'package:dispute/features/contact/domain/contact_entity.dart';

sealed class ContactEvent {
  const ContactEvent();
}

/// User presses "Add to my list" for the found contact
final class AddContact extends ContactEvent {
  final ContactEntity contact;
  const AddContact(this.contact);
}

/// Load "my list" screen (no filter)
final class LoadMyContacts extends ContactEvent {
  const LoadMyContacts();
}

/// Trigger a search while staying on the myList screen
final class SearchContact extends ContactEvent {
  const SearchContact({required this.identifier});
  final String identifier;
}

/// User filter contacts
final class FilterContacts extends ContactEvent {
  const FilterContacts(this.query);
  final String query;
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
