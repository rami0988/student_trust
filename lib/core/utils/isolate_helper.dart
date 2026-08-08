import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

class IsolateHelper {
  static Future<R> run<P, R>(FutureOr<R> Function(P) worker, P params) async {
    return await Isolate.run<R>(() async => await worker(params));
  }

  static Future<R> runCompute<P, R>(
    ComputeCallback<P, R> worker,
    P params,
  ) async {
    return await compute<P, R>(worker, params);
  }
}
