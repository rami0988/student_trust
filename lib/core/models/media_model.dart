import 'package:json_annotation/json_annotation.dart';

import '../entities/media.dart';
import '../extensions/strings.dart';
import '../utils/app_enums.dart';

part 'media_model.g.dart';

@JsonSerializable(createToJson: false, checked: true)
class MediaModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  @JsonKey(name: 'size')
  final num? size;
  @JsonKey(name: 'original')
  final String original;

  MediaModel({
    required this.id,
    this.name,
    this.fileName,
    this.mimeType,
    this.size,
    required this.original,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => _$MediaModelFromJson(json);

  Media toDomain() => Media(
    id: id,
    url: original,
    type: MediaType.fromValue(original.fileExtension),
  );
}
