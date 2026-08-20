import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/models/pagination_model.dart';
import 'package:mobile_template/core/models/paginated_result.dart';
import 'package:mobile_template/core/utils/app_enums.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/chapters/domain/entities/chapter.dart';
import 'package:mobile_template/features/chapters/domain/repositories/chapters_repository.dart';
import 'package:mobile_template/features/chapters/presentation/cubit/chapters_cubit.dart';
import 'package:mobile_template/features/chapters/presentation/cubit/chapters_state.dart';

PaginationModel _pagination({
  int page = 1,
  int limit = 50,
  int total = 0,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPrevPage = false,
}) => PaginationModel(page: page, limit: limit, total: total, totalPages: totalPages, hasNextPage: hasNextPage, hasPrevPage: hasPrevPage);

class _FakeChaptersRepository implements ChaptersRepository {
  /// Keyed by page number so a test can script page 1 vs page 2 responses.
  Map<int, RequestResult<PaginatedResult<Chapter>>>? pagesByNumber;

  @override
  Future<RequestResult<PaginatedResult<Chapter>>> getChapters(String subjectId, {int page = 1, int limit = 50}) async =>
      pagesByNumber![page]!;

  @override
  Future<RequestResult<T>> execute<T, TM>(request, {converter}) => throw UnimplementedError();

  @override
  RequestResult<T> executeSync<T, TM>(request, {converter}) => throw UnimplementedError();
}

const _chapter1 = Chapter(id: 'c1', subjectId: 'sub1', title: 'الفصل الأول');
const _chapter2 = Chapter(id: 'c2', subjectId: 'sub1', title: 'الفصل الثاني');

void main() {
  late _FakeChaptersRepository repository;

  setUp(() {
    repository = _FakeChaptersRepository();
  });

  blocTest<ChaptersCubit, ChaptersState>(
    'getChapters: emits [loading, success] with page 1 and its pagination',
    build: () {
      repository.pagesByNumber = {
        1: SuccessResult(PaginatedResult([_chapter1], _pagination(page: 1, total: 1, totalPages: 1))),
      };
      return ChaptersCubit(repository);
    },
    act: (cubit) => cubit.getChapters('sub1'),
    expect: () => [
      isA<ChaptersState>().having((s) => s.status, 'status', Status.loading),
      isA<ChaptersState>()
          .having((s) => s.status, 'status', Status.success)
          .having((s) => s.chapters, 'chapters', [_chapter1])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<ChaptersCubit, ChaptersState>(
    'getChapters: an empty page 1 maps to Status.empty',
    build: () {
      repository.pagesByNumber = {1: SuccessResult(PaginatedResult(const [], _pagination(page: 1, total: 0)))};
      return ChaptersCubit(repository);
    },
    act: (cubit) => cubit.getChapters('sub1'),
    expect: () => [
      isA<ChaptersState>().having((s) => s.status, 'status', Status.loading),
      isA<ChaptersState>().having((s) => s.status, 'status', Status.empty),
    ],
  );

  blocTest<ChaptersCubit, ChaptersState>(
    'getChapters: emits [loading, failure] on a repository failure',
    build: () {
      repository.pagesByNumber = {1: const FailureResult(NetworkFailure('offline', 400))};
      return ChaptersCubit(repository);
    },
    act: (cubit) => cubit.getChapters('sub1'),
    expect: () => [
      isA<ChaptersState>().having((s) => s.status, 'status', Status.loading),
      isA<ChaptersState>().having((s) => s.status, 'status', Status.failure).having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<ChaptersCubit, ChaptersState>(
    'loadMoreChapters: appends page 2 to the already-loaded page 1',
    seed: () => ChaptersState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..chapters = [_chapter1]
        ..pagination = _pagination(page: 1, total: 2, totalPages: 2, hasNextPage: true),
    ),
    build: () {
      repository.pagesByNumber = {
        2: SuccessResult(PaginatedResult([_chapter2], _pagination(page: 2, total: 2, totalPages: 2, hasNextPage: false))),
      };
      return ChaptersCubit(repository);
    },
    act: (cubit) => cubit.loadMoreChapters('sub1'),
    expect: () => [
      isA<ChaptersState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
      isA<ChaptersState>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', false)
          .having((s) => s.chapters, 'chapters', [_chapter1, _chapter2])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<ChaptersCubit, ChaptersState>(
    'loadMoreChapters: no-ops once hasNextPage is false (end of list)',
    seed: () => ChaptersState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..chapters = [_chapter1]
        ..pagination = _pagination(page: 1, total: 1, totalPages: 1, hasNextPage: false),
    ),
    build: () => ChaptersCubit(repository),
    act: (cubit) => cubit.loadMoreChapters('sub1'),
    expect: () => <ChaptersState>[],
  );
}
