import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/error/exceptions.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/repositories/base_repository_impl.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/generated/l10n.dart';

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
