import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../generated/l10n.dart';
import '../models/base_model.dart';
import 'exceptions.dart';
import 'failures.dart';

abstract class ErrorHandler {
  ErrorHandler._();

  static Failure handleFailureError(dynamic error) {
    if (error is ServerException) {
      return ServerFailure(
        error.exceptionMessage ?? S.current.serverErrorOccurredPleaseTryAgain,
        error.exceptionCode,
      );
    } else if (error is CacheException) {
      return CacheFailure(
        error.exceptionMessage ?? S.current.failedToLoadDataPleaseTryAgain,
      );
    } else if (error is NetworkException) {
      final String message = error.exceptionMessage ?? S.current.thereIsProblemWithYourConnectionPleaseTryAgain;
      return NetworkFailure(message, error.exceptionCode);
    } else if (error is ParsingJsonException) {
      return ParsingJsonFailure(
        '${error.className}: ${error.exceptionMessage}',
      );
    }
    return GeneralFailure(S.current.somethingWentWrong);
  }

  static GenericExceptions handleExceptionError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(error.response!.data);
        return ServerException(baseModel.message, error.response!.statusCode);
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionTimeout) {
        return NetworkException(
          S.current.thereIsProblemWithYourConnectionPleaseTryAgain,
        );
      } else {
        return GeneralException();
      }
    } else if (error is ServerException) {
      return ServerException(error.exceptionMessage, error.exceptionCode);
    } else if (error is CacheException) {
      return CacheException(error.exceptionMessage);
    } else if (error is CheckedFromJsonException) {
      return ParsingJsonException(error.className, error.message);
    } else {
      return GeneralException();
    }
  }
}
