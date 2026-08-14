import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/progress.dart';

part 'progress_model.g.dart';

@JsonSerializable(createToJson: false, checked: true)
class ProgressModel {
  @JsonKey(name: 'positionSeconds', readValue: _readPositionSeconds, defaultValue: 0)
  final int positionSeconds;
  @JsonKey(name: 'isCompleted', readValue: _readIsCompleted, defaultValue: false)
  final bool isCompleted;

  ProgressModel({required this.positionSeconds, required this.isCompleted});

  factory ProgressModel.fromJson(Map<String, dynamic> json) => _$ProgressModelFromJson(json);

  static ProgressModel empty() => ProgressModel(positionSeconds: 0, isCompleted: false);

  Progress toDomain() => Progress(positionSeconds: positionSeconds, isCompleted: isCompleted);

  static Object? _readPositionSeconds(Map json, String key) =>
      _asInt(json['positionSeconds'] ?? json['position_seconds']);

  static Object? _readIsCompleted(Map json, String key) => json['isCompleted'] == true || json['is_completed'] == true;

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
