import '../models/subject_model.dart';

abstract class SubjectsRemoteDataSource {
  Future<List<SubjectModel>> getSubjects();
}
