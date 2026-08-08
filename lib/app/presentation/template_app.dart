import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/di/di.dart';
import '../../core/routing/app_router.dart';
import '../../core/routing/routes.dart';
import '../../core/theme/app_theme_data.dart';
import '../../core/utils/app_enums.dart';
import '../../generated/l10n.dart';
import 'cubit/app_cubit.dart';
import 'cubit/app_state.dart';

class TemplateApp extends StatelessWidget {
  final AppRouter appRouter;
  const TemplateApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppCubit, AppState, Language>(
      selector: (state) {
        return state.language;
      },
      builder: (context, language) {
        return MaterialApp(
          title: 'App Template',
          debugShowCheckedModeBanner: false,
          navigatorKey: getIt<GlobalKey<NavigatorState>>(),
          theme: AppThemeData.appTheme(language),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1)),
              child: child!,
            );
          },
          initialRoute: Routes.exampleItems,
          onGenerateRoute: appRouter.generateRoute,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: Locale(language.name),
        );
      },
    );
  }
}
