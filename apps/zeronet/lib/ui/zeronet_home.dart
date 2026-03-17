import 'package:flutter/material.dart';

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
          title: const Text('ZeroNet'),
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
