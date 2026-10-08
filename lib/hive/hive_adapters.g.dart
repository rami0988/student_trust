// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class DownloadRecordStatusAdapter extends TypeAdapter<DownloadRecordStatus> {
  @override
  final typeId = 0;

  @override
  DownloadRecordStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadRecordStatus.queued;
      case 1:
        return DownloadRecordStatus.downloading;
      case 2:
        return DownloadRecordStatus.paused;
      case 3:
        return DownloadRecordStatus.waitingForNetwork;
      case 4:
        return DownloadRecordStatus.failed;
      default:
        return DownloadRecordStatus.queued;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadRecordStatus obj) {
    switch (obj) {
      case DownloadRecordStatus.queued:
        writer.writeByte(0);
      case DownloadRecordStatus.downloading:
        writer.writeByte(1);
      case DownloadRecordStatus.paused:
        writer.writeByte(2);
      case DownloadRecordStatus.waitingForNetwork:
        writer.writeByte(3);
      case DownloadRecordStatus.failed:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRecordStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadRecordAdapter extends TypeAdapter<DownloadRecord> {
  @override
  final typeId = 1;

  @override
  DownloadRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadRecord(
      lessonId: fields[0] as String,
      videoUrl: fields[1] as String,
      title: fields[2] as String,
      durationSeconds: (fields[3] as num).toInt(),
      thumbnailUrl: fields[4] as String?,
      status: fields[5] as DownloadRecordStatus,
      bytesReceived: (fields[6] as num).toInt(),
      totalBytes: (fields[7] as num).toInt(),
      error: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.videoUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.bytesReceived)
      ..writeByte(7)
      ..write(obj.totalBytes)
      ..writeByte(8)
      ..write(obj.error)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
