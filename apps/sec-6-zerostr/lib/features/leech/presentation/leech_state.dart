import '../domain/downloaded_file.dart';
import '../domain/remote_file.dart';

sealed class LeechState {
  const LeechState();
}

class LeechIdle extends LeechState {
  const LeechIdle({this.downloaded = const []});
  final List<DownloadedFile> downloaded;
}

class LeechSearching extends LeechState {
  const LeechSearching();
}

class LeechSearchResults extends LeechState {
  const LeechSearchResults({required this.results});
  final List<RemoteFile> results;
}

class LeechDownloading extends LeechState {
  const LeechDownloading();
}

class LeechError extends LeechState {
  const LeechError({required this.message});
  final String message;
}
