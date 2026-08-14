import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/worksheet_file.dart';

part 'worksheet_file_model.g.dart';

/// A PDF file of a worksheet — freely viewable and downloadable.
@JsonSerializable(createToJson: false, checked: true)
class WorksheetFileModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  @JsonKey(name: 'worksheet_id', readValue: _readWorksheetId)
  final String worksheetId;
  @JsonKey(name: 'file_name', readValue: _readFileName)
  final String fileName;
  @JsonKey(name: 'url')
  final String url;
  @JsonKey(name: 'file_size_kb', readValue: _readFileSizeKb, defaultValue: 0)
  final int fileSizeKb;

  WorksheetFileModel({
    required this.id,
    required this.worksheetId,
    required this.fileName,
    required this.url,
    required this.fileSizeKb,
  });

  factory WorksheetFileModel.fromJson(Map<String, dynamic> json) => _$WorksheetFileModelFromJson(json);

  WorksheetFile toDomain() =>
      WorksheetFile(id: id, worksheetId: worksheetId, fileName: fileName, url: url, fileSizeKb: fileSizeKb);

  static Object? _readId(Map json, String key) => json['id']?.toString() ?? '';

  static Object? _readWorksheetId(Map json, String key) => (json['worksheetId'] ?? json['worksheet_id'])?.toString() ?? '';

  static Object? _readFileName(Map json, String key) => (json['fileName'] ?? json['file_name'] ?? '').toString();

  static Object? _readFileSizeKb(Map json, String key) => _asInt(json['fileSizeKb'] ?? json['file_size_kb']);

  static int _asInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
}
