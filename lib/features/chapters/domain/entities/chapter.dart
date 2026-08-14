import 'package:equatable/equatable.dart';

class Chapter extends Equatable {
  final String id;
  final String subjectId;
  final String title;
  final int sortOrder;
  final String? grade;

  /// Number of PUBLISHED worksheets — backend embeds a filtered
  /// `worksheets(count)` on the student chapters endpoint.
  final int worksheetCount;

  const Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    this.sortOrder = 0,
    this.grade,
    this.worksheetCount = 0,
  });

  @override
  List<Object?> get props => [id, subjectId, title, sortOrder, grade, worksheetCount];
}
