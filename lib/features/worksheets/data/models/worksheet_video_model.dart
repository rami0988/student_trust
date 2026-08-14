import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/worksheet_video.dart';

part 'worksheet_video_model.g.dart';

/// A published solution video (plays through the secure video player).
@JsonSerializable(createToJson: false, checked: true)
class WorksheetVideoModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'worksheet_id', readValue: _readWorksheetId)
  final String worksheetId;
  @JsonKey(name: 'title_ar', readValue: _readTitle)
  final String title;
  @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)
  final String? thumbnailUrl;
  @JsonKey(name: 'duration_seconds', readValue: _readDurationSeconds, defaultValue: 0)
  final int durationSeconds;

  WorksheetVideoModel({
    required this.id,
    required this.worksheetId,
    required this.title,
    required this.durationSeconds,
    this.thumbnailUrl,
  });

  factory WorksheetVideoModel.fromJson(Map<String, dynamic> json) => _$WorksheetVideoModelFromJson(json);

  WorksheetVideo toDomain() =>
      WorksheetVideo(id: id, worksheetId: worksheetId, title: title, thumbnailUrl: thumbnailUrl, durationSeconds: durationSeconds);

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readWorksheetId(Map json, String key) => (json['worksheetId'] ?? json['worksheet_id'])?.toString() ?? '';

  static Object? _readTitle(Map json, String key) => (json['titleAr'] ?? json['title_ar'] ?? '').toString();

  static Object? _readThumbnailUrl(Map json, String key) => (json['thumbnailUrl'] ?? json['thumbnail_url'])?.toString();

  static Object? _readDurationSeconds(Map json, String key) => _asInt(json['durationSeconds'] ?? json['duration_seconds']);

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
