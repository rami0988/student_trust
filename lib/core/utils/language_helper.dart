import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_enums.dart';

abstract class LanguageHelper {
  LanguageHelper._();

  static bool isEnglishLocale(BuildContext context) => Localizations.localeOf(context).languageCode == Language.en.name;

  static Language getDeviceLanguage() {
    final Locale deviceLocale = PlatformDispatcher.instance.locale;
    final String deviceLanguage = deviceLocale.languageCode;
    return Language.fromValue(deviceLanguage);
  }
}
