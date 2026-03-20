import '../domain/downloaded_file.dart';
import '../domain/remote_file.dart';

abstract interface class DownloadPort {
  Future<DownloadedFile> download(RemoteFile file);
}
