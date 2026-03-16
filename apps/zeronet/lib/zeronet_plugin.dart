import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
import 'package:wizard/wizard.dart';

class ZeronetPlugin extends AppPlugin {
  late NostrDatabase _db;

  @override
  String get id => 'zeronet';

  @override
  String get name => 'ZeroNet';

  @override
  IconData get icon => Icons.language;

  @override
  Future<void> initialize() async {
    _db = await NostrDatabase.open('zeronet_key');
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
