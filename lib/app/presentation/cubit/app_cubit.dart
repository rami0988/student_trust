import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/utils/app_enums.dart';
import '../../domain/repositories/app_repository.dart';
import 'app_state.dart';

@lazySingleton
class AppCubit extends Cubit<AppState> {
  final AppRepository _appRepository;
  AppCubit(this._appRepository) : super(AppState.initial());

  void getAppLanguage() {
    final result = _appRepository.getAppLanguage();
    result.fold(
      failure: (_) => emit(state.rebuild((b) => b..language = Language.ar)),
      success: (language) => emit(state.rebuild((b) => b..language = language)),
    );
  }

  void changeAppLanguage(Language language) async {
    if (language == state.language) return;
    final result = await _appRepository.setAppLanguage(language);
    result.fold(
      failure: (_) => null,
      success: (_) {
        emit(state.rebuild((b) => b..language = language));
      },
    );
  }

  void setAppFlavor(AppFlavor flavor) {
    emit(state.rebuild((b) => b..flavor = flavor));
  }
}
