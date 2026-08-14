import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/repositories/downloads_repository.dart';
import '../data_sources/downloads_remote_data_source.dart';

@LazySingleton(as: DownloadsRepository)
class DownloadsRepositoryImpl extends BaseRepositoryImpl implements DownloadsRepository {
  final DownloadsRemoteDataSource _downloadsRemoteDataSource;

  DownloadsRepositoryImpl(this._downloadsRemoteDataSource) : super('DownloadsRepository');

  @override
  Future<RequestResult<void>> registerDownload({required String lessonId, required String deviceUuid, required int chunkCount}) =>
      execute(() => _downloadsRemoteDataSource.registerDownload(lessonId: lessonId, deviceUuid: deviceUuid, chunkCount: chunkCount));

  @override
  Future<RequestResult<bool>> validateDownload(String lessonId) => execute(() => _downloadsRemoteDataSource.validateDownload(lessonId));
}
