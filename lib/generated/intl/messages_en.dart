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

  static String m0(count) => "${count} downloaded";

  static String m1(count) => "Deleted ${count} lessons";

  static String m2(count) => "${count} files";

  static String m3(shown, total) => "Showing ${shown} of ${total}";

  static String m4(count) => "${count} solution videos";

  static String m5(count) =>
      "${Intl.plural(count, one: '${count} day ago', other: '${count} days ago')}";

  static String m6(count) =>
      "${Intl.plural(count, one: '${count} hour ago', other: '${count} hours ago')}";

  static String m7(count) =>
      "${Intl.plural(count, one: '${count} min ago', other: '${count} mins ago')}";

  static String m8(count) =>
      "${Intl.plural(count, one: '${count} month ago', other: '${count} months ago')}";

  static String m9(count) =>
      "${Intl.plural(count, one: '${count} year ago', other: '${count} years ago')}";

  static String m10(count) => "Worksheets (${count})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "PleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("Thiqa"),
    "appTheme": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appVersion": MessageLookupByLibrary.simpleMessage("App version"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "availableOffline": MessageLookupByLibrary.simpleMessage(
      "Available offline",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "cancelDownload": MessageLookupByLibrary.simpleMessage("Cancel download"),
    "chapters": MessageLookupByLibrary.simpleMessage("Chapters"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact us"),
    "contactUsMessage": MessageLookupByLibrary.simpleMessage(
      "Email us and we\'ll get back to you shortly:",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAccount": MessageLookupByLibrary.simpleMessage("Delete account"),
    "deleteAccountConfirm": MessageLookupByLibrary.simpleMessage(
      "Your account will be permanently deleted and this cannot be undone. Are you sure?",
    ),
    "deleteAccountFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t delete the account, please try again",
    ),
    "deleteAllDownloads": MessageLookupByLibrary.simpleMessage(
      "Delete all downloads",
    ),
    "deleteAllDownloadsConfirm": MessageLookupByLibrary.simpleMessage(
      "Every downloaded lesson will be removed from this device. You can download them again any time.",
    ),
    "deleteDownload": MessageLookupByLibrary.simpleMessage("Delete download"),
    "deleteDownloadConfirm": MessageLookupByLibrary.simpleMessage(
      "Remove this lesson from your downloads?",
    ),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadCorrupted": MessageLookupByLibrary.simpleMessage(
      "This download is damaged - please download the lesson again",
    ),
    "downloadDeleted": MessageLookupByLibrary.simpleMessage(
      "Lesson removed from downloads",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("Download failed"),
    "downloadIncomplete": MessageLookupByLibrary.simpleMessage(
      "The download stopped before it finished - please try again",
    ),
    "downloadToDeviceTooltip": MessageLookupByLibrary.simpleMessage(
      "Download to device",
    ),
    "downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "downloadsCount": m0,
    "downloadsDeleted": m1,
    "downloadsTitle": MessageLookupByLibrary.simpleMessage("Downloads"),
    "emailCopied": MessageLookupByLibrary.simpleMessage("Email copied"),
    "emailFormatNotCorrect": MessageLookupByLibrary.simpleMessage(
      "Email format is not correct",
    ),
    "emulatorDetectedMessage": MessageLookupByLibrary.simpleMessage(
      "This app is running on an emulator.\nIt can only run on a physical device.",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterFullscreen": MessageLookupByLibrary.simpleMessage("Fullscreen"),
    "exitFullscreen": MessageLookupByLibrary.simpleMessage("Exit fullscreen"),
    "failedToLoadDataPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "Failed to load saved data, please try again",
    ),
    "fieldIsRequired": MessageLookupByLibrary.simpleMessage(
      "This field is required",
    ),
    "filesCount": m2,
    "filesSectionTitle": MessageLookupByLibrary.simpleMessage("Files"),
    "fullNameCanOnlyContainLettersOrSpaces":
        MessageLookupByLibrary.simpleMessage(
          "Full name can only contain letters or spaces",
        ),
    "genericError": MessageLookupByLibrary.simpleMessage(
      "An unexpected error occurred",
    ),
    "gradeBac": MessageLookupByLibrary.simpleMessage("Baccalaureate"),
    "gradeGeneral": MessageLookupByLibrary.simpleMessage("General"),
    "gradeNine": MessageLookupByLibrary.simpleMessage("9th grade"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "loginButton": MessageLookupByLibrary.simpleMessage("Log in"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage("We meet at the top"),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "manageDownloads": MessageLookupByLibrary.simpleMessage("Manage downloads"),
    "myDownloads": MessageLookupByLibrary.simpleMessage("My downloads"),
    "networkErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "It seems you\'re not connected to the internet. Please check your connection and try again.",
    ),
    "networkErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No Internet Connection",
    ),
    "noChapters": MessageLookupByLibrary.simpleMessage("No chapters available"),
    "noDownloadedVideos": MessageLookupByLibrary.simpleMessage(
      "No downloaded videos",
    ),
    "noDownloadedVideosSubtitle": MessageLookupByLibrary.simpleMessage(
      "Download videos while online to watch them later",
    ),
    "noFiles": MessageLookupByLibrary.simpleMessage("No files"),
    "noLessons": MessageLookupByLibrary.simpleMessage("No lessons available"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No subjects match your search",
    ),
    "noSolutionVideos": MessageLookupByLibrary.simpleMessage(
      "No solution videos",
    ),
    "noSubjects": MessageLookupByLibrary.simpleMessage("No subjects available"),
    "noWorksheets": MessageLookupByLibrary.simpleMessage("No worksheets yet"),
    "notSubscribed": MessageLookupByLibrary.simpleMessage("Not subscribed"),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "offlineBanner": MessageLookupByLibrary.simpleMessage(
      "You\'re offline — showing downloads only",
    ),
    "offlineIndicator": MessageLookupByLibrary.simpleMessage("Offline"),
    "oopsSomethingWentWrongPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Oops! Something went wrong. Please try again",
        ),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordRequired": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "passwordShouldAtLeast8Character": MessageLookupByLibrary.simpleMessage(
      "Password should be at least 8 characters",
    ),
    "passwordsDoNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "pauseDownload": MessageLookupByLibrary.simpleMessage("Pause"),
    "pdfDisplayError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t display the file",
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
    "queuedDownload": MessageLookupByLibrary.simpleMessage("Waiting"),
    "recordingDetected": MessageLookupByLibrary.simpleMessage(
      "Screen recording detected\nStop the recording app to continue",
    ),
    "resumeDownload": MessageLookupByLibrary.simpleMessage("Resume"),
    "retry": MessageLookupByLibrary.simpleMessage("Try Again"),
    "retryConnection": MessageLookupByLibrary.simpleMessage("Retry connection"),
    "retryDownload": MessageLookupByLibrary.simpleMessage("Try again"),
    "savedToDownloads": MessageLookupByLibrary.simpleMessage(
      "File saved to your Downloads folder",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchSubjectHint": MessageLookupByLibrary.simpleMessage(
      "Search a subject...",
    ),
    "selectCountry": MessageLookupByLibrary.simpleMessage("Select Country"),
    "serverErrorOccurredPleaseTryAgain": MessageLookupByLibrary.simpleMessage(
      "A server error occurred, please try again later",
    ),
    "serverErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "Sorry, something went wrong on our end. We\'re working on it — please try again later.",
    ),
    "serverErrorTitle": MessageLookupByLibrary.simpleMessage("Server Error"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "settingsAccountSection": MessageLookupByLibrary.simpleMessage("Account"),
    "settingsAppSection": MessageLookupByLibrary.simpleMessage("App"),
    "settingsDangerSection": MessageLookupByLibrary.simpleMessage(
      "Danger zone",
    ),
    "settingsSupportSection": MessageLookupByLibrary.simpleMessage("Support"),
    "showLess": MessageLookupByLibrary.simpleMessage("Show Less"),
    "showMore": MessageLookupByLibrary.simpleMessage("Show More"),
    "showingOfTotal": m3,
    "solutionVideosCount": m4,
    "solutionsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Explanation & Solution",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Oops! Something went wrong",
    ),
    "stillOffline": MessageLookupByLibrary.simpleMessage(
      "Still no internet connection",
    ),
    "storageUsed": MessageLookupByLibrary.simpleMessage("Storage used"),
    "studentLabel": MessageLookupByLibrary.simpleMessage("Student"),
    "subjects": MessageLookupByLibrary.simpleMessage("Subjects"),
    "subscribed": MessageLookupByLibrary.simpleMessage("Subscribed"),
    "syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Syrian phone numbers should be 10 digits, please check and try again",
        ),
    "syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "Syrian phone numbers should be 9 digits, please check and try again",
        ),
    "themeModeDark": MessageLookupByLibrary.simpleMessage("Dark"),
    "themeModeLight": MessageLookupByLibrary.simpleMessage("Light"),
    "themeModeSystem": MessageLookupByLibrary.simpleMessage("Match system"),
    "thereIsProblemWithYourConnectionPleaseTryAgain":
        MessageLookupByLibrary.simpleMessage(
          "There is problem with your connection, please try again",
        ),
    "timeAgoDays": m5,
    "timeAgoHours": m6,
    "timeAgoMinutes": m7,
    "timeAgoMonths": m8,
    "timeAgoNow": MessageLookupByLibrary.simpleMessage("just now"),
    "timeAgoYears": m9,
    "totalDuration": MessageLookupByLibrary.simpleMessage("Total time"),
    "unsafeDeviceTitle": MessageLookupByLibrary.simpleMessage("Unsafe device"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameRequired": MessageLookupByLibrary.simpleMessage(
      "Username is required",
    ),
    "validationRequired": MessageLookupByLibrary.simpleMessage(
      "Please connect to the internet to verify your subscription",
    ),
    "videoPaused": MessageLookupByLibrary.simpleMessage("Video paused"),
    "videoProcessingMessage": MessageLookupByLibrary.simpleMessage(
      "Video is processing\nTry again shortly",
    ),
    "worksheetsWithCount": m10,
    "yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers":
        MessageLookupByLibrary.simpleMessage(
          "Your password must contain at least 8 characters including letters and numbers",
        ),
  };
}
