import 'package:injectable/injectable.dart';

import '../../../core/extensions/strings.dart';
import '../../../core/repositories/base_repository_impl.dart';
import '../../../core/utils/app_enums.dart';
import '../../../core/utils/local_storage_keys.dart';
import '../../../core/utils/request_result.dart';
import '../../../core/utils/shared_preferences_helper.dart';
import '../../domain/repositories/app_repository.dart';

@LazySingleton(as: AppRepository)
class AppRepositoryImpl extends BaseRepositoryImpl implements AppRepository {
  AppRepositoryImpl() : super('AppRepository');

  @override
  RequestResult<Language> getAppLanguage() => executeSync<Language, String>(() {
    final String storedLanguage = SharedPreferencesHelper.getString(
      LocalStorageKeys.language,
    );
    if (storedLanguage.isNullOrEmpty()) {
      // final Language deviceLanguage = LanguageHelper.getDeviceLanguage();
      const Language defaultLanguage = Language.ar;
      SharedPreferencesHelper.setData(
        LocalStorageKeys.language,
        defaultLanguage.name,
      );
      return defaultLanguage.name;
    }
    return storedLanguage;
  }, converter: Language.fromValue);

  @override
  Future<RequestResult<void>> setAppLanguage(Language language) async {
    return await execute(() async {
      await SharedPreferencesHelper.setData(
        LocalStorageKeys.language,
        language.name,
      );
      return language;
    });
  }
}
