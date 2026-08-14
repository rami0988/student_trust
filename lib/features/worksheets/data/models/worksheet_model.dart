import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/worksheet.dart';

part 'worksheet_model.g.dart';

/// Raw DB row shape (bilingual columns, no envelope — see
/// core/network/endpoints.dart NOTE(migration)).
@JsonSerializable(createToJson: false, checked: true)
class WorksheetModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'chapter_id', readValue: _readChapterId)
  final String chapterId;
  @JsonKey(name: 'title_ar', readValue: _readTitle)
  final String title;
  @JsonKey(name: 'description_ar', readValue: _readDescription)
  final String? description;
  @JsonKey(name: 'filesCount', readValue: _readFilesCount, defaultValue: 0)
  final int filesCount;
  @JsonKey(name: 'videosCount', readValue: _readVideosCount, defaultValue: 0)
  final int videosCount;

  WorksheetModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.filesCount,
    required this.videosCount,
    this.description,
  });

  factory WorksheetModel.fromJson(Map<String, dynamic> json) => _$WorksheetModelFromJson(json);

  Worksheet toDomain() => Worksheet(
    id: id,
    chapterId: chapterId,
    title: title,
    description: description,
    filesCount: filesCount,
    videosCount: videosCount,
  );

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readChapterId(Map json, String key) => (json['chapterId'] ?? json['chapter_id'])?.toString() ?? '';

  static Object? _readTitle(Map json, String key) =>
      (json['titleAr'] ?? json['title_ar'] ?? json['titleEn'] ?? json['title_en'] ?? '').toString();

  static Object? _readDescription(Map json, String key) => (json['descriptionAr'] ?? json['description_ar'])?.toString();

  static Object? _readFilesCount(Map json, String key) => _asInt(json['filesCount'] ?? json['files_count']);

  static Object? _readVideosCount(Map json, String key) => _asInt(json['videosCount'] ?? json['videos_count']);

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
