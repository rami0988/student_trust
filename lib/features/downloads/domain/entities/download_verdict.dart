import 'package:equatable/equatable.dart';

/// The server's answer for one downloaded lesson during batch revalidation.
class DownloadVerdict extends Equatable {
  final bool isValid;

  /// Why it isn't valid: `NOT_SUBSCRIBED`, `GRADE_ACCESS_DENIED` or
  /// `LESSON_NOT_FOUND`. Null when valid.
  final String? reason;

  const DownloadVerdict({required this.isValid, this.reason});

  /// The student is definitively no longer entitled to keep this lesson.
  bool get isRevoked => !isValid && reason != null;

  @override
  List<Object?> get props => [isValid, reason];
}
