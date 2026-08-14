import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/subject.dart';

part 'subject_model.g.dart';

/// Raw DB row shape (bilingual columns, no envelope — see
/// core/network/endpoints.dart NOTE(migration)). The app is Arabic-first so
/// prefers `_ar` columns, then `_en`, then any legacy flat key.
@JsonSerializable(createToJson: false, checked: true)
class SubjectModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'name_ar', readValue: _readName)
  final String name;
  @JsonKey(name: 'description_ar', readValue: _readDescription)
  final String? description;
  @JsonKey(name: 'thumbnail_url', readValue: _readThumbnailUrl)
  final String? thumbnailUrl;
  @JsonKey(name: 'teacher_name', readValue: _readTeacherName)
  final String? teacherName;
  @JsonKey(name: 'grade')
  final String? grade;
  @JsonKey(name: 'is_subscribed', readValue: _readIsSubscribed, defaultValue: false)
  final bool isSubscribed;

  SubjectModel({
    required this.id,
    required this.name,
    required this.isSubscribed,
    this.description,
    this.thumbnailUrl,
    this.teacherName,
    this.grade,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => _$SubjectModelFromJson(json);

  Subject toDomain() => Subject(
    id: id,
    name: name,
    description: description,
    thumbnailUrl: thumbnailUrl,
    teacherName: teacherName,
    grade: grade,
    isSubscribed: isSubscribed,
  );

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readName(Map json, String key) =>
      (json['name_ar'] ?? json['name_en'] ?? json['name'] ?? json['title'] ?? '').toString();

  static Object? _readDescription(Map json, String key) => (json['description_ar'] ?? json['description'])?.toString();

  static Object? _readThumbnailUrl(Map json, String key) =>
      (json['thumbnail_url'] ?? json['cover_image_url'] ?? json['thumbnailUrl'])?.toString();

  static Object? _readTeacherName(Map json, String key) => (json['teacher_name'] ?? json['teacherName'])?.toString();

  static Object? _readIsSubscribed(Map json, String key) => json['isSubscribed'] == true || json['is_subscribed'] == true;
}
