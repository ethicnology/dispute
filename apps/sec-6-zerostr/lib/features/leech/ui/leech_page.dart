import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/leech_bloc.dart';
import '../presentation/leech_event.dart';
import '../presentation/leech_state.dart';
import 'website_page.dart';

class LeechPage extends StatefulWidget {
  const LeechPage({super.key});

  @override
  State<LeechPage> createState() => _LeechPageState();
}

class _LeechPageState extends State<LeechPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final npub = _controller.text.trim();
    if (npub.isEmpty) return;
    context.read<LeechBloc>().add(LeechSearchRequested(npub: npub));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'npub or Namecoin name (e.g. alice, nostr/bob)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),
        ),
        Expanded(
          child: BlocBuilder<LeechBloc, LeechState>(
            builder: (context, state) => switch (state) {
              LeechIdle(:final downloaded) => downloaded.isEmpty
                  ? const Center(child: Text('Search for an npub to discover websites'))
                  : ListView(
                      children: [
                        for (final file in downloaded)
                          ListTile(
                            title: Text(file.title),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebsitePage(site: file),
                              ),
                            ),
                          ),
                      ],
                    ),
              LeechSearching() => const Center(child: CircularProgressIndicator()),
              LeechSearchResults(:final results) => results.isEmpty
                  ? const Center(child: Text('No files found for this npub'))
                  : ListView(
                      children: [
                        for (final file in results)
                          ListTile(
                            title: Text(file.name),
                            subtitle: Text('${file.mimeType} — ${file.size} bytes'),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () => context
                                  .read<LeechBloc>()
                                  .add(LeechDownloadRequested(file: file)),
                            ),
                          ),
                      ],
                    ),
              LeechDownloading() => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Downloading...'),
                    ],
                  ),
                ),
              LeechError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText('Error: $message', textAlign: TextAlign.center),
                  ),
                ),
            },
          ),
        ),
      ],
    );
  }
}
