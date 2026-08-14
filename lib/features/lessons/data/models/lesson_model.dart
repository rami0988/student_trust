import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/lesson.dart';
import 'progress_model.dart';

part 'lesson_model.g.dart';

/// Raw DB row shape (bilingual columns, no envelope — see
/// core/network/endpoints.dart NOTE(migration)).
@JsonSerializable(createToJson: false, checked: true)
class LessonModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'chapter_id', readValue: _readChapterId)
  final String chapterId;
  @JsonKey(name: 'title_ar', readValue: _readTitle)
  final String title;
  @JsonKey(name: 'description_ar', readValue: _readDescription)
  final String? description;
  @JsonKey(name: 'duration_seconds', readValue: _readDurationSeconds, defaultValue: 0)
  final int durationSeconds;
  @JsonKey(name: 'sort_order', readValue: _readSortOrder, defaultValue: 0)
  final int sortOrder;
  @JsonKey(name: 'is_published', readValue: _readIsPublished, defaultValue: true)
  final bool isPublished;
  @JsonKey(name: 'bunny_video_id', readValue: _readBunnyVideoId)
  final String? bunnyVideoId;
  // The backend signs and sends the thumbnail URL directly — it token-protects
  // thumbnails with a key only the backend holds, so this must NOT be derived
  // client-side from a hardcoded pull-zone host.
  @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)
  final String? thumbnailUrl;
  @JsonKey(name: 'progress', readValue: _readProgress)
  final ProgressModel progress;

  LessonModel({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.durationSeconds,
    required this.sortOrder,
    required this.isPublished,
    required this.progress,
    this.description,
    this.bunnyVideoId,
    this.thumbnailUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => _$LessonModelFromJson(json);

  Lesson toDomain() => Lesson(
    id: id,
    chapterId: chapterId,
    title: title,
    description: description,
    durationSeconds: durationSeconds,
    sortOrder: sortOrder,
    isPublished: isPublished,
    bunnyVideoId: bunnyVideoId,
    thumbnailUrl: thumbnailUrl,
    progress: progress.toDomain(),
  );

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readChapterId(Map json, String key) => (json['chapter_id'] ?? json['chapterId'])?.toString() ?? '';

  static Object? _readTitle(Map json, String key) =>
      (json['title_ar'] ?? json['title_en'] ?? json['title'] ?? json['name'] ?? '').toString();

  static Object? _readDescription(Map json, String key) => (json['description_ar'] ?? json['description'])?.toString();

  static Object? _readDurationSeconds(Map json, String key) => _asInt(json['duration_seconds'] ?? json['durationSeconds']);

  static Object? _readSortOrder(Map json, String key) => _asInt(json['sort_order'] ?? json['sortOrder']);

  static Object? _readIsPublished(Map json, String key) => json['is_published'] != false && json['isPublished'] != false;

  static Object? _readBunnyVideoId(Map json, String key) => (json['bunny_video_id'] ?? json['bunnyVideoId'])?.toString();

  static Object? _readThumbnailUrl(Map json, String key) => (json['thumbnail_url'] ?? json['thumbnailUrl'])?.toString();

  static Object? _readProgress(Map json, String key) =>
      json['progress'] is Map ? (json['progress'] as Map).cast<String, dynamic>() : <String, dynamic>{};

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
