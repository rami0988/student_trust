import '../../domain/entities/download_verdict.dart';

abstract class DownloadsRemoteDataSource {
  Future<void> registerDownload({required String lessonId, required String deviceUuid, required int chunkCount});

  Future<bool> validateDownload(String lessonId);

  /// Batch revalidation: a verdict per lesson id the server answered for.
  Future<Map<String, DownloadVerdict>> validateDownloads(List<String> lessonIds);
}
