import '../../../core/repositories/base_repository.dart';
import '../../../core/utils/app_enums.dart';
import '../../../core/utils/request_result.dart';

abstract class AppRepository extends BaseRepository {
  RequestResult<Language> getAppLanguage();
  Future<RequestResult<void>> setAppLanguage(Language language);
}
