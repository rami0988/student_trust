import 'package:flutter/material.dart';

import '../../models/base_model.dart';

abstract class BaseRemoteDataSource {
  @protected
  Future<BaseModel> performGetRequest({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  });

  @protected
  Future<BaseModel> performPostRequest({
    required String endpoint,
    required dynamic body,
    Map<String, dynamic>? queryParameters,
  });

  @protected
  Future<BaseModel> performPutRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });

  @protected
  Future<BaseModel> performDeleteRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });

  @protected
  Future<BaseModel> performPatchRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  });

  @protected
  Future<void> performDownloadRequest({
    required String endpoint,
    required String downloadPath,
  });
}
