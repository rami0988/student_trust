import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/presentation/pages/auth_gate.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/chapters/presentation/cubit/chapters_cubit.dart';
import '../../features/chapters/presentation/pages/chapters_args.dart';
import '../../features/chapters/presentation/pages/chapters_page.dart';
import '../../features/lessons/presentation/cubit/lessons_cubit.dart';
import '../../features/lessons/presentation/pages/lessons_args.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/offline/presentation/pages/offline_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/subjects/presentation/cubit/subjects_cubit.dart';
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../../features/video/presentation/pages/video_player_args.dart';
import '../../features/video/presentation/pages/video_player_page.dart';
import '../../features/worksheets/presentation/cubit/worksheet_view_cubit.dart';
import '../../features/worksheets/presentation/cubit/worksheets_cubit.dart';
import '../../features/worksheets/presentation/pages/pdf_viewer_args.dart';
import '../../features/worksheets/presentation/pages/pdf_viewer_page.dart';
import '../../features/worksheets/presentation/pages/worksheet_view_args.dart';
import '../../features/worksheets/presentation/pages/worksheet_view_page.dart';
import '../../features/worksheets/presentation/pages/worksheets_args.dart';
import '../../features/worksheets/presentation/pages/worksheets_page.dart';
import '../di/di.dart';
import 'router_transitions.dart';
import 'routes.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final Object? arguments = settings.arguments;

    switch (settings.name) {
      case Routes.authGate:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.authGate, arguments: arguments),
          const AuthGate(),
        );
      case Routes.login:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.login, arguments: arguments),
          // AuthCubit is an app-wide @lazySingleton — use `.value()` so
          // popping this route never closes it out from under AuthGate or
          // any other screen still holding a reference.
          BlocProvider<AuthCubit>.value(value: getIt<AuthCubit>(), child: const LoginPage()),
        );
      case Routes.subjects:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.subjects, arguments: arguments),
          BlocProvider<SubjectsCubit>(
            create: (BuildContext context) => getIt<SubjectsCubit>()..getSubjects(),
            child: const SubjectsPage(),
          ),
        );
      case Routes.chapters:
        final ChaptersArgs chaptersArgs = arguments as ChaptersArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.chapters, arguments: arguments),
          BlocProvider<ChaptersCubit>(
            create: (BuildContext context) => getIt<ChaptersCubit>()..getChapters(chaptersArgs.subjectId),
            child: ChaptersPage(args: chaptersArgs),
          ),
        );
      case Routes.lessons:
        final LessonsArgs lessonsArgs = arguments as LessonsArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.lessons, arguments: arguments),
          BlocProvider<LessonsCubit>(
            create: (BuildContext context) => getIt<LessonsCubit>()..getLessons(lessonsArgs.chapterId),
            child: LessonsPage(args: lessonsArgs),
          ),
        );
      case Routes.videoPlayer:
        final VideoPlayerArgs videoArgs = arguments as VideoPlayerArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.videoPlayer, arguments: arguments),
          VideoPlayerPage(args: videoArgs),
        );
      case Routes.settings:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.settings, arguments: arguments),
          const SettingsPage(),
        );
      case Routes.offlineHome:
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.offlineHome, arguments: arguments),
          const OfflinePage(),
        );
      case Routes.worksheets:
        final WorksheetsArgs worksheetsArgs = arguments as WorksheetsArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.worksheets, arguments: arguments),
          BlocProvider<WorksheetsCubit>(
            create: (BuildContext context) => getIt<WorksheetsCubit>()..getWorksheets(worksheetsArgs.chapterId),
            child: WorksheetsPage(args: worksheetsArgs),
          ),
        );
      case Routes.worksheetView:
        final WorksheetViewArgs worksheetViewArgs = arguments as WorksheetViewArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.worksheetView, arguments: arguments),
          BlocProvider<WorksheetViewCubit>(
            create: (BuildContext context) => getIt<WorksheetViewCubit>()..load(worksheetViewArgs.worksheetId),
            child: WorksheetViewPage(args: worksheetViewArgs),
          ),
        );
      case Routes.pdfViewer:
        final PdfViewerArgs pdfViewerArgs = arguments as PdfViewerArgs;
        return RouterTransitions.buildDefault(
          settings: RouteSettings(name: Routes.pdfViewer, arguments: arguments),
          PdfViewerPage(args: pdfViewerArgs),
        );
      default:
        return null;
    }
  }
}
