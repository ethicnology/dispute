import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
import 'package:wizard/wizard.dart';

class DisputePlugin extends AppPlugin {
  DisputePlugin({NostrDatabase? db}) : _injectedDb = db;

  final NostrDatabase? _injectedDb;
  late final NostrDatabase _db;

  @override
  String get id => 'dispute';

  @override
  String get name => 'Dispute';

  @override
  IconData get icon => Icons.chat;

  @override
  Future<void> initialize() async {
    _db = _injectedDb ?? await NostrDatabase.open('tmp_hardcoded_key');
  }

  @override
  Widget buildHome(BuildContext context) {
    final accountPort = NostrAccountAdapter(DriftAccountStorage(_db));
    return BlocProvider(
      create: (_) => WizardBloc(
        createAccountUseCase: CreateAccountUseCase(accountPort: accountPort),
        getAccountsUseCase: GetAccountsUseCase(accountPort: accountPort),
      ),
      child: const WizardPage(),
    );
  }
}
