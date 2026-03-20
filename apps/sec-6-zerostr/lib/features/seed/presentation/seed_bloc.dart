import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';

import '../../transfer/transfer.dart';
import '../application/list_seeding_use_case.dart';
import '../application/seed_file_use_case.dart';
import 'seed_event.dart';
import 'seed_state.dart';

class SeedBloc extends Bloc<SeedEvent, SeedState> {
  SeedBloc({
    required this.seedFileUseCase,
    required this.listSeedingUseCase,
    required this.accountStorage,
  }) : super(const SeedLoading()) {
    on<SeedListRequested>(_onListRequested);
    on<SeedFileRequested>(_onFileRequested);
    add(const SeedListRequested());
  }

  final SeedFileUseCase seedFileUseCase;
  final ListSeedingUseCase listSeedingUseCase;
  final AccountStoragePort accountStorage;
  WebRtcSeeder? _seeder;

  Future<void> _onListRequested(
    SeedListRequested event,
    Emitter<SeedState> emit,
  ) async {
    try {
      final files = await listSeedingUseCase.execute();

      // Start seeder listener if we have files and it's not already running
      if (files.isNotEmpty && _seeder == null) {
        await _startSeeder(files.map((f) => MapEntry(f.sha256, f.filePath)));
      }

      emit(SeedIdle(files: files));
    } catch (e) {
      emit(SeedError(message: e.toString()));
    }
  }

  Future<void> _onFileRequested(
    SeedFileRequested event,
    Emitter<SeedState> emit,
  ) async {
    emit(const SeedPublishing());
    try {
      final accounts = await accountStorage.getAll();
      if (accounts.isEmpty) throw StateError('No account found');
      final account = accounts.first;
      final relayUrls = _parseWriteRelays(account.relaysJson);

      final seedFile = await seedFileUseCase.execute(
        filePath: event.filePath,
        nsec: account.nsec,
        relayUrls: relayUrls,
      );

      // Register with seeder for serving
      _seeder?.filesBySha256[seedFile.sha256] = seedFile.filePath;

      add(const SeedListRequested());
    } catch (e) {
      emit(SeedError(message: e.toString()));
    }
  }

  Future<void> _startSeeder(Iterable<MapEntry<String, String>> files) async {
    try {
      final accounts = await accountStorage.getAll();
      if (accounts.isEmpty) return;
      final account = accounts.first;
      final relayUrls = _parseWriteRelays(account.relaysJson);
      if (relayUrls.isEmpty) return;

      _seeder = WebRtcSeeder(
        secretKey: account.nsec,
        relayUrl: relayUrls.first,
      );
      for (final entry in files) {
        _seeder!.filesBySha256[entry.key] = entry.value;
      }
      await _seeder!.start();
      print('[seed-bloc] seeder started, serving ${files.length} files');
    } catch (e) {
      print('[seed-bloc] failed to start seeder: $e');
    }
  }

  @override
  Future<void> close() async {
    await _seeder?.stop();
    return super.close();
  }

  List<String> _parseWriteRelays(String relaysJson) {
    final list = jsonDecode(relaysJson) as List;
    return list
        .cast<Map<String, dynamic>>()
        .where((r) => r['write'] == true)
        .map<String>((r) => r['url'] as String)
        .toList();
  }
}
