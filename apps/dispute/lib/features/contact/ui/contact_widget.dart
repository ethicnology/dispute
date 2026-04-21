import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/application/use_cases/add_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_all_my_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/remove_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/search_contact_use_case.dart';
import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:dispute/features/contact/presentation/contact_state.dart';
import 'package:dispute/features/contact/ui/widgets/chat_widget.dart';
import 'package:dispute/features/contact/ui/widgets/contact_list_widget.dart';
import 'package:dispute/features/contact/ui/widgets/error_widget.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactWidget extends StatelessWidget {
  const ContactWidget({required this.port, super.key});

  final ContactPort port;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ContactBloc(
        searchContactUseCase: SearchContactUseCase(contactPort: port),
        addContactUseCase: AddContactUseCase(contactPort: port),
        fetchAllMyContactsUseCase: FetchAllMyContactsUseCase(contactPort: port),
        fetchContactsUseCase: FetchContactsUseCase(contactPort: port),
        removeContactUseCase: RemoveContactUseCase(contactPort: port),
      )..add(const LoadMyContacts()),
      child: BlocBuilder<ContactBloc, ContactState>(
        builder: (context, state) => switch (state) {
          ContactLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          ContactError(:final message) => ErrorWidget(message: message),
          ContactLoaded(:final screen) => switch (screen) {
            ContactScreen.myList => ListWidget(state: state),
            ContactScreen.chat => ChatWidget(state: state),
          },
        },
      ),
    );
  }
}
