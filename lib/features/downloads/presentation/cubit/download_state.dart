import 'package:built_value/built_value.dart';

import '../../domain/entities/download_item.dart';

part 'download_state.g.dart';

/// App-wide download state: a snapshot of every lesson the app has touched
/// this session, keyed by lessonId. Persistent "already downloaded" lessons
/// that predate this session are read via [EncryptedDownloadService] instead.
abstract class DownloadState implements Built<DownloadState, DownloadStateBuilder> {
  Map<String, DownloadItem> get items;

  DownloadState._();
  factory DownloadState([void Function(DownloadStateBuilder) updates]) = _$DownloadState;

  factory DownloadState.initial() => DownloadState((b) => b..items = {});

  DownloadItem? of(String lessonId) => items[lessonId];
}
