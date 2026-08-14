abstract class DownloadsRemoteDataSource {
  Future<void> registerDownload({required String lessonId, required String deviceUuid, required int chunkCount});

  Future<bool> validateDownload(String lessonId);
}
