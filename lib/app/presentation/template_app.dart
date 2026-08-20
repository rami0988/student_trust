import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../core/di/di.dart';
import '../../core/routing/app_router.dart';
import '../../core/routing/route_tracker.dart';
import '../../core/theme/app_theme_data.dart';
import '../../generated/l10n.dart';
import 'cubit/app_cubit.dart';
import 'cubit/app_state.dart';
import 'pages/auth_gate.dart';
import 'widgets/connectivity_watcher.dart';
import 'widgets/session_watcher.dart';

class TemplateApp extends StatelessWidget {
  final AppRouter appRouter;
  const TemplateApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'ثقة',
          debugShowCheckedModeBanner: false,
          navigatorKey: getIt<GlobalKey<NavigatorState>>(),
          navigatorObservers: [getIt<RouteTracker>()],
          // Light-only app — no dark mode, so no themeMode/darkTheme wiring.
          theme: AppThemeData.light(state.language),
          builder: (context, child) {
            // ConnectivityWatcher and SessionWatcher sit here, above the
            // navigator, so they survive the `pushNamedAndRemoveUntil` calls
            // that replace the whole route stack — see their doc comments.
            return ConnectivityWatcher(
              child: SessionWatcher(
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1)),
                  child: child!,
                ),
              ),
            );
          },
          home: const AuthGate(),
          onGenerateRoute: appRouter.generateRoute,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          locale: Locale(state.language.name),
        );
      },
    );
  }
}
