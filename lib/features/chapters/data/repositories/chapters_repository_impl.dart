import 'package:injectable/injectable.dart';

import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapters_repository.dart';
import '../data_sources/chapters_remote_data_source.dart';

@LazySingleton(as: ChaptersRepository)
class ChaptersRepositoryImpl extends BaseRepositoryImpl implements ChaptersRepository {
  final ChaptersRemoteDataSource _chaptersRemoteDataSource;

  ChaptersRepositoryImpl(this._chaptersRemoteDataSource) : super('ChaptersRepository');

  @override
  Future<RequestResult<PaginatedResult<Chapter>>> getChapters(String subjectId, {int page = 1, int limit = 50}) => execute(
    () => _chaptersRemoteDataSource.getChapters(subjectId, page: page, limit: limit),
    converter: (page) => page.map((m) => m.toDomain()),
  );
}
