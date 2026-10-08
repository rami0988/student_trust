import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/download_verdict.dart';

abstract class DownloadsRepository extends BaseRepository {
  /// Registers a completed download on the backend (audit + device binding).
  /// Best-effort by convention at the call site — offline registration
  /// failures should not fail the download itself.
  Future<RequestResult<void>> registerDownload({required String lessonId, required String deviceUuid, required int chunkCount});

  /// Re-validates an offline lesson against the server (subscription still
  /// active?). Returns true when the lesson may still be played offline.
  Future<RequestResult<bool>> validateDownload(String lessonId);

  /// Re-validates many offline lessons in one request (on launch and when
  /// connectivity returns). Only lessons the server answered for appear in
  /// the result; a failure means "no verdict", never "invalid".
  Future<RequestResult<Map<String, DownloadVerdict>>> validateDownloads(List<String> lessonIds);
}
