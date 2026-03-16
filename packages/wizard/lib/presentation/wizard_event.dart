import 'relay_view.dart';

sealed class WizardEvent {
  const WizardEvent();
}

/// Step 1: user generates new keys
class KeysGenerateRequested extends WizardEvent {
  const KeysGenerateRequested();
}

/// Step 1: user imports existing keys via nsec
class KeysImportRequested extends WizardEvent {
  const KeysImportRequested({required this.nsec});
  final String nsec;
}

/// Step 2: user selects relay URLs
class RelaysSelected extends WizardEvent {
  const RelaysSelected({required this.relays});
  final List<RelayView> relays;
}

/// Step 3: user sets name and submits
class WizardSubmitted extends WizardEvent {
  const WizardSubmitted({required this.name});
  final String name;
}

/// Reset the wizard back to step 1
class WizardReset extends WizardEvent {
  const WizardReset();
}

/// Dispatched automatically on BLoC init to check for existing accounts
class WizardStarted extends WizardEvent {
  const WizardStarted();
}

/// User requests adding a new account from the idle screen
class WizardNewAccountRequested extends WizardEvent {
  const WizardNewAccountRequested();
}
