import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';

import '../application/create_account_use_case.dart';
import '../domain/account_entity.dart';
import 'account_view.dart';
import 'wizard_event.dart';
import 'wizard_state.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  WizardBloc({required this.createAccountUseCase})
    : super(const WizardInProgress(step: WizardStep.keys)) {
    on<KeysGenerateRequested>(_onKeysGenerateRequested);
    on<KeysImportRequested>(_onKeysImportRequested);
    on<RelaysSelected>(_onRelaysSelected);
    on<WizardSubmitted>(_onWizardSubmitted);
    on<WizardReset>(_onWizardReset);
  }

  final CreateAccountUseCase createAccountUseCase;

  // Internal domain state — not exposed to UI
  Keys? _keys;

  void _onKeysGenerateRequested(
    KeysGenerateRequested event,
    Emitter<WizardState> emit,
  ) {
    _keys = Keys.generate();
    emit(WizardInProgress(step: WizardStep.relays, npub: _keys!.public));
  }

  void _onKeysImportRequested(
    KeysImportRequested event,
    Emitter<WizardState> emit,
  ) {
    try {
      _keys = Keys(event.nsec);
      emit(WizardInProgress(step: WizardStep.relays, npub: _keys!.public));
    } on Exception catch (e) {
      emit(WizardError(message: e.toString()));
    }
  }

  void _onRelaysSelected(RelaysSelected event, Emitter<WizardState> emit) {
    final current = state;
    if (current is! WizardInProgress) return;
    emit(
      WizardInProgress(
        step: WizardStep.profile,
        npub: current.npub,
        relays: event.relays,
      ),
    );
  }

  void _onWizardReset(WizardReset event, Emitter<WizardState> emit) {
    _keys = null;
    emit(const WizardInProgress(step: WizardStep.keys));
  }

  Future<void> _onWizardSubmitted(
    WizardSubmitted event,
    Emitter<WizardState> emit,
  ) async {
    final current = state;
    if (current is! WizardInProgress || _keys == null) return;

    try {
      final relays = current.relays
          .map((rv) => RelayEntity(url: rv.url, read: rv.read, write: rv.write))
          .toList();

      final account = AccountEntity(
        keys: _keys!,
        name: event.name,
        relays: relays,
      );

      await createAccountUseCase.execute(account: account);

      emit(
        WizardCompleted(
          account: AccountView(
            npub: account.npub,
            name: account.name,
            relays: current.relays,
          ),
        ),
      );
    } on Exception catch (e) {
      emit(WizardError(message: e.toString()));
    }
  }
}
