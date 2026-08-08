import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_template/core/error/error_handler.dart';
import 'package:mobile_template/core/error/exceptions.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/generated/l10n.dart';

/// ErrorHandler is the single place exceptions (thrown below the repository)
/// become failures (returned above it), so both directions are covered here.
void main() {
  setUpAll(() async {
    // ErrorHandler falls back to S.current for default messages.
    await S.load(const Locale('en'));
  });

  final RequestOptions requestOptions = RequestOptions(path: '/example-items');

  group('handleExceptionError', () {
    test('maps a DioException carrying a response body to a ServerException', () {
      final error = DioException(
        requestOptions: requestOptions,
        response: Response<Map<String, dynamic>>(
          requestOptions: requestOptions,
          statusCode: 422,
          data: const {'success': false, 'message': 'Validation failed'},
        ),
      );

      final result = ErrorHandler.handleExceptionError(error);

      expect(result, isA<ServerException>());
      expect(result.exceptionMessage, 'Validation failed');
      expect(result.exceptionCode, 422);
    });

    test('maps connection/timeout DioExceptions to a NetworkException', () {
      for (final type in [
        DioExceptionType.connectionError,
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        final result = ErrorHandler.handleExceptionError(
          DioException(requestOptions: requestOptions, type: type),
        );

        expect(result, isA<NetworkException>(), reason: 'for $type');
      }
    });

    test('maps a CheckedFromJsonException to a ParsingJsonException', () {
      final result = ErrorHandler.handleExceptionError(
        CheckedFromJsonException(const {}, 'id', 'ExampleItemModel', 'not an int'),
      );

      expect(result, isA<ParsingJsonException>());
      expect((result as ParsingJsonException).className, 'ExampleItemModel');
    });

    test('falls back to GeneralException for unknown errors', () {
      expect(
        ErrorHandler.handleExceptionError(StateError('boom')),
        isA<GeneralException>(),
      );
    });
  });

  group('handleFailureError', () {
    test('maps each exception type to its matching failure, preserving code', () {
      expect(
        ErrorHandler.handleFailureError(ServerException('down', 500)),
        const ServerFailure('down', 500),
      );
      expect(
        ErrorHandler.handleFailureError(NetworkException('offline')),
        const NetworkFailure('offline', 400),
      );
      expect(
        ErrorHandler.handleFailureError(CacheException('no cache')),
        isA<CacheFailure>(),
      );
      expect(
        ErrorHandler.handleFailureError(ParsingJsonException('Model', 'bad')),
        isA<ParsingJsonFailure>(),
      );
    });

    test('substitutes a localized message when the exception carries none', () {
      final failure = ErrorHandler.handleFailureError(ServerException(null, 500));

      expect(failure, isA<ServerFailure>());
      expect(failure.statusMessage, isNotEmpty);
    });

    test('falls back to GeneralFailure for unknown errors', () {
      expect(
        ErrorHandler.handleFailureError(StateError('boom')),
        isA<GeneralFailure>(),
      );
    });
  });
}
