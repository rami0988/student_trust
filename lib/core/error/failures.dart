import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final int? statusCode;
  final String statusMessage;

  const Failure(this.statusMessage, this.statusCode);

  @override
  List<Object?> get props => [statusCode, statusMessage];
}

class ServerFailure extends Failure {
  const ServerFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'ServerFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
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

/// The offline download's 7-day grace window expired and re-validation
/// failed (or there was no connection to attempt it).
class ValidationRequiredFailure extends Failure {
  const ValidationRequiredFailure([super.statusMessage = 'يجب الاتصال بالإنترنت للتحقق من الاشتراك', super.statusCode]);
}
