import 'account_view.dart';
import 'relay_view.dart';

enum WizardStep { keys, relays, profile }

sealed class WizardState {
  const WizardState();
}

class WizardInProgress extends WizardState {
  const WizardInProgress({
    required this.step,
    this.npub,
    this.relays = const [],
  });

  final WizardStep step;
  final String? npub;
  final List<RelayView> relays;
}

class WizardCompleted extends WizardState {
  const WizardCompleted({required this.account});
  final AccountView account;
}

class WizardError extends WizardState {
  const WizardError({required this.message});
  final String message;
}
