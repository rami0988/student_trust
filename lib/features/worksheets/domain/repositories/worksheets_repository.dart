import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/worksheet.dart';
import '../entities/worksheet_file.dart';
import '../entities/worksheet_video.dart';

abstract class WorksheetsRepository extends BaseRepository {
  Future<RequestResult<List<Worksheet>>> getWorksheets(String chapterId);

  Future<RequestResult<List<WorksheetFile>>> getFiles(String worksheetId);

  Future<RequestResult<List<WorksheetVideo>>> getVideos(String worksheetId);

  /// Downloads a PDF to the app temp cache for in-app viewing. Returns the
  /// local file path.
  Future<RequestResult<String>> downloadPdfToCache(String url, String fileName);

  /// Saves a PDF PERMANENTLY to the public Downloads folder so the student
  /// can open/keep/share it outside the app. Worksheet PDFs are intentionally
  /// NOT encrypted or device-locked (unlike lesson videos).
  Future<RequestResult<String>> downloadPdfToDevice(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  });
}
