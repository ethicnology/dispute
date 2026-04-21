import 'package:dispute/features/contact/contact.dart';
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
    final contactPort = DriftContactAdapter(_disputeDb);

    return BlocProvider(
      create: (_) => WizardBloc(
        createAccountUseCase: CreateAccountUseCase(accountPort: accountPort),
        getAccountsUseCase: GetAccountsUseCase(accountPort: accountPort),
      ),
      child: _DisputeHome(contactPort: contactPort),
    );
  }
}

class _DisputeHome extends StatefulWidget {
  const _DisputeHome({required this.contactPort});

  final ContactPort contactPort;

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
        children: [
          const WizardPage(),
          ContactWidget(port: widget.contactPort),
        ],
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
