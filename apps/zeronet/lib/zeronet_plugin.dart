import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
import 'package:wizard/wizard.dart';

import 'features/website/website.dart';

class ZeronetPlugin extends AppPlugin {
  ZeronetPlugin({NostrDatabase? db}) : _injectedDb = db;

  final NostrDatabase? _injectedDb;
  late final NostrDatabase _db;

  @override
  String get id => 'zeronet';

  @override
  String get name => 'ZeroNet';

  @override
  IconData get icon => Icons.language;

  @override
  Future<void> initialize() async {
    _db = _injectedDb ?? await NostrDatabase.open('tmp_hardcoded_key');
  }

  @override
  Widget buildHome(BuildContext context) {
    final accountPort = NostrAccountAdapter(DriftAccountStorage(_db));
    final websitePort = const AssetWebsiteAdapter();
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
          create: (_) => WebsiteBloc(
            loadWebsiteUseCase: LoadWebsiteUseCase(websitePort: websitePort),
          ),
        ),
      ],
      child: BlocBuilder<WizardBloc, Object?>(
        builder: (context, state) {
          if (state is WizardIdle) return const WebsitePage();
          return const WizardPage();
        },
      ),
    );
  }
}
