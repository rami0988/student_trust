import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

abstract class Logger {
  Logger._();

  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _green = '\x1B[32m';
  // static const _yellow = '\x1B[33m';
  // static const _cyan = '\x1B[36m';
  // static const _blue = '\x1B[34m';

  static void info(String message, {String name = 'INFO'}) {
    if (kDebugMode) {
      developer.log(message, name: "🔵 $name", level: 800);
    }
  }

  static void success(
    String message, {
    String name = 'SUCCESS',
    String icon = '✅',
  }) {
    if (kDebugMode) {
      developer.log(
        '$_green$message$_reset',
        name: '$icon $_green$name$_reset',
        level: 850,
      );
    }
  }

  static void warning(String message, {String name = 'WARNING'}) {
    if (kDebugMode) {
      developer.log(message, name: '⚠️ $name', level: 900);
    }
  }

  static void error(
    String message, {
    String name = 'ERROR',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      developer.log(
        '$_red$message$_reset',
        name: '❌ $_red$name$_reset',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void debug(
    String message, {
    String name = 'DEBUG',
    String icon = '🐛',
  }) {
    if (kDebugMode) {
      developer.log(message, name: '$icon $name', level: 700);
    }
  }
}
