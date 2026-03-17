import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:plugin_interface/plugin_interface.dart';
import 'package:wizard/wizard.dart';

import 'features/leech/leech.dart';
import 'features/seed/seed.dart';
import 'ui/zeronet_home.dart';

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
    final storage = DriftAccountStorage(_db);
    final accountPort = NostrAccountAdapter(storage);
    final seedPort = const NostrSeedAdapter();
    final discoveryPort = const NostrDiscoveryAdapter();
    final downloadPort = WebRtcDownloadAdapter(accountStorage: storage);

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
          create: (_) => SeedBloc(
            seedFileUseCase: SeedFileUseCase(seedPort: seedPort),
            listSeedingUseCase: ListSeedingUseCase(seedPort: seedPort),
            accountStorage: storage,
          ),
        ),
        BlocProvider(
          create: (_) => LeechBloc(
            searchFilesUseCase: SearchFilesUseCase(
              discoveryPort: discoveryPort,
            ),
            downloadFileUseCase: DownloadFileUseCase(
              downloadPort: downloadPort,
            ),
            accountStorage: storage,
          ),
        ),
      ],
      child: BlocBuilder<WizardBloc, Object?>(
        builder: (context, state) {
          if (state is WizardIdle) return const ZeroNetHome();
          return const WizardPage();
        },
      ),
    );
  }
}
