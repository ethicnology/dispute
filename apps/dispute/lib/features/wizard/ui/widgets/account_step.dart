import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/wizard_bloc.dart';
import '../../presentation/wizard_event.dart';
import '../validators.dart';

class AccountStep extends StatefulWidget {
  const AccountStep({super.key});

  @override
  State<AccountStep> createState() => _AccountStepState();
}

class _AccountStepState extends State<AccountStep> {
  final _formKey = GlobalKey<FormState>();
  final _nsecController = TextEditingController();

  @override
  void dispose() {
    _nsecController.dispose();
    super.dispose();
  }

  void _importNsec() {
    if (!_formKey.currentState!.validate()) return;
    context.read<WizardBloc>().add(
          KeysImportRequested(nsec: _nsecController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () {
              context.read<WizardBloc>().add(const KeysGenerateRequested());
            },
            child: const Text('Generate new keys'),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nsecController,
            decoration: const InputDecoration(
              labelText: 'Import nsec',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: Validators.nsec,
            onFieldSubmitted: (_) => _importNsec(),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _importNsec,
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
