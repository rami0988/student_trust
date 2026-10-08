import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final int? statusCode;
  final String statusMessage;

  /// The backend's per-request correlation id, forwarded from the
  /// [GenericExceptions] that produced this failure — see `ErrorHandler`.
  /// Kept out of [props] so existing equality-based assertions
  /// (`ServerFailure('x', 500) == ServerFailure('x', 500)`) don't start
  /// failing just because one side happens to carry a requestId and the
  /// other doesn't.
  final String? requestId;

  const Failure(this.statusMessage, this.statusCode, [this.requestId]);

  @override
  List<Object?> get props => [statusCode, statusMessage];
}

class ServerFailure extends Failure {
  const ServerFailure(super.statusMessage, super.statusCode, [super.requestId]);

  @override
  String toString() {
    return 'ServerFailure{statusMessage: $statusMessage, statusCode: $statusCode, requestId: $requestId}';
  }
}

class CacheFailure extends Failure {
  const CacheFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'CacheFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'GeneralFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class ParsingJsonFailure extends Failure {
  const ParsingJsonFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'ParsingJsonFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'NetworkFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'PermissionFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

// NOTE(migration): the backend returns specific `code` values in error
// bodies that OLD app mapped to tailored failures (single-device login
// enforcement, subscription checks, BunnyCDN transcoding state, offline
// revalidation). See ErrorHandler.handleFailureError's code detection.

class DeviceMismatchFailure extends Failure {
  const DeviceMismatchFailure([super.statusMessage = 'تم تسجيل الدخول من جهاز آخر. تواصل مع الإدارة', super.statusCode]);
}

class AccountInactiveFailure extends Failure {
  const AccountInactiveFailure([super.statusMessage = 'تم إيقاف حسابك. تواصل مع الإدارة', super.statusCode]);
}

class NotSubscribedFailure extends Failure {
  const NotSubscribedFailure([super.statusMessage = 'أنت غير مشترك في هذه المادة', super.statusCode]);
}

/// The video is still transcoding on BunnyCDN — retry in a bit.
class VideoProcessingFailure extends Failure {
  const VideoProcessingFailure([super.statusMessage = 'الفيديو قيد المعالجة\nحاول مرة أخرى بعد قليل', super.statusCode]);
}

/// The device doesn't have room for the download (checked before starting
/// and while writing). Freeing space and resuming continues from the partial.
class InsufficientStorageFailure extends Failure {
  const InsufficientStorageFailure([super.statusMessage = 'لا توجد مساحة كافية على الجهاز', super.statusCode]);
}

/// No internet at all — the download is waiting, not failed, and resumes by
/// itself when the connection returns.
class NetworkUnavailableFailure extends Failure {
  const NetworkUnavailableFailure([super.statusMessage = 'بانتظار الاتصال بالإنترنت', super.statusCode]);
}

/// The offline copy passed its total lifetime (30 days) and was removed.
class LicenseExpiredFailure extends Failure {
  const LicenseExpiredFailure([super.statusMessage = 'انتهت صلاحية التنزيل، أعد تنزيل الدرس', super.statusCode]);
}

/// The downloaded media is damaged (missing, truncated or undecryptable
/// chunks) and has been removed so it can be downloaded again.
class MediaCorruptedFailure extends Failure {
  const MediaCorruptedFailure([super.statusMessage = 'الملف المحمّل تالف، أعد تنزيل الدرس', super.statusCode]);
}

/// The offline download's 7-day grace window expired and re-validation
/// failed (or there was no connection to attempt it).
class ValidationRequiredFailure extends Failure {
  const ValidationRequiredFailure([super.statusMessage = 'يجب الاتصال بالإنترنت للتحقق من الاشتراك', super.statusCode]);
}
