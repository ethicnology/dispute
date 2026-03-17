import '../domain/downloaded_file.dart';
import '../domain/remote_file.dart';
import 'download_port.dart';

class DownloadFileUseCase {
  const DownloadFileUseCase({required this.downloadPort});

  final DownloadPort downloadPort;

  Future<DownloadedFile> execute(RemoteFile file) => downloadPort.download(file);
}
