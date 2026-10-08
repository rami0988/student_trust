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
import 'features/downloads/data/local/download_records_store.dart';
import 'features/downloads/data/models/download_record.dart';
import 'features/downloads/data/services/download_revalidator.dart';
import 'features/downloads/data/services/encrypted_download_service.dart';
import 'features/downloads/presentation/cubit/download_cubit.dart';
import 'firebase/firebase_options_dev.dart';
import 'hive/hive_registrar.g.dart';

/// Firebase is optional. Set to true after running `flutterfire configure`
/// (see CHECKLIST.md) — the app boots and runs fine without it.
const bool useFirebase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  // NOTE(responsive): see main.dart — no app-wide orientation lock.
  Endpoints.setServerUrl('https://magdalen-unhissed-adelaide.ngrok-free.dev');
  if (useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  // Local encrypted-download metadata store (see EncryptedDownloadService).
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox(EncryptedDownloadService.boxName);
  await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);
  await configureDependencies();
  // Repair anything a kill/crash left half-finished before any screen reads
  // the store: an app killed mid-download leaves a partial file, and a lesson
  // whose chunks were purged by the OS would otherwise still be offered as
  // playable and then fail. Best effort - never block startup on it.
  try {
    await getIt<EncryptedDownloadService>().reconcileOnStartup(isTracked: getIt<DownloadRecordsStore>().contains);
  } catch (_) {}
  // Re-check the offline library with the server now and whenever the
  // connection returns: unlocks lessons past the 7-day window, purges ones the
  // student may no longer keep. Fire-and-forget — never delays the first frame.
  getIt<DownloadRevalidator>().start();
  runApp(
    BlocProvider<AppCubit>(
      create: (context) => getIt<AppCubit>()
        ..setAppFlavor(AppFlavor.development)
        ..getAppLanguage(),
      child: BlocProvider<DownloadCubit>(
        // Provided above the navigator so downloads survive screen changes.
        create: (_) => getIt<DownloadCubit>()..restore(),
        child: TemplateApp(appRouter: AppRouter()),
      ),
    ),
  );
}
