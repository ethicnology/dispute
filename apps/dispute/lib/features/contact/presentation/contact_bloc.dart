import 'package:dispute/features/contact/application/use_cases/add_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_all_my_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/remove_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/search_contact_use_case.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:dispute/features/contact/presentation/contact_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  ContactBloc({
    required this.searchContactUseCase,
    required this.addContactUseCase,
    required this.fetchAllMyContactsUseCase,
    required this.fetchContactsUseCase,
    required this.removeContactUseCase,
  }) : super(const ContactLoading()) {
    on<AddContact>(_onAddContact);
    on<LoadMyContacts>(_onLoadMyContacts);
    on<SearchContact>(_onSearchContact);
    on<FilterContacts>(_onFilterContacts);
    on<SelectContact>(_onSelectContact);
    on<RemoveContact>(_onRemoveContact);
  }

  final SearchContactUseCase searchContactUseCase;
  final AddContactUseCase addContactUseCase;
  final FetchAllMyContactsUseCase fetchAllMyContactsUseCase;
  final FetchContactsUseCase fetchContactsUseCase;
  final RemoveContactUseCase removeContactUseCase;

  Future<void> _onAddContact(
    AddContact event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      await addContactUseCase.execute(event.contact);
      final list = await fetchAllMyContactsUseCase.execute();
      emit(ContactLoaded(screen: ContactScreen.myList, myContacts: list));
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

  Future<void> _onLoadMyContacts(
    LoadMyContacts event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      final list = await fetchAllMyContactsUseCase.execute();
      emit(ContactLoaded(screen: ContactScreen.myList, myContacts: list));
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

  Future<void> _onSearchContact(
    SearchContact event,
    Emitter<ContactState> emit,
  ) async {
    final current = state is ContactLoaded ? state as ContactLoaded : null;
    try {
      final found = await searchContactUseCase.execute(event.identifier);
      emit(
        ContactLoaded(
          screen: ContactScreen.myList,
          input: event.identifier,
          foundContact: found,
          myContacts: current?.myContacts ?? const [],
          selectedPubkey: current?.selectedPubkey,
          showSearchButton: found == null,
        ),
      );
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

  Future<void> _onFilterContacts(
    FilterContacts event,
    Emitter<ContactState> emit,
  ) async {
    final current = state is ContactLoaded ? state as ContactLoaded : null;
    final text = event.query.trim();
    try {
      final list = await fetchContactsUseCase.execute(query: text);
      final shouldShowSearchButton = list.isEmpty && _looksLikeNip05(text);
      emit(
        ContactLoaded(
          screen: ContactScreen.myList,
          input: event.query,
          myContacts: list,
          selectedPubkey: current?.selectedPubkey,
          showSearchButton: shouldShowSearchButton,
        ),
      );
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

  bool _looksLikeNip05(String text) {
    final parts = text.split('@');
    return parts.length == 2 && parts[0].isNotEmpty && parts[1].isNotEmpty;
  }

  void _onSelectContact(SelectContact event, Emitter<ContactState> emit) {
    if (state is! ContactLoaded) return;
    final current = state as ContactLoaded;
    emit(
      ContactLoaded(
        screen: ContactScreen.chat,
        input: current.input,
        foundContact: current.foundContact,
        myContacts: current.myContacts,
        selectedPubkey: event.pubkey,
      ),
    );
  }

  Future<void> _onRemoveContact(
    RemoveContact event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      await removeContactUseCase.execute(event.pubkey);
      final list = await fetchAllMyContactsUseCase.execute();
      emit(ContactLoaded(screen: ContactScreen.myList, myContacts: list));
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }
}
