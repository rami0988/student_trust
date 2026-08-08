import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../generated/l10n.dart';
import '../../error/error_handler.dart';
import '../../error/exceptions.dart';
import '../../models/base_model.dart';
import 'base_remote_data_source.dart';

@LazySingleton(as: BaseRemoteDataSource)
class BaseRemoteDataSourceImpl extends BaseRemoteDataSource {
  final Dio _dio;
  BaseRemoteDataSourceImpl(this._dio);

  @override
  Future<BaseModel> performGetRequest({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      if (response.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(response.data!);
        if (response.statusCode == 200 && baseModel.success != false) {
          return baseModel;
        } else {
          throw ServerException(baseModel.message, response.statusCode);
        }
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<BaseModel> performPostRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.post(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      if (response.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(response.data!);
        if ((response.statusCode == 200 || response.statusCode == 201) && baseModel.success != false) {
          return baseModel;
        } else {
          throw ServerException(baseModel.message, response.statusCode);
        }
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleExceptionError(e);
    }
  }

  @override
  Future<BaseModel> performPutRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.put(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      if (response.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(response.data!);
        if (response.statusCode == 200 && baseModel.success != false) {
          return baseModel;
        } else {
          throw ServerException(baseModel.message, response.statusCode);
        }
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleExceptionError(e);
    }
  }

  @override
  Future<BaseModel> performDeleteRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.delete(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      if (response.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(response.data!);
        if (response.statusCode == 200 && baseModel.success != false) {
          return baseModel;
        } else {
          throw ServerException(baseModel.message, response.statusCode);
        }
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleExceptionError(e);
    }
  }

  @override
  Future<BaseModel> performPatchRequest({
    required String endpoint,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.patch(
        endpoint,
        data: body,
        queryParameters: queryParameters,
      );
      if (response.data != null) {
        final BaseModel baseModel = BaseModel.fromJson(response.data!);
        if (response.statusCode == 200 && baseModel.success != false) {
          return baseModel;
        } else {
          throw ServerException(baseModel.message, response.statusCode);
        }
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleExceptionError(e);
    }
  }

  @override
  Future<void> performDownloadRequest({
    required String endpoint,
    required String downloadPath,
  }) async {
    try {
      final Response response = await _dio.download(endpoint, downloadPath);
      if (response.statusCode == 200) {
        return;
      } else {
        throw ServerException(
          S.current.somethingWentWrong,
          response.statusCode,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleExceptionError(e);
    }
  }
}
