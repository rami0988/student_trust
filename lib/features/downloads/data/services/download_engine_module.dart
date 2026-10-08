import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'download_engine.dart';
import 'native_download_engine.dart';

/// Picks the [DownloadEngine] the app runs on.
///
/// Production Android/iOS use [NativeDownloadEngine] (OS background transfer:
/// survives backgrounding and app kills). Everything else — desktop, tests —
/// uses [DartDownloadEngine]. Building with `--dart-define=DOWNLOAD_ENGINE=dart`
/// forces the in-process engine on a phone too, for debugging.
abstract final class DownloadEngineChoice {
  static const String _override = String.fromEnvironment('DOWNLOAD_ENGINE');

  static bool get useNative {
    if (_override == 'dart') return false;
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}

@module
abstract class DownloadEngineModule {
  @lazySingleton
  DownloadEngine downloadEngine(DartDownloadEngine dart, NativeDownloadEngine native) =>
      DownloadEngineChoice.useNative ? native : dart;
}
