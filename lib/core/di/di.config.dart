// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:dio/dio.dart' as _i361;
import 'package:event_bus/event_bus.dart' as _i1017;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter/material.dart' as _i409;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_ce_flutter/hive_ce_flutter.dart' as _i965;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../app/data/repositories/app_repository_impl.dart' as _i604;
import '../../app/domain/repositories/app_repository.dart' as _i350;
import '../../app/presentation/cubit/app_cubit.dart' as _i406;
import '../../features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i25;
import '../../features/auth/data/data_sources/auth_remote_data_source_impl.dart'
    as _i182;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/chapters/data/data_sources/chapters_remote_data_source.dart'
    as _i41;
import '../../features/chapters/data/data_sources/chapters_remote_data_source_impl.dart'
    as _i10;
import '../../features/chapters/data/repositories/chapters_repository_impl.dart'
    as _i309;
import '../../features/chapters/domain/repositories/chapters_repository.dart'
    as _i355;
import '../../features/chapters/presentation/cubit/chapters_cubit.dart'
    as _i919;
import '../../features/downloads/data/data_sources/downloads_remote_data_source.dart'
    as _i945;
import '../../features/downloads/data/data_sources/downloads_remote_data_source_impl.dart'
    as _i399;
import '../../features/downloads/data/repositories/downloads_repository_impl.dart'
    as _i1072;
import '../../features/downloads/data/services/encrypted_download_service.dart'
    as _i503;
import '../../features/downloads/domain/repositories/downloads_repository.dart'
    as _i1025;
import '../../features/downloads/presentation/cubit/download_cubit.dart'
    as _i723;
import '../../features/lessons/data/data_sources/lessons_remote_data_source.dart'
    as _i596;
import '../../features/lessons/data/data_sources/lessons_remote_data_source_impl.dart'
    as _i439;
import '../../features/lessons/data/repositories/lessons_repository_impl.dart'
    as _i393;
import '../../features/lessons/domain/repositories/lessons_repository.dart'
    as _i265;
import '../../features/lessons/presentation/cubit/lessons_cubit.dart' as _i879;
import '../../features/subjects/data/data_sources/subjects_remote_data_source.dart'
    as _i968;
import '../../features/subjects/data/data_sources/subjects_remote_data_source_impl.dart'
    as _i377;
import '../../features/subjects/data/repositories/subjects_repository_impl.dart'
    as _i962;
import '../../features/subjects/domain/repositories/subjects_repository.dart'
    as _i640;
import '../../features/subjects/presentation/cubit/subjects_cubit.dart'
    as _i722;
import '../../features/video/data/data_sources/video_remote_data_source.dart'
    as _i170;
import '../../features/video/data/data_sources/video_remote_data_source_impl.dart'
    as _i488;
import '../../features/video/data/repositories/video_repository_impl.dart'
    as _i606;
import '../../features/video/domain/repositories/video_repository.dart'
    as _i247;
import '../../features/video/presentation/cubit/video_cubit.dart' as _i517;
import '../../features/worksheets/data/data_sources/worksheets_remote_data_source.dart'
    as _i435;
import '../../features/worksheets/data/data_sources/worksheets_remote_data_source_impl.dart'
    as _i389;
import '../../features/worksheets/data/repositories/worksheets_repository_impl.dart'
    as _i488;
import '../../features/worksheets/domain/repositories/worksheets_repository.dart'
    as _i395;
import '../../features/worksheets/presentation/cubit/worksheet_view_cubit.dart'
    as _i585;
import '../../features/worksheets/presentation/cubit/worksheets_cubit.dart'
    as _i693;
import '../data_source/remote/base_remote_data_source.dart' as _i755;
import '../data_source/remote/base_remote_data_source_impl.dart' as _i330;
import '../network/network_info.dart' as _i932;
import '../routing/route_tracker.dart' as _i54;
import '../services/connectivity_service.dart' as _i47;
import '../services/device_service.dart' as _i738;
import '../services/security_service.dart' as _i337;
import '../utils/deep_link_helper.dart' as _i681;
import '../utils/notifications_helper.dart' as _i126;
import 'di.dart' as _i913;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i558.FlutterSecureStorage>(
    () => registerModule.flutterSecureStorage,
  );
  gh.lazySingleton<_i409.GlobalKey<_i409.State<_i409.StatefulWidget>>>(
    () => registerModule.loaderDialogKey,
  );
  gh.lazySingleton<_i409.GlobalKey<_i409.NavigatorState>>(
    () => registerModule.navigatorKey,
  );
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
  gh.lazySingleton<_i1017.EventBus>(() => registerModule.eventBus);
  gh.lazySingleton<_i892.FirebaseMessaging>(
    () => registerModule.firebaseMessaging,
  );
  gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
    () => registerModule.flutterLocalNotificationsPlugin,
  );
  gh.lazySingleton<_i833.DeviceInfoPlugin>(
    () => registerModule.deviceInfoPlugin,
  );
  await gh.lazySingletonAsync<_i460.SharedPreferences>(
    () => registerModule.getSharedPreferences(),
    preResolve: true,
  );
  await gh.lazySingletonAsync<_i965.Box<dynamic>>(
    () => registerModule.getAppBox(),
    preResolve: true,
  );
  gh.lazySingleton<_i54.RouteTracker>(() => _i54.RouteTracker());
  gh.lazySingleton<_i337.SecurityService>(() => _i337.SecurityService());
  gh.lazySingleton<_i503.EncryptedDownloadService>(
    () => _i503.EncryptedDownloadService(),
  );
  gh.lazySingleton<_i126.NotificationsHelper>(
    () => _i126.NotificationsHelper(
      gh<_i361.Dio>(),
      gh<_i892.FirebaseMessaging>(),
      gh<_i409.GlobalKey<_i409.NavigatorState>>(),
      gh<_i163.FlutterLocalNotificationsPlugin>(),
      gh<_i1017.EventBus>(),
      gh<_i833.DeviceInfoPlugin>(),
    ),
  );
  gh.lazySingleton<_i596.LessonsRemoteDataSource>(
    () => _i439.LessonsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i945.DownloadsRemoteDataSource>(
    () => _i399.DownloadsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i25.AuthRemoteDataSource>(
    () => _i182.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i738.DeviceService>(
    () => _i738.DeviceService(
      gh<_i558.FlutterSecureStorage>(),
      gh<_i833.DeviceInfoPlugin>(),
    ),
  );
  gh.lazySingleton<_i435.WorksheetsRemoteDataSource>(
    () => _i389.WorksheetsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i787.AuthRepository>(
    () => _i153.AuthRepositoryImpl(
      gh<_i25.AuthRemoteDataSource>(),
      gh<_i738.DeviceService>(),
    ),
  );
  gh.lazySingleton<_i41.ChaptersRemoteDataSource>(
    () => _i10.ChaptersRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i755.BaseRemoteDataSource>(
    () => _i330.BaseRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i968.SubjectsRemoteDataSource>(
    () => _i377.SubjectsRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i265.LessonsRepository>(
    () => _i393.LessonsRepositoryImpl(gh<_i596.LessonsRemoteDataSource>()),
  );
  gh.lazySingleton<_i350.AppRepository>(() => _i604.AppRepositoryImpl());
  gh.factory<_i879.LessonsCubit>(
    () => _i879.LessonsCubit(
      gh<_i265.LessonsRepository>(),
      gh<_i503.EncryptedDownloadService>(),
    ),
  );
  gh.lazySingleton<_i170.VideoRemoteDataSource>(
    () => _i488.VideoRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i247.VideoRepository>(
    () => _i606.VideoRepositoryImpl(gh<_i170.VideoRemoteDataSource>()),
  );
  gh.lazySingleton<_i406.AppCubit>(
    () => _i406.AppCubit(gh<_i350.AppRepository>()),
  );
  gh.lazySingleton<_i47.ConnectivityService>(
    () => _i47.ConnectivityService(gh<_i895.Connectivity>()),
  );
  gh.lazySingleton<_i355.ChaptersRepository>(
    () => _i309.ChaptersRepositoryImpl(gh<_i41.ChaptersRemoteDataSource>()),
  );
  gh.lazySingleton<_i640.SubjectsRepository>(
    () => _i962.SubjectsRepositoryImpl(gh<_i968.SubjectsRemoteDataSource>()),
  );
  gh.lazySingleton<_i681.DeepLinkHelper>(
    () => _i681.DeepLinkHelper(gh<_i409.GlobalKey<_i409.NavigatorState>>()),
  );
  gh.lazySingleton<_i1025.DownloadsRepository>(
    () => _i1072.DownloadsRepositoryImpl(gh<_i945.DownloadsRemoteDataSource>()),
  );
  gh.lazySingleton<_i117.AuthCubit>(
    () => _i117.AuthCubit(gh<_i787.AuthRepository>()),
  );
  gh.factory<_i722.SubjectsCubit>(
    () => _i722.SubjectsCubit(gh<_i640.SubjectsRepository>()),
  );
  gh.lazySingleton<_i932.NetworkInfo>(
    () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
  );
  gh.lazySingleton<_i395.WorksheetsRepository>(
    () =>
        _i488.WorksheetsRepositoryImpl(gh<_i435.WorksheetsRemoteDataSource>()),
  );
  gh.factory<_i919.ChaptersCubit>(
    () => _i919.ChaptersCubit(gh<_i355.ChaptersRepository>()),
  );
  gh.lazySingleton<_i723.DownloadCubit>(
    () => _i723.DownloadCubit(
      gh<_i503.EncryptedDownloadService>(),
      gh<_i1025.DownloadsRepository>(),
      gh<_i738.DeviceService>(),
    ),
  );
  gh.factory<_i585.WorksheetViewCubit>(
    () => _i585.WorksheetViewCubit(gh<_i395.WorksheetsRepository>()),
  );
  gh.factory<_i693.WorksheetsCubit>(
    () => _i693.WorksheetsCubit(gh<_i395.WorksheetsRepository>()),
  );
  gh.factory<_i517.VideoCubit>(
    () => _i517.VideoCubit(
      gh<_i247.VideoRepository>(),
      gh<_i503.EncryptedDownloadService>(),
      gh<_i1025.DownloadsRepository>(),
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i913.RegisterModule {}
