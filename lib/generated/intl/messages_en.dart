// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: '${count} day ago', other: '${count} days ago')}";

  static String m1(count) =>
      "${Intl.plural(count, one: '${count} hour ago', other: '${count} hours ago')}";

  static String m2(count) =>
      "${Intl.plural(count, one: '${count} min ago', other: '${count} mins ago')}";

  static String m3(count) =>
      "${Intl.plural(count, one: '${count} month ago', other: '${count} months ago')}";

  static String m4(count) =>
      "${Intl.plural(count, one: '${count} year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "PleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "emailFormatNotCorrect": MessageLookupByLibrary.simpleMessage(
      "Email format is not correct",
    ),
    "emptyExampleItemsSubtitle": MessageLookupByLibrary.simpleMessage(
      "Pull to refresh and try again",
    ),
    "emptyExampleItemsTitle": MessageLookupByLibrary.simpleMessage(
      "No items yet",
    ),
    "exampleItems": MessageLookupByLibrary.simpleMessage("Example items"),
    "exampleItemsSubtitle": MessageLookupByLibrary.simpleMessage(
      "A reference feature you can copy",
    ),
    "failedToLoadDataPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Failed to load saved data, please try again",
    ),
    "fieldIsRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "fullNameCanOnlyContainLettersOrSpaces":
        MessageLookupByLibrary.simpleMessage(
          "Full name can only contain letters or spaces",
        ),
    "networkErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "It seems you\'re not connected to the internet. Please check your connection and try again.",
    ),
    "networkErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No Internet Connection",
    ),
    "oopsSomethingWentWrongPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Oops! Something went wrong. Please try again",
        ),
    "passwordShouldAtLeast8Character": MessageLookupByLibrary.simpleMessage(
      "Password should be at least 8 characters",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "pleaseCompleteVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Please complete the 6-digit verification code",
    ),
    "pleaseConfirmYourPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password",
    ),
    "pleaseEnterAtLeastFirstAndLastName": MessageLookupByLibrary.simpleMessage(
      "Please enter at least first and last name",
    ),
    "pleaseEnterPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter your password",
    ),
    "pleaseEnterPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Please enter your phone number",
    ),
    "pleaseEnterVerificationCode": MessageLookupByLibrary.simpleMessage(
      "Please enter the verification code",
    ),
    "pleaseEnterYourFullName": MessageLookupByLibrary.simpleMessage(
      "Please enter your full name",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Try Again"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "selectCountry": MessageLookupByLibrary.simpleMessage("Select Country"),
    "serverErrorOccurredPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "A server error occurred, please try again later",
    ),
    "serverErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sorry, something went wrong on our end. We\'re working on it — please try again later.",
    ),
    "serverErrorTitle": MessageLookupByLibrary.simpleMessage("Server Error"),
    "showLess": MessageLookupByLibrary.simpleMessage("Show Less"),
    "showMore": MessageLookupByLibrary.simpleMessage("Show More"),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Oops! Something went wrong",
    ),
    "syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Syrian phone numbers should be 10 digits, please check and try again",
        ),
    "syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Syrian phone numbers should be 9 digits, please check and try again",
        ),
    "thereIsProblemWithYourConnectionPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "There is problem with your connection, please try again",
        ),
    "timeAgoDays": m0,
    "timeAgoHours": m1,
    "timeAgoMinutes": m2,
    "timeAgoMonths": m3,
    "timeAgoNow": MessageLookupByLibrary.simpleMessage("just now"),
    "timeAgoYears": m4,
    "yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers":
        MessageLookupByLibrary.simpleMessage(
          "Your password must contain at least 8 characters including letters and numbers",
        ),
  };
}
