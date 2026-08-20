import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/models/pagination_model.dart';
import 'package:mobile_template/core/models/paginated_result.dart';
import 'package:mobile_template/core/utils/app_enums.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/lessons/domain/entities/lesson.dart';
import 'package:mobile_template/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:mobile_template/features/lessons/presentation/cubit/lessons_cubit.dart';
import 'package:mobile_template/features/lessons/presentation/cubit/lessons_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// `EncryptedDownloadService` touches a lazily-opened Hive box in
// `isDownloaded()`, which a plain unit test has no Hive environment for —
// mockito avoids ever calling through to the real implementation.
// `LessonsRepository` is mocked too, so `execute`/`executeSync` (inherited
// from `BaseRepository`) don't need hand-written stubs.
@GenerateNiceMocks([MockSpec<LessonsRepository>(), MockSpec<EncryptedDownloadService>()])
import 'lessons_cubit_test.mocks.dart';

PaginationModel _pagination({
  int page = 1,
  int limit = 50,
  int total = 0,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPrevPage = false,
}) => PaginationModel(page: page, limit: limit, total: total, totalPages: totalPages, hasNextPage: hasNextPage, hasPrevPage: hasPrevPage);

const _lesson1 = Lesson(id: 'l1', chapterId: 'c1', title: 'الدرس الأول');
const _lesson2 = Lesson(id: 'l2', chapterId: 'c1', title: 'الدرس الثاني');

void main() {
  late MockLessonsRepository repository;
  late MockEncryptedDownloadService downloadService;

  setUp(() {
    repository = MockLessonsRepository();
    downloadService = MockEncryptedDownloadService();
    when(downloadService.isDownloaded(any)).thenReturn(false);
  });

  blocTest<LessonsCubit, LessonsState>(
    'getLessons: emits [loading, success] with page 1 and its pagination',
    build: () {
      when(
        repository.getLessons('c1', page: 1),
      ).thenAnswer((_) async => SuccessResult(PaginatedResult([_lesson1], _pagination(page: 1, total: 1, totalPages: 1))));
      return LessonsCubit(repository, downloadService);
    },
    act: (cubit) => cubit.getLessons('c1'),
    expect: () => [
      isA<LessonsState>().having((s) => s.status, 'status', Status.loading),
      isA<LessonsState>()
          .having((s) => s.status, 'status', Status.success)
          .having((s) => s.lessons, 'lessons', [_lesson1])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<LessonsCubit, LessonsState>(
    'getLessons: an empty page 1 maps to Status.empty',
    build: () {
      when(
        repository.getLessons('c1', page: 1),
      ).thenAnswer((_) async => SuccessResult(PaginatedResult(const [], _pagination(page: 1, total: 0))));
      return LessonsCubit(repository, downloadService);
    },
    act: (cubit) => cubit.getLessons('c1'),
    expect: () => [
      isA<LessonsState>().having((s) => s.status, 'status', Status.loading),
      isA<LessonsState>().having((s) => s.status, 'status', Status.empty),
    ],
  );

  blocTest<LessonsCubit, LessonsState>(
    'getLessons: emits [loading, failure] on a repository failure',
    build: () {
      when(repository.getLessons('c1', page: 1)).thenAnswer((_) async => const FailureResult(NetworkFailure('offline', 400)));
      return LessonsCubit(repository, downloadService);
    },
    act: (cubit) => cubit.getLessons('c1'),
    expect: () => [
      isA<LessonsState>().having((s) => s.status, 'status', Status.loading),
      isA<LessonsState>().having((s) => s.status, 'status', Status.failure).having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<LessonsCubit, LessonsState>(
    'getLessons: marks a lesson downloaded when EncryptedDownloadService reports it so',
    build: () {
      when(
        repository.getLessons('c1', page: 1),
      ).thenAnswer((_) async => SuccessResult(PaginatedResult([_lesson1], _pagination(page: 1, total: 1, totalPages: 1))));
      when(downloadService.isDownloaded('l1')).thenReturn(true);
      return LessonsCubit(repository, downloadService);
    },
    act: (cubit) => cubit.getLessons('c1'),
    expect: () => [
      isA<LessonsState>().having((s) => s.status, 'status', Status.loading),
      isA<LessonsState>().having((s) => s.downloadedLessonIds, 'downloadedLessonIds', ['l1']),
    ],
  );

  blocTest<LessonsCubit, LessonsState>(
    'loadMoreLessons: appends page 2 to the already-loaded page 1',
    seed: () => LessonsState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..lessons = [_lesson1]
        ..pagination = _pagination(page: 1, total: 2, totalPages: 2, hasNextPage: true),
    ),
    build: () {
      when(
        repository.getLessons('c1', page: 2),
      ).thenAnswer((_) async => SuccessResult(PaginatedResult([_lesson2], _pagination(page: 2, total: 2, totalPages: 2, hasNextPage: false))));
      return LessonsCubit(repository, downloadService);
    },
    act: (cubit) => cubit.loadMoreLessons('c1'),
    expect: () => [
      isA<LessonsState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
      isA<LessonsState>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', false)
          .having((s) => s.lessons, 'lessons', [_lesson1, _lesson2])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<LessonsCubit, LessonsState>(
    'loadMoreLessons: no-ops once hasNextPage is false (end of list)',
    seed: () => LessonsState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..lessons = [_lesson1]
        ..pagination = _pagination(page: 1, total: 1, totalPages: 1, hasNextPage: false),
    ),
    build: () => LessonsCubit(repository, downloadService),
    act: (cubit) => cubit.loadMoreLessons('c1'),
    expect: () => <LessonsState>[],
  );
}
