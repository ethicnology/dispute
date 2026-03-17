import 'package:dispute/features/contact/domain/contact_entity.dart';
import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactTileWidget extends StatelessWidget {
  const ContactTileWidget({required this.contact, super.key});
  final ContactEntity contact;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ContactBloc>();
    return ListTile(
      title: Text(contact.name ?? contact.pubkey),
      subtitle: contact.nip05 != null ? Text(contact.nip05!.identifier) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.send_sharp),
            onPressed: () => bloc.add(SelectContact(contact.pubkey)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => bloc.add(RemoveContact(contact.pubkey)),
          ),
        ],
      ),
    );
  }
}
