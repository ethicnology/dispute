import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:dispute/features/contact/presentation/contact_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({required this.state, super.key});
  final ContactLoaded state;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () =>
            context.read<ContactBloc>().add(const LoadMyContacts()),
      ),
      title: const Text('Chat'),
    ),
    body: Center(child: Text(state.selectedPubkey ?? '—')),
  );
}
