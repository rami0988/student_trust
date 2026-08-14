import 'package:equatable/equatable.dart';

class WorksheetFile extends Equatable {
  final String id;
  final String worksheetId;
  final String fileName;
  final String url;
  final int fileSizeKb;

  const WorksheetFile({
    required this.id,
    required this.worksheetId,
    required this.fileName,
    required this.url,
    this.fileSizeKb = 0,
  });

  /// Human-readable size, e.g. "3.2 MB" / "540 KB".
  String get sizeLabel {
    if (fileSizeKb >= 1024) {
      return '${(fileSizeKb / 1024).toStringAsFixed(1)} MB';
    }
    return '$fileSizeKb KB';
  }

  @override
  List<Object?> get props => [id, worksheetId, fileName, url, fileSizeKb];
}
