// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(count) => "${count} فيديو محفوظ";

  static String m1(count) => "تم حذف ${count} درساً";

  static String m2(count) => "${count} ملف";

  static String m3(shown, total) => "عرض ${shown} من ${total}";

  static String m4(count) => "${count} فيديو حل";

  static String m5(count) =>
      "${Intl.plural(count, one: 'منذ يوم', two: 'منذ يومين', few: 'منذ ${count} أيام', many: 'منذ ${count} يوم', other: 'منذ ${count} يوم')}";

  static String m6(count) =>
      "${Intl.plural(count, one: 'منذ ساعة', two: 'منذ ساعتين', few: 'منذ ${count} ساعات', many: 'منذ ${count} ساعة', other: 'منذ ${count} ساعة')}";

  static String m7(count) =>
      "${Intl.plural(count, one: 'منذ دقيقة', two: 'منذ دقيقتين', few: 'منذ ${count} دقائق', many: 'منذ ${count} دقيقة', other: 'منذ ${count} دقيقة')}";

  static String m8(count) =>
      "${Intl.plural(count, one: 'منذ شهر', two: 'منذ شهرين', few: 'منذ ${count} أشهر', many: 'منذ ${count} شهر', other: 'منذ ${count} شهر')}";

  static String m9(count) =>
      "${Intl.plural(count, one: 'منذ سنة', two: 'منذ سنتين', few: 'منذ ${count} سنوات', many: 'منذ ${count} سنة', other: 'منذ ${count} سنة')}";

  static String m10(count) => "أوراق العمل (${count})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "PleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال بريدك الإلكتروني",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("ثقة"),
    "appTheme": MessageLookupByLibrary.simpleMessage("المظهر"),
    "appVersion": MessageLookupByLibrary.simpleMessage("إصدار التطبيق"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "availableOffline": MessageLookupByLibrary.simpleMessage(
      "متاح بدون إنترنت",
    ),
    "back": MessageLookupByLibrary.simpleMessage("رجوع"),
    "cancelDownload": MessageLookupByLibrary.simpleMessage("إلغاء التحميل"),
    "chapters": MessageLookupByLibrary.simpleMessage("الفصول"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("قريباً"),
    "completed": MessageLookupByLibrary.simpleMessage("مكتمل"),
    "contactUs": MessageLookupByLibrary.simpleMessage("تواصل معنا"),
    "contactUsMessage": MessageLookupByLibrary.simpleMessage(
      "راسلنا على البريد التالي وسنعود إليك في أقرب وقت:",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("نسخ"),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("حذف الحساب"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "سيتم حذف حسابك نهائياً ولا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "تعذر حذف الحساب، حاول مرة أخرى",
    ),
    "deleteAllDownloads": MessageLookupByLibrary.simpleMessage(
      "حذف كل التحميلات",
    ),
    "deleteAllDownloadsConfirm": MessageLookupByLibrary.simpleMessage(
      "سيتم حذف جميع الدروس المحمّلة من هذا الجهاز. يمكنك تحميلها مرة أخرى في أي وقت.",
    ),
    "deleteDownload": MessageLookupByLibrary.simpleMessage("حذف التحميل"),
    "deleteDownloadConfirm": MessageLookupByLibrary.simpleMessage(
      "هل تريد حذف هذا الدرس من التحميلات؟",
    ),
    "download": MessageLookupByLibrary.simpleMessage("تحميل"),
    "downloadCorrupted": MessageLookupByLibrary.simpleMessage(
      "ملف التحميل تالف — يرجى تحميل الدرس من جديد",
    ),
    "downloadDeleted": MessageLookupByLibrary.simpleMessage(
      "تم حذف الدرس من التحميلات",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("فشل التحميل"),
    "downloadIncomplete": MessageLookupByLibrary.simpleMessage(
      "انقطع التحميل قبل اكتماله — أعد المحاولة",
    ),
    "downloadToDeviceTooltip": MessageLookupByLibrary.simpleMessage(
      "تحميل إلى الجهاز",
    ),
    "downloaded": MessageLookupByLibrary.simpleMessage("تم التحميل"),
    "downloadsCount": m0,
    "downloadsDeleted": m1,
    "downloadsTitle": MessageLookupByLibrary.simpleMessage("التحميلات"),
    "emailCopied": MessageLookupByLibrary.simpleMessage("تم نسخ البريد"),
    "emailFormatNotCorrect": MessageLookupByLibrary.simpleMessage(
      "صيغة البريد الإلكتروني غير صحيحة",
    ),
    "emulatorDetectedMessage": MessageLookupByLibrary.simpleMessage(
      "تم رصد أن التطبيق يعمل على محاكي (Emulator).\nلا يمكن تشغيل التطبيق إلا على جهاز حقيقي.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterFullscreen": MessageLookupByLibrary.simpleMessage("ملء الشاشة"),
    "exitFullscreen": MessageLookupByLibrary.simpleMessage("إنهاء ملء الشاشة"),
    "failedToLoadDataPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل البيانات المحفوظة، يرجى المحاولة مجدداً",
    ),
    "fieldIsRequired": MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
    "filesCount": m2,
    "filesSectionTitle": MessageLookupByLibrary.simpleMessage("الملفات"),
    "fullNameCanOnlyContainLettersOrSpaces":
        MessageLookupByLibrary.simpleMessage(
          "الاسم الكامل يمكن أن يحتوي على أحرف ومسافات فقط",
        ),
    "genericError": MessageLookupByLibrary.simpleMessage("حدث خطأ غير متوقع"),
    "gradeBac": MessageLookupByLibrary.simpleMessage("بكالوريا"),
    "gradeGeneral": MessageLookupByLibrary.simpleMessage("عام"),
    "gradeNine": MessageLookupByLibrary.simpleMessage("الصف التاسع"),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "lessons": MessageLookupByLibrary.simpleMessage("الدروس"),
    "loginButton": MessageLookupByLibrary.simpleMessage("دخول"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage("نلتقي في القمة"),
    "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "هل تريد تسجيل الخروج؟",
    ),
    "manageDownloads": MessageLookupByLibrary.simpleMessage("إدارة التحميلات"),
    "myDownloads": MessageLookupByLibrary.simpleMessage("تحميلاتي"),
    "networkErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "يبدو أن الاتصال بالإنترنت غير متوفر. يرجى التحقق من اتصالك والمحاولة مرة أخرى.",
    ),
    "networkErrorTitle": MessageLookupByLibrary.simpleMessage(
      "لا يوجد اتصال بالإنترنت",
    ),
    "noChapters": MessageLookupByLibrary.simpleMessage("لا توجد فصول متاحة"),
    "noDownloadedVideos": MessageLookupByLibrary.simpleMessage(
      "لا توجد فيديوهات محمّلة",
    ),
    "noDownloadedVideosSubtitle": MessageLookupByLibrary.simpleMessage(
      "قم بتحميل الفيديوهات وأنت متصل بالإنترنت لمشاهدتها لاحقاً",
    ),
    "noFiles": MessageLookupByLibrary.simpleMessage("لا توجد ملفات"),
    "noLessons": MessageLookupByLibrary.simpleMessage("لا توجد دروس متاحة"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "لا توجد مواد مطابقة للبحث",
    ),
    "noSolutionVideos": MessageLookupByLibrary.simpleMessage(
      "لا توجد فيديوهات حل",
    ),
    "noSubjects": MessageLookupByLibrary.simpleMessage("لا توجد مواد متاحة"),
    "noWorksheets": MessageLookupByLibrary.simpleMessage(
      "لا توجد أوراق عمل بعد",
    ),
    "notSubscribed": MessageLookupByLibrary.simpleMessage("غير مشترك"),
    "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "offlineBanner": MessageLookupByLibrary.simpleMessage(
      "أنت غير متصل بالإنترنت — يتم عرض التحميلات فقط",
    ),
    "offlineIndicator": MessageLookupByLibrary.simpleMessage("غير متصل"),
    "oopsSomethingWentWrongPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "عذراً! حدث خطأ ما. يرجى المحاولة مجدداً",
        ),
    "open": MessageLookupByLibrary.simpleMessage("فتح"),
    "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور مطلوبة",
    ),
    "passwordShouldAtLeast8Character": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "كلمتا المرور غير متطابقتين",
    ),
    "pauseDownload": MessageLookupByLibrary.simpleMessage("إيقاف مؤقت"),
    "pdfDisplayError": MessageLookupByLibrary.simpleMessage("تعذّر عرض الملف"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "pleaseCompleteVerificationCode": MessageLookupByLibrary.simpleMessage(
      "الرجاء إكمال رمز التحقق المكون من 6 أرقام",
    ),
    "pleaseConfirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "الرجاء تأكيد كلمة المرور",
    ),
    "pleaseEnterAtLeastFirstAndLastName": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال الاسم الأول واسم العائلة على الأقل",
    ),
    "pleaseEnterPassword": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال كلمة المرور",
    ),
    "pleaseEnterPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال رقم هاتفك",
    ),
    "pleaseEnterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال رمز التحقق",
    ),
    "pleaseEnterYourFullName": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال اسمك الكامل",
    ),
    "queuedDownload": MessageLookupByLibrary.simpleMessage("بانتظار الدور"),
    "recordingDetected": MessageLookupByLibrary.simpleMessage(
      "تم رصد تسجيل الشاشة\nأوقف تطبيق التسجيل للمتابعة",
    ),
    "resumeDownload": MessageLookupByLibrary.simpleMessage("استئناف"),
    "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "retryConnection": MessageLookupByLibrary.simpleMessage(
      "إعادة المحاولة للاتصال",
    ),
    "retryDownload": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "savedToDownloads": MessageLookupByLibrary.simpleMessage(
      "تم حفظ الملف في مجلد التنزيلات",
    ),
    "search": MessageLookupByLibrary.simpleMessage("بحث"),
    "searchSubjectHint": MessageLookupByLibrary.simpleMessage(
      "ابحث عن مادة...",
    ),
    "selectCountry": MessageLookupByLibrary.simpleMessage("اختر الدولة"),
    "serverErrorOccurredPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "حدث خطأ في الخادم، يرجى المحاولة مجدداً لاحقاً",
    ),
    "serverErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "نعتذر، حدث خطأ في النظام. نعمل على حل المشكلة. يرجى المحاولة مرة أخرى لاحقاً.",
    ),
    "serverErrorTitle": MessageLookupByLibrary.simpleMessage("خطأ في الخادم"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "settingsAccountSection": MessageLookupByLibrary.simpleMessage("الحساب"),
    "settingsAppSection": MessageLookupByLibrary.simpleMessage("التطبيق"),
    "settingsDangerSection": MessageLookupByLibrary.simpleMessage(
      "منطقة الخطر",
    ),
    "settingsSupportSection": MessageLookupByLibrary.simpleMessage("الدعم"),
    "showLess": MessageLookupByLibrary.simpleMessage("عرض أقل"),
    "showMore": MessageLookupByLibrary.simpleMessage("عرض المزيد"),
    "showingOfTotal": m3,
    "solutionVideosCount": m4,
    "solutionsSectionTitle": MessageLookupByLibrary.simpleMessage("شرح وحل"),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "عفواً! حدث خطأ ما",
    ),
    "stillOffline": MessageLookupByLibrary.simpleMessage(
      "ما زلت غير متصل بالإنترنت",
    ),
    "storageUsed": MessageLookupByLibrary.simpleMessage("المساحة المستخدمة"),
    "studentLabel": MessageLookupByLibrary.simpleMessage("طالب"),
    "subjects": MessageLookupByLibrary.simpleMessage("المواد الدراسية"),
    "subscribed": MessageLookupByLibrary.simpleMessage("مشترك"),
    "syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "أرقام الهواتف السورية يجب أن تكون 10 أرقام، الرجاء التحقق والمحاولة مجدداً",
        ),
    "syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "أرقام الهواتف السورية يجب أن تكون 9 أرقام، الرجاء التحقق والمحاولة مجدداً",
        ),
    "themeModeDark": MessageLookupByLibrary.simpleMessage("داكن"),
    "themeModeLight": MessageLookupByLibrary.simpleMessage("فاتح"),
    "themeModeSystem": MessageLookupByLibrary.simpleMessage("حسب النظام"),
    "thereIsProblemWithYourConnectionPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "هناك مشكلة بالاتصال بالشبكة الرجاء إعادة المحاولة لاحقاً",
        ),
    "timeAgoDays": m5,
    "timeAgoHours": m6,
    "timeAgoMinutes": m7,
    "timeAgoMonths": m8,
    "timeAgoNow": MessageLookupByLibrary.simpleMessage("الآن"),
    "timeAgoYears": m9,
    "totalDuration": MessageLookupByLibrary.simpleMessage("المدة الإجمالية"),
    "unsafeDeviceTitle": MessageLookupByLibrary.simpleMessage("جهاز غير آمن"),
    "username": MessageLookupByLibrary.simpleMessage("اسم المستخدم"),
    "usernameRequired": MessageLookupByLibrary.simpleMessage(
      "اسم المستخدم مطلوب",
    ),
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "يجب الاتصال بالإنترنت للتحقق من الاشتراك",
    ),
    "videoPaused": MessageLookupByLibrary.simpleMessage("تم إيقاف الفيديو"),
    "videoProcessingMessage": MessageLookupByLibrary.simpleMessage(
      "الفيديو قيد المعالجة\nحاول مرة أخرى بعد قليل",
    ),
    "worksheetsWithCount": m10,
    "yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers":
        MessageLookupByLibrary.simpleMessage(
          "يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل تشمل حروفاً وأرقاماً",
        ),
  };
}
