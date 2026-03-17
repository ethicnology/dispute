import 'package:dispute/features/contact/adapters/drift_contact_adapter.dart';
import 'package:dispute/features/contact/application/use_cases/add_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_all_my_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/fetch_contacts_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/remove_contact_use_case.dart';
import 'package:dispute/features/contact/application/use_cases/search_contact_use_case.dart';
import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:dispute/features/contact/ui/contact_page.dart';
import 'package:dispute/shared/storage/drift_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
import 'package:wizard/wizard.dart';

class DisputePlugin extends AppPlugin {
  late NostrDatabase _nostrDb;
  late DisputeDatabase _disputeDb;

  @override
  String get id => 'dispute';

  @override
  String get name => 'Dispute';

  @override
  IconData get icon => Icons.chat;

  @override
  Future<void> initialize() async {
    _nostrDb = await NostrDatabase.open('tmp_hardcoded_key');
    _disputeDb = await DisputeDatabase.open('tmp_hardcoded_key');
  }

  @override
  Widget buildHome(BuildContext context) {
    final accountPort = NostrAccountAdapter(DriftAccountStorage(_nostrDb));
    final contactAdapter = DriftContactAdapter(_disputeDb);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WizardBloc(
            createAccountUseCase: CreateAccountUseCase(
              accountPort: accountPort,
            ),
            getAccountsUseCase: GetAccountsUseCase(accountPort: accountPort),
          ),
        ),
        BlocProvider(
          create: (_) => ContactBloc(
            searchContactUseCase: SearchContactUseCase(
              contactPort: contactAdapter,
            ),
            addContactUseCase: AddContactUseCase(contactPort: contactAdapter),
            fetchAllMyContactsUseCase: FetchAllMyContactsUseCase(
              contactPort: contactAdapter,
            ),
            fetchContactsUseCase: FetchContactsUseCase(
              contactPort: contactAdapter,
            ),
            removeContactUseCase: RemoveContactUseCase(
              contactPort: contactAdapter,
            ),
          )..add(const LoadMyContacts()),
        ),
      ],
      child: const _DisputeHome(),
    );
  }
}

class _DisputeHome extends StatefulWidget {
  const _DisputeHome();

  @override
  State<_DisputeHome> createState() => _DisputeHomeState();
}

class _DisputeHomeState extends State<_DisputeHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [WizardPage(), ContactPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contacts',
          ),
        ],
      ),
    );
  }
}
