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

  static String m0(count) =>
      "${Intl.plural(count, one: 'منذ يوم', two: 'منذ يومين', few: 'منذ ${count} أيام', many: 'منذ ${count} يوم', other: 'منذ ${count} يوم')}";

  static String m1(count) =>
      "${Intl.plural(count, one: 'منذ ساعة', two: 'منذ ساعتين', few: 'منذ ${count} ساعات', many: 'منذ ${count} ساعة', other: 'منذ ${count} ساعة')}";

  static String m2(count) =>
      "${Intl.plural(count, one: 'منذ دقيقة', two: 'منذ دقيقتين', few: 'منذ ${count} دقائق', many: 'منذ ${count} دقيقة', other: 'منذ ${count} دقيقة')}";

  static String m3(count) =>
      "${Intl.plural(count, one: 'منذ شهر', two: 'منذ شهرين', few: 'منذ ${count} أشهر', many: 'منذ ${count} شهر', other: 'منذ ${count} شهر')}";

  static String m4(count) =>
      "${Intl.plural(count, one: 'منذ سنة', two: 'منذ سنتين', few: 'منذ ${count} سنوات', many: 'منذ ${count} سنة', other: 'منذ ${count} سنة')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "PleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "الرجاء إدخال بريدك الإلكتروني",
    ),
    "back": MessageLookupByLibrary.simpleMessage("رجوع"),
    "emailFormatNotCorrect": MessageLookupByLibrary.simpleMessage(
      "صيغة البريد الإلكتروني غير صحيحة",
    ),
    "emptyExampleItemsSubtitle": MessageLookupByLibrary.simpleMessage(
      "اسحب للتحديث وحاول مجدداً",
    ),
    "emptyExampleItemsTitle": MessageLookupByLibrary.simpleMessage(
      "لا توجد عناصر بعد",
    ),
    "exampleItems": MessageLookupByLibrary.simpleMessage("عناصر تجريبية"),
    "exampleItemsSubtitle": MessageLookupByLibrary.simpleMessage(
      "ميزة مرجعية يمكنك نسخها",
    ),
    "failedToLoadDataPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل البيانات المحفوظة، يرجى المحاولة مجدداً",
    ),
    "fieldIsRequired": MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
    "fullNameCanOnlyContainLettersOrSpaces":
        MessageLookupByLibrary.simpleMessage(
          "الاسم الكامل يمكن أن يحتوي على أحرف ومسافات فقط",
        ),
    "networkErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "يبدو أن الاتصال بالإنترنت غير متوفر. يرجى التحقق من اتصالك والمحاولة مرة أخرى.",
    ),
    "networkErrorTitle": MessageLookupByLibrary.simpleMessage(
      "لا يوجد اتصال بالإنترنت",
    ),
    "oopsSomethingWentWrongPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "عذراً! حدث خطأ ما. يرجى المحاولة مجدداً",
        ),
    "passwordShouldAtLeast8Character": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور يجب أن تكون 8 أحرف على الأقل",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "كلمتا المرور غير متطابقتين",
    ),
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
    "retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "search": MessageLookupByLibrary.simpleMessage("بحث"),
    "selectCountry": MessageLookupByLibrary.simpleMessage("اختر الدولة"),
    "serverErrorOccurredPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "حدث خطأ في الخادم، يرجى المحاولة مجدداً لاحقاً",
    ),
    "serverErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "نعتذر، حدث خطأ في النظام. نعمل على حل المشكلة. يرجى المحاولة مرة أخرى لاحقاً.",
    ),
    "serverErrorTitle": MessageLookupByLibrary.simpleMessage("خطأ في الخادم"),
    "showLess": MessageLookupByLibrary.simpleMessage("عرض أقل"),
    "showMore": MessageLookupByLibrary.simpleMessage("عرض المزيد"),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "عفواً! حدث خطأ ما",
    ),
    "syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "أرقام الهواتف السورية يجب أن تكون 10 أرقام، الرجاء التحقق والمحاولة مجدداً",
        ),
    "syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "أرقام الهواتف السورية يجب أن تكون 9 أرقام، الرجاء التحقق والمحاولة مجدداً",
        ),
    "thereIsProblemWithYourConnectionPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "هناك مشكلة بالاتصال بالشبكة الرجاء إعادة المحاولة لاحقاً",
        ),
    "timeAgoDays": m0,
    "timeAgoHours": m1,
    "timeAgoMinutes": m2,
    "timeAgoMonths": m3,
    "timeAgoNow": MessageLookupByLibrary.simpleMessage("الآن"),
    "timeAgoYears": m4,
    "yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers":
        MessageLookupByLibrary.simpleMessage(
          "يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل تشمل حروفاً وأرقاماً",
        ),
  };
}
