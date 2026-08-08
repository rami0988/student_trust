import 'dart:async';

import '../error/error_handler.dart';
import '../error/failures.dart';
import '../utils/logger.dart';
import '../utils/request_result.dart';
import 'base_repository.dart';

class BaseRepositoryImpl extends BaseRepository {
  final String _repoName;

  BaseRepositoryImpl(this._repoName);

  @override
  Future<RequestResult<T>> execute<T, TM>(
    FutureOr<TM> Function() apiRequest, {
    FutureOr<T> Function(TM)? converter,
  }) async {
    try {
      final TM result = await apiRequest();
      if (converter != null) {
        final T convertedResult = await converter(result);
        return SuccessResult(convertedResult);
      }
      return SuccessResult(result as T);
    } catch (error, stackTrace) {
      Logger.error(
        name: _repoName,
        "Error: execute function",
        stackTrace: stackTrace,
        error: error,
      );
      final Failure failure = ErrorHandler.handleFailureError(error);
      return FailureResult(failure);
    }
  }

  @override
  RequestResult<T> executeSync<T, TM>(
    TM Function() request, {
    T Function(TM)? converter,
  }) {
    try {
      final TM result = request();
      if (converter != null) {
        final T convertedResult = converter(result);
        return SuccessResult(convertedResult);
      }
      return SuccessResult(result as T);
    } catch (error, stackTrace) {
      Logger.error(
        name: _repoName,
        "Error: execute function",
        stackTrace: stackTrace,
        error: error,
      );
      final Failure failure = ErrorHandler.handleFailureError(error);
      return FailureResult(failure);
    }
  }
}
