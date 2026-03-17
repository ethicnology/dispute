import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/wizard_bloc.dart';
import '../presentation/wizard_event.dart';
import '../presentation/wizard_state.dart';
import 'widgets/account_step.dart';
import 'widgets/profile_step.dart';
import 'widgets/relays_step.dart';

class WizardPage extends StatelessWidget {
  const WizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WizardBloc, WizardState>(
      builder: (context, state) {
        return switch (state) {
          WizardLoading() => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          WizardIdle(:final accounts) => Scaffold(
              appBar: AppBar(
                title: const Text('Accounts'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Add account',
                    onPressed: () => context
                        .read<WizardBloc>()
                        .add(const WizardNewAccountRequested()),
                  ),
                ],
              ),
              body: ListView(
                children: [
                  for (final a in accounts)
                    ListTile(
                      title: Text(a.name),
                      subtitle: SelectableText(a.npub),
                    ),
                ],
              ),
            ),
          WizardInProgress(:final step) => Scaffold(
              appBar: AppBar(title: const Text('Setup')),
              body: Stepper(
                currentStep: step.index,
                controlsBuilder: (context, details) => const SizedBox.shrink(),
                steps: [
                  Step(
                    title: const Text('Keys'),
                    content: const AccountStep(),
                    isActive: step == WizardStep.keys,
                    state: step.index > WizardStep.keys.index
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Relays'),
                    content: const RelaysStep(),
                    isActive: step == WizardStep.relays,
                    state: step.index > WizardStep.relays.index
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Profile'),
                    content: const ProfileStep(),
                    isActive: step == WizardStep.profile,
                  ),
                ],
              ),
            ),
          WizardError(:final message) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $message'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<WizardBloc>()
                          .add(const WizardReset()),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
        };
      },
    );
  }
}
