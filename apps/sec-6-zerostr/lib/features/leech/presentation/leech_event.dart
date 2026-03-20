import '../domain/remote_file.dart';

sealed class LeechEvent {
  const LeechEvent();
}

class LeechListRequested extends LeechEvent {
  const LeechListRequested();
}

class LeechSearchRequested extends LeechEvent {
  const LeechSearchRequested({required this.npub});
  final String npub;
}

class LeechDownloadRequested extends LeechEvent {
  const LeechDownloadRequested({required this.file});
  final RemoteFile file;
}
