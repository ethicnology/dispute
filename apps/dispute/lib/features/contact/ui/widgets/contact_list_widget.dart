import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:dispute/features/contact/presentation/contact_state.dart';
import 'package:dispute/features/contact/ui/widgets/contact_card_widget.dart';
import 'package:dispute/features/contact/ui/widgets/contact_search_field.dart';
import 'package:dispute/features/contact/ui/widgets/contact_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListWidget extends StatefulWidget {
  const ListWidget({required this.state, super.key});
  final ContactLoaded state;

  @override
  State<ListWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.input);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContactBloc>();
    final contacts = widget.state.myContacts;
    final showSearch = widget.state.showSearchButton;
    final foundContact = widget.state.foundContact;

    return Scaffold(
      appBar: AppBar(title: const Text('My contacts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ContactSearchField(
              controller: _controller,
              label: 'Filter by name or pubkey',
              onSubmitted: (v) => bloc.add(FilterContacts(v)),
              onChanged: (v) => bloc.add(FilterContacts(v)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  bloc.add(const LoadMyContacts());
                },
              ),
            ),
          ),
          Expanded(
            child: contacts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (foundContact != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ContactCardWidget(contact: foundContact),
                          ),
                        ] else ...[
                          const Text('No contacts found.'),
                          if (showSearch) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.search),
                              label: const Text('Search'),
                              onPressed: () => bloc.add(
                                SearchContact(
                                  identifier: widget.state.input.trim(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (_, i) =>
                        ContactTileWidget(contact: contacts[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
