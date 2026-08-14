import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/worksheet_file_model.dart';
import '../models/worksheet_model.dart';
import '../models/worksheet_video_model.dart';
import 'worksheets_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
///
/// PDF downloads use a bare, unconfigured [Dio] (not the injected one): the
/// CDN storage URLs are public and must not receive the app's auth headers
/// or its `Endpoints.baseURL` prefix.
@LazySingleton(as: WorksheetsRemoteDataSource)
class WorksheetsRemoteDataSourceImpl implements WorksheetsRemoteDataSource {
  final Dio _dio;

  WorksheetsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<WorksheetModel>> getWorksheets(String chapterId) async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.worksheetsByChapter(chapterId));
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => WorksheetModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<List<WorksheetFileModel>> getFiles(String worksheetId) async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.worksheetFiles(worksheetId));
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => WorksheetFileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<List<WorksheetVideoModel>> getVideos(String worksheetId) async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.worksheetVideos(worksheetId));
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => WorksheetVideoModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  static String _safeName(String fileName) => fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  @override
  Future<String> downloadPdfToCache(String url, String fileName) async {
    try {
      final Directory dir = await getTemporaryDirectory();
      final String path = '${dir.path}${Platform.pathSeparator}${_safeName(fileName)}';
      final File file = File(path);
      if (await file.exists() && await file.length() > 0) return path;
      await Dio().download(url, path);
      return path;
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<String> downloadPdfToDevice(
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final String safeName = _safeName(fileName);

      if (Platform.isAndroid) {
        // Legacy storage permission is only required (and grantable) up to
        // Android 9; from 10 the MediaStore path below needs no permission.
        final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt <= 28) {
          final PermissionStatus status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission is required to save the file');
          }
        }

        // 1) Download into the app temp cache (no special permissions).
        final Directory tmpDir = await getTemporaryDirectory();
        final String tmpPath = '${tmpDir.path}${Platform.pathSeparator}$safeName';
        await Dio().download(
          url,
          tmpPath,
          onReceiveProgress: (received, total) => onProgress?.call(received, total),
        );

        // 2) Publish it into the system Downloads collection via MediaStore
        // (native side), so it actually appears in the device's Downloads
        // app — a raw file write into /Download is not indexed on many ROMs.
        // NOTE(migration): relies on the 'saveToDownloads' handler on the
        // 'com.edushield/security' native channel (see SecurityService) —
        // verify it's present once native config is merged (task #14).
        const MethodChannel channel = MethodChannel('com.edushield/security');
        final String? savedPath = await channel.invokeMethod<String>('saveToDownloads', {
          'path': tmpPath,
          'fileName': safeName,
          'mime': 'application/pdf',
        });

        // Clean up the temp copy; keep it as a fallback result if the
        // channel returned nothing.
        if (savedPath != null && savedPath.isNotEmpty) {
          try {
            File(tmpPath).deleteSync();
          } catch (_) {}
          return savedPath;
        }
        return tmpPath;
      }

      // iOS/other: save into the app documents folder (visible via Files app).
      final Directory downloadsDir = await getApplicationDocumentsDirectory();
      final String savePath = '${downloadsDir.path}${Platform.pathSeparator}$safeName';
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) => onProgress?.call(received, total),
      );
      return savePath;
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
