import '../models/chapter_model.dart';

abstract class ChaptersRemoteDataSource {
  Future<List<ChapterModel>> getChapters(String subjectId);
}
