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
    } else if (error is DeviceMismatchException) {
      return DeviceMismatchFailure(error.exceptionMessage ?? '', error.exceptionCode);
    } else if (error is AccountInactiveException) {
      return AccountInactiveFailure(error.exceptionMessage ?? '', error.exceptionCode);
    } else if (error is NotSubscribedException) {
      return NotSubscribedFailure(error.exceptionMessage ?? '', error.exceptionCode);
    } else if (error is VideoProcessingException) {
      return VideoProcessingFailure(error.exceptionMessage ?? '', error.exceptionCode);
    } else if (error is ValidationRequiredException) {
      return ValidationRequiredFailure(error.exceptionMessage ?? '', error.exceptionCode);
    }
    return GeneralFailure(S.current.somethingWentWrong);
  }

  static GenericExceptions handleExceptionError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        final dynamic raw = error.response!.data;
        final String? code = _extractCode(raw);
        // NOTE(migration): raw-JSON backend (see endpoints.dart) sends
        // {code, message} error bodies rather than the {success, message,
        // data} envelope — detect specific backend codes before falling back
        // to a generic ServerException. See failures.dart.
        switch (code) {
          case 'VIDEO_PROCESSING':
            return VideoProcessingException();
          case 'DEVICE_MISMATCH':
            return DeviceMismatchException();
          case 'ACCOUNT_INACTIVE':
            return AccountInactiveException();
          case 'NOT_SUBSCRIBED':
            return NotSubscribedException();
        }
        final BaseModel baseModel = BaseModel.fromJson(raw is Map<String, dynamic> ? raw : <String, dynamic>{});
        return ServerException(baseModel.message ?? _extractMessage(raw), error.response!.statusCode);
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

  static String? _extractCode(dynamic data) {
    if (data is Map) {
      final dynamic code = data['code'] ?? data['errorCode'];
      if (code != null) return code.toString();
    }
    return null;
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final dynamic msg = data['message'] ?? data['error'] ?? data['detail'];
      if (msg != null) return msg.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }
}
