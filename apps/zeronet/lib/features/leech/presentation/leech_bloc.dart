import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../adapters/namecoin_resolution_adapter.dart';
import '../application/download_file_use_case.dart';
import '../application/search_files_use_case.dart';
import '../domain/downloaded_file.dart';
import 'leech_event.dart';
import 'leech_state.dart';

class LeechBloc extends Bloc<LeechEvent, LeechState> {
  LeechBloc({
    required this.searchFilesUseCase,
    required this.downloadFileUseCase,
    required this.accountStorage,
  }) : super(const LeechIdle()) {
    on<LeechListRequested>(_onListRequested);
    on<LeechSearchRequested>(_onSearchRequested);
    on<LeechDownloadRequested>(_onDownloadRequested);
    add(const LeechListRequested());
  }

  final SearchFilesUseCase searchFilesUseCase;
  final DownloadFileUseCase downloadFileUseCase;
  final AccountStoragePort accountStorage;

  Future<void> _onListRequested(
    LeechListRequested event,
    Emitter<LeechState> emit,
  ) async {
    final downloaded = await _scanDownloaded();
    emit(LeechIdle(downloaded: downloaded));
  }

  Future<void> _onSearchRequested(
    LeechSearchRequested event,
    Emitter<LeechState> emit,
  ) async {
    emit(const LeechSearching());
    try {
      var npub = event.npub;
      if (!npub.startsWith('npub1')) {
        npub = await NamecoinResolutionAdapter().resolve(npub);
      }

      final accounts = await accountStorage.getAll();
      if (accounts.isEmpty) throw StateError('No account found');
      final relayUrls = _parseReadRelays(accounts.first.relaysJson);

      final results = await searchFilesUseCase.execute(
        npub: npub,
        relayUrls: relayUrls,
      );
      emit(LeechSearchResults(results: results));
    } catch (e) {
      emit(LeechError(message: e.toString()));
    }
  }

  Future<void> _onDownloadRequested(
    LeechDownloadRequested event,
    Emitter<LeechState> emit,
  ) async {
    emit(const LeechDownloading());
    try {
      await downloadFileUseCase.execute(event.file);
      add(const LeechListRequested());
    } catch (e) {
      emit(LeechError(message: e.toString()));
    }
  }

  Future<List<DownloadedFile>> _scanDownloaded() async {
    final supportDir = await getApplicationSupportDirectory();
    final websitesDir = Directory(p.join(supportDir.path, 'websites'));
    if (!await websitesDir.exists()) return [];

    final files = <DownloadedFile>[];
    await for (final entry in websitesDir.list()) {
      if (entry is! Directory) continue;
      final indexFile = File(p.join(entry.path, 'index.html'));
      if (!await indexFile.exists()) {
        // Check for any HTML file
        await for (final f in entry.list()) {
          if (f is File && f.path.endsWith('.html')) {
            files.add(DownloadedFile(
              title: p.basenameWithoutExtension(f.path),
              filePath: f.path,
            ));
            break;
          }
        }
      } else {
        files.add(DownloadedFile(
          title: p.basenameWithoutExtension(indexFile.path),
          filePath: indexFile.path,
        ));
      }
    }
    return files;
  }

  List<String> _parseReadRelays(String relaysJson) {
    final list = jsonDecode(relaysJson) as List;
    return list
        .cast<Map<String, dynamic>>()
        .where((r) => r['read'] == true)
        .map<String>((r) => r['url'] as String)
        .toList();
  }
}
