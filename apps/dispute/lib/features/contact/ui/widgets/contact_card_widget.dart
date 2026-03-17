import 'package:dispute/features/contact/domain/contact_entity.dart';
import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactCardWidget extends StatelessWidget {
  const ContactCardWidget({required this.contact, super.key});
  final ContactEntity contact;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContactBloc>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.name != null) Text(contact.name!),
            if (contact.nip05 != null) Text(contact.nip05!.identifier),
            const SizedBox(height: 8),
            Text(contact.pubkey, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add to my contacts'),
              onPressed: () => bloc.add(AddContact(contact)),
            ),
          ],
        ),
      ),
    );
  }
}
