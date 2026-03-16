import 'account_view.dart';
import 'relay_view.dart'; // used by WizardInProgress

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

class WizardLoading extends WizardState {
  const WizardLoading();
}

class WizardIdle extends WizardState {
  const WizardIdle({required this.accounts});
  final List<AccountView> accounts;
}

class WizardError extends WizardState {
  const WizardError({required this.message});
  final String message;
}
