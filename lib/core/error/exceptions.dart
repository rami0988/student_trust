import '../../generated/l10n.dart';

abstract class GenericExceptions implements Exception {
  final String? exceptionMessage;
  final int? exceptionCode;

  /// The backend's per-request correlation id (`routeErrorHandler`'s
  /// `req.id`), when the error body carried one. Only [ServerException]
  /// actually has a response body to read it from — see
  /// `ErrorHandler.handleExceptionError`. Threaded through to [toString] so
  /// it lands in the existing `Logger.error` call at the repository
  /// boundary (`BaseRepositoryImpl.execute`) without any extra plumbing.
  final String? requestId;

  const GenericExceptions(this.exceptionMessage, this.exceptionCode, [this.requestId]);
}

class ServerException extends GenericExceptions {
  ServerException(super.exceptionMessage, super.exceptionCode, [super.requestId]);

  @override
  String toString() {
    return 'ServerException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode, requestId: $requestId}';
  }
}

class CacheException extends GenericExceptions {
  CacheException(
    String? exceptionMessage,
  ) : super(exceptionMessage, 404);

  @override
  String toString() {
    return 'CacheException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class GeneralException extends GenericExceptions {
  GeneralException() : super(S.current.oopsSomethingWentWrongPleaseTryAgain, 404);

  @override
  String toString() {
    return 'GeneralException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class NetworkException extends GenericExceptions {
  NetworkException(String? exceptionMessage) : super(exceptionMessage, 400);

  @override
  String toString() {
    return 'NetworkException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class ParsingJsonException extends GenericExceptions {
  final String? className;

  ParsingJsonException(this.className, String? exceptionMessage) : super(exceptionMessage, null);

  @override
  String toString() {
    return 'ParsingJsonException{className: $className, exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

// NOTE(migration): backend-specific error `code` values — see
// ErrorHandler.handleExceptionError's code detection and failures.dart.

class DeviceMismatchException extends GenericExceptions {
  DeviceMismatchException() : super('تم تسجيل الدخول من جهاز آخر. تواصل مع الإدارة', 403);
}

class AccountInactiveException extends GenericExceptions {
  AccountInactiveException() : super('تم إيقاف حسابك. تواصل مع الإدارة', 403);
}

class NotSubscribedException extends GenericExceptions {
  NotSubscribedException() : super('أنت غير مشترك في هذه المادة', 403);
}

/// The lesson's video is still transcoding on BunnyCDN (backend code
/// VIDEO_PROCESSING) — not an error, just "try again in a bit".
class VideoProcessingException extends GenericExceptions {
  VideoProcessingException() : super('الفيديو قيد المعالجة، حاول لاحقاً', null);
}

class ValidationRequiredException extends GenericExceptions {
  ValidationRequiredException() : super('VALIDATION_REQUIRED', null);
}
