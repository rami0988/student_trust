import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/models/pagination_model.dart';
import 'package:mobile_template/core/models/paginated_result.dart';
import 'package:mobile_template/core/utils/app_enums.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/subjects/domain/entities/subject.dart';
import 'package:mobile_template/features/subjects/domain/repositories/subjects_repository.dart';
import 'package:mobile_template/features/subjects/presentation/cubit/subjects_cubit.dart';
import 'package:mobile_template/features/subjects/presentation/cubit/subjects_state.dart';

PaginationModel _pagination({
  int page = 1,
  int limit = 50,
  int total = 0,
  int totalPages = 1,
  bool hasNextPage = false,
  bool hasPrevPage = false,
}) => PaginationModel(page: page, limit: limit, total: total, totalPages: totalPages, hasNextPage: hasNextPage, hasPrevPage: hasPrevPage);

class _FakeSubjectsRepository implements SubjectsRepository {
  /// Keyed by page number so a test can script page 1 vs page 2 responses.
  Map<int, RequestResult<PaginatedResult<Subject>>>? pagesByNumber;
  RequestResult<List<Subject>>? getAllSubjectsResult;

  @override
  Future<RequestResult<PaginatedResult<Subject>>> getSubjects({int page = 1, int limit = 50}) async => pagesByNumber![page]!;

  @override
  Future<RequestResult<List<Subject>>> getAllSubjects() async => getAllSubjectsResult!;

  @override
  Future<RequestResult<T>> execute<T, TM>(request, {converter}) => throw UnimplementedError();

  @override
  RequestResult<T> executeSync<T, TM>(request, {converter}) => throw UnimplementedError();
}

const _subject1 = Subject(id: 'sub1', name: 'رياضيات');
const _subject2 = Subject(id: 'sub2', name: 'فيزياء');

void main() {
  late _FakeSubjectsRepository repository;

  setUp(() {
    repository = _FakeSubjectsRepository();
  });

  blocTest<SubjectsCubit, SubjectsState>(
    'getSubjects: emits [loading, success] with page 1 and its pagination',
    build: () {
      repository.pagesByNumber = {
        1: SuccessResult(PaginatedResult([_subject1], _pagination(page: 1, total: 1, totalPages: 1))),
      };
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.getSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.status, 'status', Status.loading),
      isA<SubjectsState>()
          .having((s) => s.status, 'status', Status.success)
          .having((s) => s.subjects, 'subjects', [_subject1])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'getSubjects: an empty page 1 maps to Status.empty',
    build: () {
      repository.pagesByNumber = {1: SuccessResult(PaginatedResult(const [], _pagination(page: 1, total: 0)))};
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.getSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.status, 'status', Status.loading),
      isA<SubjectsState>().having((s) => s.status, 'status', Status.empty),
    ],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'getSubjects: emits [loading, failure] on a repository failure',
    build: () {
      repository.pagesByNumber = {1: const FailureResult(NetworkFailure('offline', 400))};
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.getSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.status, 'status', Status.loading),
      isA<SubjectsState>().having((s) => s.status, 'status', Status.failure).having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'loadMoreSubjects: appends page 2 to the already-loaded page 1',
    seed: () => SubjectsState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..subjects = [_subject1]
        ..pagination = _pagination(page: 1, total: 2, totalPages: 2, hasNextPage: true),
    ),
    build: () {
      repository.pagesByNumber = {
        2: SuccessResult(PaginatedResult([_subject2], _pagination(page: 2, total: 2, totalPages: 2, hasNextPage: false))),
      };
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.loadMoreSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
      isA<SubjectsState>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', false)
          .having((s) => s.subjects, 'subjects', [_subject1, _subject2])
          .having((s) => s.pagination?.hasNextPage, 'hasNextPage', false),
    ],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'loadMoreSubjects: no-ops once hasNextPage is false (end of list)',
    seed: () => SubjectsState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..subjects = [_subject1]
        ..pagination = _pagination(page: 1, total: 1, totalPages: 1, hasNextPage: false),
    ),
    build: () => SubjectsCubit(repository),
    act: (cubit) => cubit.loadMoreSubjects(),
    expect: () => <SubjectsState>[],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'loadMoreSubjects: a failed next page keeps the already-loaded list on screen',
    seed: () => SubjectsState.initial().rebuild(
      (b) => b
        ..status = Status.success
        ..subjects = [_subject1]
        ..pagination = _pagination(page: 1, total: 2, totalPages: 2, hasNextPage: true),
    ),
    build: () {
      repository.pagesByNumber = {2: const FailureResult(NetworkFailure('offline', 400))};
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.loadMoreSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.isLoadingMore, 'isLoadingMore', true),
      isA<SubjectsState>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', false)
          .having((s) => s.subjects, 'subjects', [_subject1])
          .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<SubjectsCubit, SubjectsState>(
    'searchSubjects: fetches the complete list via getAllSubjects, not just page 1',
    build: () {
      repository.getAllSubjectsResult = const SuccessResult([_subject1, _subject2]);
      return SubjectsCubit(repository);
    },
    act: (cubit) => cubit.searchSubjects(),
    expect: () => [
      isA<SubjectsState>().having((s) => s.status, 'status', Status.loading).having((s) => s.isSearching, 'isSearching', true),
      isA<SubjectsState>()
          .having((s) => s.status, 'status', Status.success)
          .having((s) => s.subjects, 'subjects', [_subject1, _subject2])
          .having((s) => s.pagination, 'pagination', isNull),
    ],
  );
}
