import 'package:dispute/features/contact/domain/contact_entity.dart';

enum ContactScreen { search, myList, chat }

sealed class ContactState {
  const ContactState();
}

class ContactLoaded extends ContactState {
  const ContactLoaded({
    required this.screen,
    this.input = '',
    this.foundContact,
    this.myContacts = const [],
    this.selectedPubkey,
  });

  /// Which screen the UI is showing
  final ContactScreen screen;

  /// Text user typed (nip05 / name / pubkey)
  final String input;

  /// Result of NIP-05 search (single contact)
  final ContactEntity? foundContact;

  /// Saved contacts list
  final List<ContactEntity> myContacts;

  /// Currently selected contact (for chat/details)
  final String? selectedPubkey;
}

/// Loading state (searching nip05, loading list, adding/removing contact, etc.)
class ContactLoading extends ContactState {
  const ContactLoading();
}

/// Error state
class ContactError extends ContactState {
  const ContactError({required this.message});
  final String message;
}
