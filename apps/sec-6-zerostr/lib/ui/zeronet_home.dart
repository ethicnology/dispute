import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wizard/wizard.dart';

import '../features/leech/ui/leech_page.dart';
import '../features/seed/ui/seed_page.dart';

class ZeroNetHome extends StatelessWidget {
  const ZeroNetHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<WizardBloc, Object?>(
            builder: (context, state) {
              if (state is WizardIdle && state.accounts.isNotEmpty) {
                final account = state.accounts.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.name),
                    SelectableText(
                      account.npub,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }
              return const Text('ZeroNet');
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.upload), text: 'Seed'),
              Tab(icon: Icon(Icons.download), text: 'Leech'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SeedPage(),
            LeechPage(),
          ],
        ),
      ),
    );
  }
}
