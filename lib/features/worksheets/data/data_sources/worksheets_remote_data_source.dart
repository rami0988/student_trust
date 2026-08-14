import '../models/worksheet_file_model.dart';
import '../models/worksheet_model.dart';
import '../models/worksheet_video_model.dart';

abstract class WorksheetsRemoteDataSource {
  Future<List<WorksheetModel>> getWorksheets(String chapterId);

  Future<List<WorksheetFileModel>> getFiles(String worksheetId);

  Future<List<WorksheetVideoModel>> getVideos(String worksheetId);

  /// Downloads a PDF to the app temp cache. Returns the local file path.
  Future<String> downloadPdfToCache(String url, String fileName);

  /// Saves a PDF permanently to the device's public Downloads folder.
  Future<String> downloadPdfToDevice(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  });
}
