import 'package:dispute/features/contact/application/use_cases/add_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_all_my_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_contact_by_name_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_contact_by_pubkey_use_case.dart';
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
    required this.fetchContactByNameUseCase,
    required this.fetchContactByPubkeyUseCase,
    required this.removeContactUseCase,
  }) : super(const ContactLoading()) {
    on<SearchContact>(_onSearchContact);
    on<AddContact>(_onAddContact);
    on<LoadMyContacts>(_onLoadMyContacts);
    on<FetchMyContactsByName>(_onFetchMyContactsByName);
    on<FetchMyContactsByPubkey>(_onFetchMyContactsByPubkey);
    on<SelectContact>(_onSelectContact);
    on<RemoveContact>(_onRemoveContact);
  }

  final SearchContactUseCase searchContactUseCase;
  final AddContactUseCase addContactUseCase;
  final FetchAllMyContactsUseCase fetchAllMyContactsUseCase;
  final FetchContactByNameUseCase fetchContactByNameUseCase;
  final FetchContactByPubkeyUseCase fetchContactByPubkeyUseCase;
  final RemoveContactUseCase removeContactUseCase;

  Future<void> _onSearchContact(
    SearchContact event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      final found = await searchContactUseCase.execute(event.identifier);
      final current = state is ContactLoaded ? state as ContactLoaded : null;
      emit(
        ContactLoaded(
          screen: ContactScreen.search,
          input: event.identifier,
          foundContact: found,
          myContacts: current?.myContacts ?? const [],
          selectedPubkey: current?.selectedPubkey,
        ),
      );
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

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

  Future<void> _onFetchMyContactsByName(
    FetchMyContactsByName event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      final list = await fetchContactByNameUseCase.execute(event.name);
      emit(
        ContactLoaded(
          screen: ContactScreen.myList,
          input: event.name,
          myContacts: list,
        ),
      );
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
  }

  Future<void> _onFetchMyContactsByPubkey(
    FetchMyContactsByPubkey event,
    Emitter<ContactState> emit,
  ) async {
    emit(const ContactLoading());
    try {
      final list = await fetchContactByPubkeyUseCase.execute(event.pubkey);
      emit(
        ContactLoaded(
          screen: ContactScreen.myList,
          input: event.pubkey,
          myContacts: list,
        ),
      );
    } on Exception catch (e) {
      emit(ContactError(message: e.toString()));
    }
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
