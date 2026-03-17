import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_state.dart';
import 'package:dispute/features/contact/ui/widgets/chat_widget.dart';
import 'package:dispute/features/contact/ui/widgets/error_widget.dart';
import 'package:dispute/features/contact/ui/widgets/contact_list_widget.dart';
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) => switch (state) {
        ContactLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        ContactError(:final message) => ErrorWidget(message: message),
        ContactLoaded(:final screen) => switch (screen) {
          ContactScreen.myList => ListWidget(state: state),
          ContactScreen.chat => ChatWidget(state: state),
        },
      },
    );
  }
}
