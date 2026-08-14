import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chapter.dart';

part 'chapter_model.g.dart';

/// Raw DB row shape (bilingual columns, no envelope — see
/// core/network/endpoints.dart NOTE(migration)).
@JsonSerializable(createToJson: false, checked: true)
class ChapterModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'subject_id', readValue: _readSubjectId)
  final String subjectId;
  @JsonKey(name: 'title_ar', readValue: _readTitle)
  final String title;
  @JsonKey(name: 'sort_order', readValue: _readSortOrder, defaultValue: 0)
  final int sortOrder;
  @JsonKey(name: 'grade')
  final String? grade;
  @JsonKey(name: 'worksheets', readValue: _readWorksheetCount, defaultValue: 0)
  final int worksheetCount;

  ChapterModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.sortOrder,
    required this.worksheetCount,
    this.grade,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) => _$ChapterModelFromJson(json);

  Chapter toDomain() =>
      Chapter(id: id, subjectId: subjectId, title: title, sortOrder: sortOrder, grade: grade, worksheetCount: worksheetCount);

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readSubjectId(Map json, String key) => (json['subject_id'] ?? json['subjectId'])?.toString() ?? '';

  static Object? _readTitle(Map json, String key) =>
      (json['title_ar'] ?? json['title_en'] ?? json['title'] ?? json['name'] ?? '').toString();

  static Object? _readSortOrder(Map json, String key) => _asInt(json['sort_order'] ?? json['sortOrder']);

  /// PostgREST count embeds arrive as `[{count: n}]`.
  static Object? _readWorksheetCount(Map json, String key) {
    final dynamic worksheets = json['worksheets'];
    if (worksheets is List && worksheets.isNotEmpty && worksheets.first is Map) {
      return _asInt((worksheets.first as Map)['count']);
    }
    return _asInt(json['worksheetCount'] ?? json['worksheet_count']);
  }

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
