import 'dart:async';

import '../error/error_handler.dart';
import '../error/failures.dart';
import '../models/paginated_result.dart';
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

  /// Loops every page of a paginated data-source call — bumping `page` while
  /// `pagination.hasNextPage` is true — and concatenates the converted items
  /// into one list.
  ///
  /// For a caller that needs the *complete* collection from an endpoint that
  /// is paginated server-side but has no server-side search: currently only
  /// the subjects search box (`SubjectsCubit.searchSubjects`), since a query
  /// that must reach further than whatever page happens to be loaded has no
  /// other way to see the rest of the results. Callers should pass a
  /// generous `limit` (e.g. the backend's page-size cap) to keep the
  /// round-trip count down.
  Future<RequestResult<List<T>>> executeAllPages<T, TM>(
    Future<PaginatedResult<TM>> Function(int page) apiRequest, {
    required T Function(TM) converter,
  }) async {
    try {
      final List<T> all = [];
      int page = 1;
      while (true) {
        final PaginatedResult<TM> result = await apiRequest(page);
        all.addAll(result.items.map(converter));
        if (!result.pagination.hasNextPage) break;
        page++;
      }
      return SuccessResult<List<T>>(all);
    } catch (error, stackTrace) {
      Logger.error(
        name: _repoName,
        "Error: executeAllPages function",
        stackTrace: stackTrace,
        error: error,
      );
      final Failure failure = ErrorHandler.handleFailureError(error);
      return FailureResult<List<T>>(failure);
    }
  }
}
