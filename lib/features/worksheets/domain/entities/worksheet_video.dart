import 'package:equatable/equatable.dart';

class WorksheetVideo extends Equatable {
  final String id;
  final String worksheetId;
  final String title;
  final String? thumbnailUrl;
  final int durationSeconds;

  const WorksheetVideo({
    required this.id,
    required this.worksheetId,
    required this.title,
    this.thumbnailUrl,
    this.durationSeconds = 0,
  });

  @override
  List<Object?> get props => [id, worksheetId, title, thumbnailUrl, durationSeconds];
}
