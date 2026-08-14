import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app/presentation/cubit/app_cubit.dart';
import 'app/presentation/template_app.dart';
import 'core/di/di.dart';
import 'core/network/endpoints.dart';
import 'core/routing/app_router.dart';
import 'core/utils/app_enums.dart';
import 'core/utils/bloc_observer.dart';
import 'features/downloads/data/services/encrypted_download_service.dart';
import 'features/downloads/presentation/cubit/download_cubit.dart';
import 'firebase/firebase_options_prod.dart';

/// Firebase is optional. Set to true after running `flutterfire configure`
/// (see CHECKLIST.md) — the app boots and runs fine without it.
const bool useFirebase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  // NOTE(responsive): no app-wide orientation lock — every screen must work
  // in both portrait and landscape (tablets/foldables rotate freely). Only
  // the video player constrains orientation, and only while it's on screen
  // (see VideoPlayerPage's initState/dispose).
  Endpoints.setServerUrl('https://api.ra-trust.site');
  if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  // Local encrypted-download metadata store (see EncryptedDownloadService).
  await Hive.initFlutter();
  await Hive.openBox(EncryptedDownloadService.boxName);
  await configureDependencies();
  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>()
        ..setAppFlavor(AppFlavor.production)
        ..getAppLanguage(),
      child: BlocProvider<DownloadCubit>(
        // Provided above the navigator so downloads survive screen changes.
        create: (_) => getIt<DownloadCubit>(),
        child: TemplateApp(appRouter: AppRouter()),
      ),
    ),
  );
}
