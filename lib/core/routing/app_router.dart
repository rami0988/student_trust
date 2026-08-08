import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/example_feature/domain/repositories/example_feature_repository.dart';
import '../../features/example_feature/presentation/bloc/example_feature_bloc.dart';
import '../../features/example_feature/presentation/bloc/example_feature_event.dart';
import '../../features/example_feature/presentation/cubit/example_item_details_cubit.dart';
import '../../features/example_feature/presentation/pages/example_item_details_args.dart';
import '../../features/example_feature/presentation/pages/example_item_details_page.dart';
import '../../features/example_feature/presentation/pages/example_items_page.dart';
import '../di/di.dart';
import 'router_transitions.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final Object? arguments = settings.arguments;

    switch (settings.name) {
      case Routes.exampleItems:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(
            name: Routes.exampleItems,
            arguments: arguments,
          ),
          BlocProvider<ExampleFeatureBloc>(
            create: (BuildContext context) => getIt<ExampleFeatureBloc>()..add(GetExampleItems((b) => b..reInitialData = false)),
            child: const ExampleItemsPage(),
          ),
        );
      case Routes.exampleItemDetails:
        final ExampleItemDetailsArgs args = arguments as ExampleItemDetailsArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(
            name: Routes.exampleItemDetails,
            arguments: arguments,
          ),
          BlocProvider<ExampleItemDetailsCubit>(
            create: (BuildContext context) => ExampleItemDetailsCubit(
              getIt<ExampleFeatureRepository>(),
              getIt(),
              args,
            )..getExampleItem(),
            child: ExampleItemDetailsPage(args: args),
          ),
        );
      default:
        return null;
    }
  }
}
