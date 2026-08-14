import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/worksheet.dart';
import '../../domain/entities/worksheet_file.dart';
import '../../domain/entities/worksheet_video.dart';
import '../../domain/repositories/worksheets_repository.dart';
import '../data_sources/worksheets_remote_data_source.dart';
import '../models/worksheet_file_model.dart';
import '../models/worksheet_model.dart';
import '../models/worksheet_video_model.dart';

@LazySingleton(as: WorksheetsRepository)
class WorksheetsRepositoryImpl extends BaseRepositoryImpl implements WorksheetsRepository {
  final WorksheetsRemoteDataSource _worksheetsRemoteDataSource;

  WorksheetsRepositoryImpl(this._worksheetsRemoteDataSource) : super('WorksheetsRepository');

  @override
  Future<RequestResult<List<Worksheet>>> getWorksheets(String chapterId) => execute(
    () => _worksheetsRemoteDataSource.getWorksheets(chapterId),
    converter: (List<WorksheetModel> models) => models.map((m) => m.toDomain()).toList(),
  );

  @override
  Future<RequestResult<List<WorksheetFile>>> getFiles(String worksheetId) => execute(
    () => _worksheetsRemoteDataSource.getFiles(worksheetId),
    converter: (List<WorksheetFileModel> models) => models.map((m) => m.toDomain()).toList(),
  );

  @override
  Future<RequestResult<List<WorksheetVideo>>> getVideos(String worksheetId) => execute(
    () => _worksheetsRemoteDataSource.getVideos(worksheetId),
    converter: (List<WorksheetVideoModel> models) => models.map((m) => m.toDomain()).toList(),
  );

  @override
  Future<RequestResult<String>> downloadPdfToCache(String url, String fileName) =>
      execute(() => _worksheetsRemoteDataSource.downloadPdfToCache(url, fileName));

  @override
  Future<RequestResult<String>> downloadPdfToDevice(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) => execute(() => _worksheetsRemoteDataSource.downloadPdfToDevice(url, fileName, onProgress: onProgress));
}
