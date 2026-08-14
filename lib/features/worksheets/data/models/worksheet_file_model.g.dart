// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksheet_file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorksheetFileModel _$WorksheetFileModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WorksheetFileModel',
      json,
      ($checkedConvert) {
        final val = WorksheetFileModel(
          id: $checkedConvert(
            'id',
            (v) => v as String,
            readValue: WorksheetFileModel._readId,
          ),
          worksheetId: $checkedConvert(
            'worksheet_id',
            (v) => v as String,
            readValue: WorksheetFileModel._readWorksheetId,
          ),
          fileName: $checkedConvert(
            'file_name',
            (v) => v as String,
            readValue: WorksheetFileModel._readFileName,
          ),
          url: $checkedConvert('url', (v) => v as String),
          fileSizeKb: $checkedConvert(
            'file_size_kb',
            (v) => (v as num?)?.toInt() ?? 0,
            readValue: WorksheetFileModel._readFileSizeKb,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'worksheetId': 'worksheet_id',
        'fileName': 'file_name',
        'fileSizeKb': 'file_size_kb',
      },
    );
