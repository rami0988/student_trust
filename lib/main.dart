import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/presentation/cubit/app_cubit.dart';
import 'app/presentation/template_app.dart';
import 'core/di/di.dart';
import 'core/network/endpoints.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_enums.dart';
import 'core/utils/bloc_observer.dart';
import 'firebase/firebase_options_prod.dart';

/// Firebase is optional. Set to true after running `flutterfire configure`
/// (see CHECKLIST.md) — the app boots and runs fine without it.
const bool useFirebase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // TODO(template): replace with your production server URL, e.g.
  // Endpoints.setServerUrl('https://api.example.com');
  Endpoints.setServerUrl(Endpoints.mockServerUrl);
  if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  await configureDependencies();
  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>()
        ..setAppFlavor(AppFlavor.production)
        ..getAppLanguage(),
      child: TemplateApp(appRouter: AppRouter()),
    ),
  );
}
