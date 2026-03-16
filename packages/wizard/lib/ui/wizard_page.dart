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
    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: BlocBuilder<WizardBloc, WizardState>(
        builder: (context, state) {
          return switch (state) {
            WizardInProgress(:final step) => Stepper(
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
            WizardCompleted() => const Center(
                child: Text('Account created!'),
              ),
            WizardError(:final message) => Center(
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
          };
        },
      ),
    );
  }
}
