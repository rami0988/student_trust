import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../utils/request_result.dart';

abstract class BaseRepository {
  @protected
  Future<RequestResult<T>> execute<T, TM>(
    FutureOr<TM> Function() apiRequest, {
    FutureOr<T> Function(TM)? converter,
  });

  @protected
  RequestResult<T> executeSync<T, TM>(
    TM Function() request, {
    T Function(TM)? converter,
  });
}
