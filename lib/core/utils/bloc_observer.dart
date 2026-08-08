import 'package:flutter_bloc/flutter_bloc.dart';

import 'logger.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    Logger.success(icon: '🟢', name: 'BlocCreated', '${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    Logger.debug(icon: '🚫', name: 'BlocClosed', '${bloc.runtimeType}');
  }
}
