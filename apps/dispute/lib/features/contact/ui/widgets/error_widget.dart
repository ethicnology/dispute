import 'package:dispute/features/contact/presentation/contact_bloc.dart';
import 'package:dispute/features/contact/presentation/contact_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Error: $message'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () =>
                context.read<ContactBloc>().add(const LoadMyContacts()),
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
