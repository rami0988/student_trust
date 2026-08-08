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
import '../../features/example_feature/data/data_sources/example_feature_remote_data_source.dart'
    as _i1070;
import '../../features/example_feature/data/data_sources/example_feature_remote_data_source_impl.dart'
    as _i143;
import '../../features/example_feature/data/repositories/example_feature_repository_impl.dart'
    as _i740;
import '../../features/example_feature/domain/repositories/example_feature_repository.dart'
    as _i59;
import '../../features/example_feature/domain/use_cases/get_example_items_use_case.dart'
    as _i503;
import '../../features/example_feature/domain/use_cases/like_example_item_use_case.dart'
    as _i870;
import '../../features/example_feature/domain/use_cases/unlike_example_item_use_case.dart'
    as _i754;
import '../../features/example_feature/presentation/bloc/example_feature_bloc.dart'
    as _i533;
import '../data_source/remote/base_remote_data_source.dart' as _i755;
import '../data_source/remote/base_remote_data_source_impl.dart' as _i330;
import '../network/network_info.dart' as _i932;
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
  gh.lazySingleton<_i755.BaseRemoteDataSource>(
    () => _i330.BaseRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i1070.ExampleFeatureRemoteDataSource>(
    () => _i143.ExampleFeatureRemoteDataSourceImpl(gh<_i361.Dio>()),
  );
  gh.lazySingleton<_i350.AppRepository>(() => _i604.AppRepositoryImpl());
  gh.lazySingleton<_i406.AppCubit>(
    () => _i406.AppCubit(gh<_i350.AppRepository>()),
  );
  gh.lazySingleton<_i681.DeepLinkHelper>(
    () => _i681.DeepLinkHelper(gh<_i409.GlobalKey<_i409.NavigatorState>>()),
  );
  gh.lazySingleton<_i59.ExampleFeatureRepository>(
    () => _i740.ExampleFeatureRepositoryImpl(
      gh<_i1070.ExampleFeatureRemoteDataSource>(),
    ),
  );
  gh.lazySingleton<_i932.NetworkInfo>(
    () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
  );
  gh.factory<_i503.GetExampleItemsUseCase>(
    () => _i503.GetExampleItemsUseCase(gh<_i59.ExampleFeatureRepository>()),
  );
  gh.factory<_i870.LikeExampleItemUseCase>(
    () => _i870.LikeExampleItemUseCase(gh<_i59.ExampleFeatureRepository>()),
  );
  gh.factory<_i754.UnlikeExampleItemUseCase>(
    () => _i754.UnlikeExampleItemUseCase(gh<_i59.ExampleFeatureRepository>()),
  );
  gh.factory<_i533.ExampleFeatureBloc>(
    () => _i533.ExampleFeatureBloc(
      gh<_i503.GetExampleItemsUseCase>(),
      gh<_i870.LikeExampleItemUseCase>(),
      gh<_i754.UnlikeExampleItemUseCase>(),
      gh<_i1017.EventBus>(),
    ),
  );
  return getIt;
}

class _$RegisterModule extends _i913.RegisterModule {}
