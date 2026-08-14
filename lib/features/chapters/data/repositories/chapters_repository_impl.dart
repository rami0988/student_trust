import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/chapters_repository.dart';
import '../data_sources/chapters_remote_data_source.dart';
import '../models/chapter_model.dart';

@LazySingleton(as: ChaptersRepository)
class ChaptersRepositoryImpl extends BaseRepositoryImpl implements ChaptersRepository {
  final ChaptersRemoteDataSource _chaptersRemoteDataSource;

  ChaptersRepositoryImpl(this._chaptersRemoteDataSource) : super('ChaptersRepository');

  @override
  Future<RequestResult<List<Chapter>>> getChapters(String subjectId) => execute(
    () => _chaptersRemoteDataSource.getChapters(subjectId),
    converter: (List<ChapterModel> models) => models.map((m) => m.toDomain()).toList(),
  );
}
