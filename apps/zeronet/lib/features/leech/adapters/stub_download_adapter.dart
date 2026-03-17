import '../application/download_port.dart';
import '../domain/downloaded_file.dart';
import '../domain/remote_file.dart';

/// Placeholder until WebRTC transfer is implemented.
class StubDownloadAdapter implements DownloadPort {
  const StubDownloadAdapter();

  @override
  Future<DownloadedFile> download(RemoteFile file) {
    throw UnimplementedError(
      'WebRTC transfer not implemented yet. '
      'Seeder must be online and WebRTC signaling is required.',
    );
  }
}
