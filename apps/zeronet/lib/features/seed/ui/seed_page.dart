import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/seed_bloc.dart';
import '../presentation/seed_event.dart';
import '../presentation/seed_state.dart';

class SeedPage extends StatelessWidget {
  const SeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SeedBloc, SeedState>(
      builder: (context, state) => switch (state) {
        SeedLoading() => const Center(child: CircularProgressIndicator()),
        SeedPublishing() => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Publishing to relays...'),
              ],
            ),
          ),
        SeedIdle(:final files) => Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['html'],
                );
                if (result != null && context.mounted) {
                  context
                      .read<SeedBloc>()
                      .add(SeedFileRequested(filePath: result.files.single.path!));
                }
              },
            ),
            body: files.isEmpty
                ? const Center(child: Text('No files seeded yet'))
                : ListView(
                    children: [
                      for (final file in files)
                        ListTile(
                          leading: const Icon(Icons.upload),
                          title: Text(file.name),
                          subtitle: Text('${file.size} bytes'),
                          trailing: const Chip(label: Text('seeding')),
                        ),
                    ],
                  ),
          ),
        SeedError(:final message) => Center(child: Text('Error: $message')),
      },
    );
  }
}
