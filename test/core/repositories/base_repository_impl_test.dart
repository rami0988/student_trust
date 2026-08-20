import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/error/exceptions.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/models/pagination_model.dart';
import 'package:mobile_template/core/models/paginated_result.dart';
import 'package:mobile_template/core/repositories/base_repository_impl.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/generated/l10n.dart';

PaginationModel _pagination({
  required int page,
  required bool hasNextPage,
  int limit = 100,
  int total = 0,
  int totalPages = 1,
}) => PaginationModel(page: page, limit: limit, total: total, totalPages: totalPages, hasNextPage: hasNextPage, hasPrevPage: page > 1);

/// `execute` is the only place an exception becomes a failure — the boundary the
/// whole architecture depends on. Nothing thrown below it may escape upward.
void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  final BaseRepositoryImpl repository = BaseRepositoryImpl('TestRepository');

  group('execute', () {
    test('returns the raw value as SuccessResult when no converter is given', () async {
      final result = await repository.execute<int, int>(() => 42);

      expect(result.isSuccess, isTrue);
      expect(result.fold(success: (d) => d, failure: (_) => -1), 42);
    });

    test('applies the converter on success', () async {
      final result = await repository.execute<String, int>(
        () => 7,
        converter: (value) => 'value=$value',
      );

      expect(result.fold(success: (d) => d, failure: (_) => ''), 'value=7');
    });

    test('converts a thrown ServerException into a ServerFailure', () async {
      final result = await repository.execute<int, int>(
        () => throw ServerException('server down', 500),
      );

      expect(result.isFailure, isTrue);
      final Failure failure = (result as FailureResult<int>).failure;
      expect(failure, const ServerFailure('server down', 500));
    });

    test('catches exceptions thrown by the converter, not just the request', () async {
      final result = await repository.execute<int, int>(
        () => 1,
        converter: (_) => throw ServerException('mapping failed', 500),
      );

      expect(result.isFailure, isTrue);
    });

    test('never lets an arbitrary error escape the boundary', () async {
      final result = await repository.execute<int, int>(
        () => throw StateError('unexpected'),
      );

      expect(result.isFailure, isTrue);
      expect((result as FailureResult<int>).failure, isA<GeneralFailure>());
    });

    test('awaits asynchronous requests', () async {
      final result = await repository.execute<int, int>(
        () async => Future<int>.delayed(const Duration(milliseconds: 10), () => 5),
      );

      expect(result.fold(success: (d) => d, failure: (_) => -1), 5);
    });
  });

  group('executeAllPages', () {
    test('loops every page (hasNextPage) and concatenates the converted items', () async {
      int calls = 0;
      final result = await repository.executeAllPages<String, int>(
        (page) async {
          calls++;
          if (page == 1) return PaginatedResult([1, 2], _pagination(page: 1, hasNextPage: true, total: 3));
          return PaginatedResult([3], _pagination(page: 2, hasNextPage: false, total: 3));
        },
        converter: (n) => 'item$n',
      );

      expect(result.isSuccess, isTrue);
      expect(result.fold(success: (d) => d, failure: (_) => const <String>[]), ['item1', 'item2', 'item3']);
      expect(calls, 2);
    });

    test('stops after a single page when hasNextPage is false', () async {
      int calls = 0;
      final result = await repository.executeAllPages<int, int>(
        (page) async {
          calls++;
          return PaginatedResult(const [], _pagination(page: 1, hasNextPage: false));
        },
        converter: (n) => n,
      );

      expect(result.fold(success: (d) => d, failure: (_) => const <int>[]), isEmpty);
      expect(calls, 1);
    });

    test('a failure mid-loop becomes a FailureResult', () async {
      final result = await repository.executeAllPages<int, int>(
        (page) => throw ServerException('server down', 500),
        converter: (n) => n,
      );

      expect(result.isFailure, isTrue);
      expect((result as FailureResult<List<int>>).failure, isA<ServerFailure>());
    });
  });

  group('executeSync', () {
    test('returns a SuccessResult for a value', () {
      final result = repository.executeSync<String, int>(
        () => 3,
        converter: (value) => '$value items',
      );

      expect(result.fold(success: (d) => d, failure: (_) => ''), '3 items');
    });

    test('converts a thrown CacheException into a CacheFailure', () {
      final result = repository.executeSync<int, int>(
        () => throw CacheException('cache miss'),
      );

      expect(result.isFailure, isTrue);
      expect((result as FailureResult<int>).failure, isA<CacheFailure>());
    });
  });
}
