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

  static String m0(count) => "${count} completed";

  static String m1(percent) => "Paused · ${percent}%";

  static String m2(percent) => "Downloading · ${percent}%";

  static String m3(count) => "${count} downloaded";

  static String m4(count) => "Deleted ${count} lessons";

  static String m5(count) =>
      "${Intl.plural(count, one: '1 hour', other: '${count} hours')}";

  static String m6(first, second) => "${first} ${second}";

  static String m7(count) =>
      "${Intl.plural(count, one: '1 minute', other: '${count} minutes')}";

  static String m8(count) =>
      "${Intl.plural(count, one: '1 second', other: '${count} seconds')}";

  static String m9(count) => "${count} files";

  static String m10(hours, minutes) => "${hours}h ${minutes}m";

  static String m11(current, total) => "Lesson ${current} of ${total}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 lesson', other: '${count} lessons')}";

  static String m13(minutes) => "${minutes} min left";

  static String m14(minutes) => "${minutes}m";

  static String m15(count) =>
      "${Intl.plural(count, one: '1 lesson available offline', other: '${count} lessons available offline')}";

  static String m16(time, speed) => "${time} left at ${speed}";

  static String m17(time) => "Resumes at ${time}";

  static String m18(attempt, max) => "Attempt ${attempt} of ${max}";

  static String m19(seconds) => "in ${seconds}s";

  static String m20(seconds) => "${seconds}s";

  static String m21(shown, total) => "Showing ${shown} of ${total}";

  static String m22(seconds) => "Back ${seconds} seconds";

  static String m23(seconds) => "Forward ${seconds} seconds";

  static String m24(count) => "${count} solution videos";

  static String m25(count) =>
      "${Intl.plural(count, one: '${count} day ago', other: '${count} days ago')}";

  static String m26(count) =>
      "${Intl.plural(count, one: '${count} hour ago', other: '${count} hours ago')}";

  static String m27(count) =>
      "${Intl.plural(count, one: '${count} min ago', other: '${count} mins ago')}";

  static String m28(count) =>
      "${Intl.plural(count, one: '${count} month ago', other: '${count} months ago')}";

  static String m29(count) =>
      "${Intl.plural(count, one: '${count} year ago', other: '${count} years ago')}";

  static String m30(time) => "${time} left";

  static String m31(saved) => "Across the whole chapter you save ${saved}.";

  static String m32(speed, saved) =>
      "At ${speed}, you\'ll save ${saved} on this lesson!";

  static String m33(duration) => "Normal speed: the lesson takes ${duration}";

  static String m34(speed, saved) =>
      "At ${speed} you save ${saved} on this lesson";

  static String m35(speed, saved) =>
      "Try ${speed} and save ${saved} on this lesson";

  static String m36(speed, extra) =>
      "At ${speed}: +${extra} for deeper understanding";

  static String m37(extra) =>
      "Slower for deeper understanding: +${extra} to the lesson";

  static String m38(speed, saved) =>
      "Try ${speed} to save ${saved} while keeping it clear.";

  static String m39(count) => "Worksheets (${count})";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "PleaseEnterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email",
    ),
    "aboutLesson": MessageLookupByLibrary.simpleMessage("About this lesson"),
    "appName": MessageLookupByLibrary.simpleMessage("Thiqa"),
    "appTheme": MessageLookupByLibrary.simpleMessage("Appearance"),
    "appVersion": MessageLookupByLibrary.simpleMessage("App version"),
    "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "availableOffline": MessageLookupByLibrary.simpleMessage(
      "Available offline",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "cancelDownload": MessageLookupByLibrary.simpleMessage("Cancel download"),
    "cannotPlayVideo": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t play the video",
    ),
    "change": MessageLookupByLibrary.simpleMessage("Change"),
    "chapterDone": MessageLookupByLibrary.simpleMessage("done"),
    "chapters": MessageLookupByLibrary.simpleMessage("Chapters"),
    "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completedCount": m0,
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact us"),
    "contactUsMessage": MessageLookupByLibrary.simpleMessage(
      "Email us and we\'ll get back to you shortly:",
    ),
    "continueWhereLeft": MessageLookupByLibrary.simpleMessage(
      "Continue where you left off",
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
    "downloadExpired": MessageLookupByLibrary.simpleMessage(
      "Download expired after 30 days — download the lesson again",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("Download failed"),
    "downloadIncomplete": MessageLookupByLibrary.simpleMessage(
      "The download stopped before it finished - please try again",
    ),
    "downloadLocked": MessageLookupByLibrary.simpleMessage(
      "Locked — go online once to verify your subscription",
    ),
    "downloadPausedPercent": m1,
    "downloadToDeviceTooltip": MessageLookupByLibrary.simpleMessage(
      "Download to device",
    ),
    "downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "downloadingPercent": m2,
    "downloadsCount": m3,
    "downloadsDeleted": m4,
    "downloadsInProgress": MessageLookupByLibrary.simpleMessage("In progress"),
    "downloadsTitle": MessageLookupByLibrary.simpleMessage("Downloads"),
    "durationHours": m5,
    "durationJoin": m6,
    "durationMinutes": m7,
    "durationSeconds": m8,
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
    "filesCount": m9,
    "filesSectionTitle": MessageLookupByLibrary.simpleMessage("Files"),
    "filterAll": MessageLookupByLibrary.simpleMessage("All"),
    "filterCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
    "filterDownloaded": MessageLookupByLibrary.simpleMessage("Saved"),
    "filterInProgress": MessageLookupByLibrary.simpleMessage("In progress"),
    "fullNameCanOnlyContainLettersOrSpaces":
        MessageLookupByLibrary.simpleMessage(
          "Full name can only contain letters or spaces",
        ),
    "genericError": MessageLookupByLibrary.simpleMessage(
      "An unexpected error occurred",
    ),
    "gradeBac": MessageLookupByLibrary.simpleMessage("Baccalaureate"),
    "gradeEleven": MessageLookupByLibrary.simpleMessage("11th grade"),
    "gradeGeneral": MessageLookupByLibrary.simpleMessage("General"),
    "gradeNine": MessageLookupByLibrary.simpleMessage("9th grade"),
    "hoursMinutesShort": m10,
    "insufficientStorage": MessageLookupByLibrary.simpleMessage(
      "Not enough storage — free up space, then resume the download",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lessonOfCount": m11,
    "lessons": MessageLookupByLibrary.simpleMessage("Lessons"),
    "lessonsCount": m12,
    "loginButton": MessageLookupByLibrary.simpleMessage("Log in"),
    "loginSubtitle": MessageLookupByLibrary.simpleMessage("We meet at the top"),
    "logout": MessageLookupByLibrary.simpleMessage("Log out"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "manageDownloads": MessageLookupByLibrary.simpleMessage("Manage downloads"),
    "mediaCorrupted": MessageLookupByLibrary.simpleMessage(
      "The downloaded file was damaged and removed — download the lesson again",
    ),
    "minutesLeft": m13,
    "minutesShort": m14,
    "myDownloads": MessageLookupByLibrary.simpleMessage("My downloads"),
    "networkErrorSubtitle": MessageLookupByLibrary.simpleMessage(
      "It seems you\'re not connected to the internet. Please check your connection and try again.",
    ),
    "networkErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No Internet Connection",
    ),
    "newLesson": MessageLookupByLibrary.simpleMessage("New"),
    "noChapters": MessageLookupByLibrary.simpleMessage("No chapters available"),
    "noDownloadedVideos": MessageLookupByLibrary.simpleMessage(
      "No downloaded videos",
    ),
    "noDownloadedVideosSubtitle": MessageLookupByLibrary.simpleMessage(
      "Download videos while online to watch them later",
    ),
    "noFiles": MessageLookupByLibrary.simpleMessage("No files"),
    "noLessons": MessageLookupByLibrary.simpleMessage("No lessons available"),
    "noLessonsInFilter": MessageLookupByLibrary.simpleMessage(
      "No lessons in this filter",
    ),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No subjects match your search",
    ),
    "noSolutionVideos": MessageLookupByLibrary.simpleMessage(
      "No solution videos",
    ),
    "noSubjects": MessageLookupByLibrary.simpleMessage("No subjects available"),
    "noWorksheets": MessageLookupByLibrary.simpleMessage("No worksheets yet"),
    "notSubscribed": MessageLookupByLibrary.simpleMessage("Not subscribed"),
    "notificationDownloading": MessageLookupByLibrary.simpleMessage(
      "Downloading",
    ),
    "notificationFailed": MessageLookupByLibrary.simpleMessage(
      "Download failed — open the app to continue",
    ),
    "notificationPaused": MessageLookupByLibrary.simpleMessage(
      "Download paused",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "offlineBanner": MessageLookupByLibrary.simpleMessage(
      "You\'re offline — showing downloads only",
    ),
    "offlineIndicator": MessageLookupByLibrary.simpleMessage("Offline"),
    "offlineSummary": m15,
    "offlineSummarySub": MessageLookupByLibrary.simpleMessage(
      "Encrypted on this device · re-checked every 7 days",
    ),
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
    "pauseVideo": MessageLookupByLibrary.simpleMessage("Pause"),
    "pdfDisplayError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t display the file",
    ),
    "perSecond": MessageLookupByLibrary.simpleMessage("/s"),
    "phoneNumber": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "pinchToZoom": MessageLookupByLibrary.simpleMessage("Pinch to zoom"),
    "playVideo": MessageLookupByLibrary.simpleMessage("Play"),
    "playbackSettings": MessageLookupByLibrary.simpleMessage(
      "Playback settings",
    ),
    "playbackSpeed": MessageLookupByLibrary.simpleMessage("Playback speed"),
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
    "qualityDataSaverDesc": MessageLookupByLibrary.simpleMessage("Data saver"),
    "qualityDefaultTag": MessageLookupByLibrary.simpleMessage("Default"),
    "qualityFullDesc": MessageLookupByLibrary.simpleMessage("Best on Wi-Fi"),
    "qualityHighDesc": MessageLookupByLibrary.simpleMessage("Sharp board text"),
    "qualityLabel": MessageLookupByLibrary.simpleMessage("Quality"),
    "qualityLowDesc": MessageLookupByLibrary.simpleMessage(
      "For very weak connections",
    ),
    "queuedDownload": MessageLookupByLibrary.simpleMessage("Waiting"),
    "recordingDetected": MessageLookupByLibrary.simpleMessage(
      "Screen recording detected\nStop the recording app to continue",
    ),
    "remainingAtSpeed": m16,
    "resetZoom": MessageLookupByLibrary.simpleMessage("Reset zoom"),
    "resumeDownload": MessageLookupByLibrary.simpleMessage("Resume"),
    "resumeFrom": m17,
    "retry": MessageLookupByLibrary.simpleMessage("Try Again"),
    "retryAttempt": m18,
    "retryConnection": MessageLookupByLibrary.simpleMessage("Retry connection"),
    "retryDownload": MessageLookupByLibrary.simpleMessage("Try again"),
    "retryInSeconds": m19,
    "retryingNow": MessageLookupByLibrary.simpleMessage("Retrying now"),
    "savedOffline": MessageLookupByLibrary.simpleMessage("Saved"),
    "savedToDownloads": MessageLookupByLibrary.simpleMessage(
      "File saved to your Downloads folder",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchSubjectHint": MessageLookupByLibrary.simpleMessage(
      "Search a subject...",
    ),
    "secondsShort": m20,
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
    "showingOfTotal": m21,
    "skipBack": m22,
    "skipForward": m23,
    "solutionVideosCount": m24,
    "solutionsSectionTitle": MessageLookupByLibrary.simpleMessage(
      "Explanation & Solution",
    ),
    "somethingWentWrong": MessageLookupByLibrary.simpleMessage(
      "Oops! Something went wrong",
    ),
    "speedLabel": MessageLookupByLibrary.simpleMessage("Speed"),
    "speedNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "speedSavedForAll": MessageLookupByLibrary.simpleMessage(
      "Saved for all lessons",
    ),
    "startChapter": MessageLookupByLibrary.simpleMessage("Start the chapter"),
    "stillOffline": MessageLookupByLibrary.simpleMessage(
      "Still no internet connection",
    ),
    "storageUsed": MessageLookupByLibrary.simpleMessage("Storage used"),
    "studentLabel": MessageLookupByLibrary.simpleMessage("Student"),
    "subjects": MessageLookupByLibrary.simpleMessage("Subjects"),
    "subscribed": MessageLookupByLibrary.simpleMessage("Subscribed"),
    "subscriptionEndedDownloadRemoved": MessageLookupByLibrary.simpleMessage(
      "Your subscription to this subject ended, so the download was removed",
    ),
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
    "timeAgoDays": m25,
    "timeAgoHours": m26,
    "timeAgoMinutes": m27,
    "timeAgoMonths": m28,
    "timeAgoNow": MessageLookupByLibrary.simpleMessage("just now"),
    "timeAgoYears": m29,
    "timeLeft": m30,
    "timeSavedChapter": m31,
    "timeSavedFaster": m32,
    "timeSavedNormal": m33,
    "timeSavedPillFaster": m34,
    "timeSavedPillNormal": m35,
    "timeSavedPillSlower": m36,
    "timeSavedSlower": m37,
    "timeSavedSlowerHint": MessageLookupByLibrary.simpleMessage(
      "Good for worked examples and the hard parts.",
    ),
    "timeSavedTry": m38,
    "totalDuration": MessageLookupByLibrary.simpleMessage("Total time"),
    "unsafeDeviceTitle": MessageLookupByLibrary.simpleMessage("Unsafe device"),
    "upNext": MessageLookupByLibrary.simpleMessage("Up next"),
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
    "videoQuality": MessageLookupByLibrary.simpleMessage("Video quality"),
    "waitingForNetwork": MessageLookupByLibrary.simpleMessage(
      "Waiting for network",
    ),
    "watchAgain": MessageLookupByLibrary.simpleMessage("Watch again"),
    "watched": MessageLookupByLibrary.simpleMessage("Watched"),
    "weakConnectionRetrying": MessageLookupByLibrary.simpleMessage(
      "Weak connection, retrying...",
    ),
    "worksheetsWithCount": m39,
    "yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers":
        MessageLookupByLibrary.simpleMessage(
          "Your password must contain at least 8 characters including letters and numbers",
        ),
    "zoomIn": MessageLookupByLibrary.simpleMessage("Zoom in"),
    "zoomModeBadge": MessageLookupByLibrary.simpleMessage("Zoom mode"),
    "zoomOut": MessageLookupByLibrary.simpleMessage("Zoom out"),
    "zoomPosBottom": MessageLookupByLibrary.simpleMessage("Bottom"),
    "zoomPosCenter": MessageLookupByLibrary.simpleMessage("Center"),
    "zoomPosFull": MessageLookupByLibrary.simpleMessage("Whole frame"),
    "zoomPosLeft": MessageLookupByLibrary.simpleMessage("Left"),
    "zoomPosRight": MessageLookupByLibrary.simpleMessage("Right"),
    "zoomPosTop": MessageLookupByLibrary.simpleMessage("Top"),
    "zoomPosition": MessageLookupByLibrary.simpleMessage("View position"),
    "zoomTipMap": MessageLookupByLibrary.simpleMessage("Tap the map to jump"),
    "zoomTipPan": MessageLookupByLibrary.simpleMessage("Drag to move around"),
    "zoomTipPinch": MessageLookupByLibrary.simpleMessage(
      "Pinch to zoom up to 4×",
    ),
    "zoomTitle": MessageLookupByLibrary.simpleMessage("Zoom"),
    "zoomVisibleArea": MessageLookupByLibrary.simpleMessage("Visible area"),
    "zoomWatermarkNote": MessageLookupByLibrary.simpleMessage(
      "The watermark stays on top of the zoomed picture, so zooming can\'t hide it.",
    ),
    "zoomYourPosition": MessageLookupByLibrary.simpleMessage("You are here"),
  };
}
