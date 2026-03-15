import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';

import 'features/wizard/adapters/nostr_account_adapter.dart';
import 'features/wizard/application/create_account_use_case.dart';
import 'features/wizard/presentation/wizard_bloc.dart';
import 'features/wizard/ui/wizard_page.dart';

class DisputePlugin extends AppPlugin {
  late NostrDatabase _db;

  @override
  String get id => 'dispute';

  @override
  String get name => 'Dispute';

  @override
  IconData get icon => Icons.chat;

  @override
  Future<void> initialize() async {
    _db = await NostrDatabase.open('tmp_hardcoded_key');
  }

  @override
  Widget buildHome(BuildContext context) {
    return BlocProvider(
      create: (_) => WizardBloc(
        createAccountUseCase: CreateAccountUseCase(
          accountPort: NostrAccountAdapter(DriftAccountStorage(_db)),
        ),
      ),
      child: const WizardPage(),
    );
  }
}
