import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';

import '../application/create_account_use_case.dart';
import '../application/get_accounts_use_case.dart';
import '../domain/account_entity.dart';
import 'account_view.dart';
import 'relay_view.dart';
import 'wizard_event.dart';
import 'wizard_state.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  WizardBloc({
    required this.createAccountUseCase,
    required this.getAccountsUseCase,
  }) : super(const WizardLoading()) {
    on<WizardStarted>(_onWizardStarted);
    on<WizardNewAccountRequested>(_onWizardNewAccountRequested);
    on<KeysGenerateRequested>(_onKeysGenerateRequested);
    on<KeysImportRequested>(_onKeysImportRequested);
    on<RelaysSelected>(_onRelaysSelected);
    on<WizardSubmitted>(_onWizardSubmitted);
    on<WizardReset>(_onWizardReset);
    add(const WizardStarted());
  }

  final CreateAccountUseCase createAccountUseCase;
  final GetAccountsUseCase getAccountsUseCase;

  // Internal domain state — not exposed to UI
  Keys? _keys;

  Future<void> _onWizardStarted(
    WizardStarted event,
    Emitter<WizardState> emit,
  ) async {
    final accounts = await getAccountsUseCase.execute();
    if (accounts.isNotEmpty) {
      emit(WizardIdle(accounts: _toViews(accounts)));
    } else {
      emit(const WizardInProgress(step: WizardStep.keys));
    }
  }

  void _onWizardNewAccountRequested(
    WizardNewAccountRequested event,
    Emitter<WizardState> emit,
  ) {
    _keys = null;
    emit(const WizardInProgress(step: WizardStep.keys));
  }

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

      await createAccountUseCase.execute(
        account: AccountEntity(keys: _keys!, name: event.name, relays: relays),
      );

      final accounts = await getAccountsUseCase.execute();
      emit(WizardIdle(accounts: _toViews(accounts)));
    } on Exception catch (e) {
      emit(WizardError(message: e.toString()));
    }
  }

  List<AccountView> _toViews(List<AccountEntity> entities) => entities
      .map(
        (e) => AccountView(
          npub: e.npub,
          name: e.name,
          relays: e.relays
              .map((r) => RelayView(url: r.url, read: r.read, write: r.write))
              .toList(),
        ),
      )
      .toList();
}
