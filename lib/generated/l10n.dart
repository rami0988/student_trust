// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Please enter your email`
  String get PleaseEnterEmail {
    return Intl.message(
      'Please enter your email',
      name: 'PleaseEnterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Thiqa`
  String get appName {
    return Intl.message('Thiqa', name: 'appName', desc: '', args: []);
  }

  /// `We meet at the top`
  String get loginSubtitle {
    return Intl.message(
      'We meet at the top',
      name: 'loginSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Log in`
  String get loginButton {
    return Intl.message('Log in', name: 'loginButton', desc: '', args: []);
  }

  /// `Username is required`
  String get usernameRequired {
    return Intl.message(
      'Username is required',
      name: 'usernameRequired',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get passwordRequired {
    return Intl.message(
      'Password is required',
      name: 'passwordRequired',
      desc: '',
      args: [],
    );
  }

  /// `Subjects`
  String get subjects {
    return Intl.message('Subjects', name: 'subjects', desc: '', args: []);
  }

  /// `Subscribed`
  String get subscribed {
    return Intl.message('Subscribed', name: 'subscribed', desc: '', args: []);
  }

  /// `Not subscribed`
  String get notSubscribed {
    return Intl.message(
      'Not subscribed',
      name: 'notSubscribed',
      desc: '',
      args: [],
    );
  }

  /// `No subjects available`
  String get noSubjects {
    return Intl.message(
      'No subjects available',
      name: 'noSubjects',
      desc: '',
      args: [],
    );
  }

  /// `Search a subject...`
  String get searchSubjectHint {
    return Intl.message(
      'Search a subject...',
      name: 'searchSubjectHint',
      desc: '',
      args: [],
    );
  }

  /// `No subjects match your search`
  String get noSearchResults {
    return Intl.message(
      'No subjects match your search',
      name: 'noSearchResults',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Chapters`
  String get chapters {
    return Intl.message('Chapters', name: 'chapters', desc: '', args: []);
  }

  /// `Lessons`
  String get lessons {
    return Intl.message('Lessons', name: 'lessons', desc: '', args: []);
  }

  /// `No chapters available`
  String get noChapters {
    return Intl.message(
      'No chapters available',
      name: 'noChapters',
      desc: '',
      args: [],
    );
  }

  /// `No lessons available`
  String get noLessons {
    return Intl.message(
      'No lessons available',
      name: 'noLessons',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Video paused`
  String get videoPaused {
    return Intl.message(
      'Video paused',
      name: 'videoPaused',
      desc: '',
      args: [],
    );
  }

  /// `Screen recording detected\nStop the recording app to continue`
  String get recordingDetected {
    return Intl.message(
      'Screen recording detected\nStop the recording app to continue',
      name: 'recordingDetected',
      desc: '',
      args: [],
    );
  }

  /// `Video is processing\nTry again shortly`
  String get videoProcessingMessage {
    return Intl.message(
      'Video is processing\nTry again shortly',
      name: 'videoProcessingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Fullscreen`
  String get enterFullscreen {
    return Intl.message(
      'Fullscreen',
      name: 'enterFullscreen',
      desc: '',
      args: [],
    );
  }

  /// `Exit fullscreen`
  String get exitFullscreen {
    return Intl.message(
      'Exit fullscreen',
      name: 'exitFullscreen',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred`
  String get genericError {
    return Intl.message(
      'An unexpected error occurred',
      name: 'genericError',
      desc: '',
      args: [],
    );
  }

  /// `Downloaded`
  String get downloaded {
    return Intl.message('Downloaded', name: 'downloaded', desc: '', args: []);
  }

  /// `Worksheets ({count})`
  String worksheetsWithCount(int count) {
    return Intl.message(
      'Worksheets ($count)',
      name: 'worksheetsWithCount',
      desc: '',
      args: [count],
    );
  }

  /// `No worksheets yet`
  String get noWorksheets {
    return Intl.message(
      'No worksheets yet',
      name: 'noWorksheets',
      desc: '',
      args: [],
    );
  }

  /// `Files`
  String get filesSectionTitle {
    return Intl.message('Files', name: 'filesSectionTitle', desc: '', args: []);
  }

  /// `Explanation & Solution`
  String get solutionsSectionTitle {
    return Intl.message(
      'Explanation & Solution',
      name: 'solutionsSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `No files`
  String get noFiles {
    return Intl.message('No files', name: 'noFiles', desc: '', args: []);
  }

  /// `No solution videos`
  String get noSolutionVideos {
    return Intl.message(
      'No solution videos',
      name: 'noSolutionVideos',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Download to device`
  String get downloadToDeviceTooltip {
    return Intl.message(
      'Download to device',
      name: 'downloadToDeviceTooltip',
      desc: '',
      args: [],
    );
  }

  /// `File saved to your Downloads folder`
  String get savedToDownloads {
    return Intl.message(
      'File saved to your Downloads folder',
      name: 'savedToDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't display the file`
  String get pdfDisplayError {
    return Intl.message(
      'Couldn\'t display the file',
      name: 'pdfDisplayError',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message('Download', name: 'download', desc: '', args: []);
  }

  /// `Delete download`
  String get deleteDownload {
    return Intl.message(
      'Delete download',
      name: 'deleteDownload',
      desc: '',
      args: [],
    );
  }

  /// `Remove this lesson from your downloads?`
  String get deleteDownloadConfirm {
    return Intl.message(
      'Remove this lesson from your downloads?',
      name: 'deleteDownloadConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Resume`
  String get resumeDownload {
    return Intl.message('Resume', name: 'resumeDownload', desc: '', args: []);
  }

  /// `Pause`
  String get pauseDownload {
    return Intl.message('Pause', name: 'pauseDownload', desc: '', args: []);
  }

  /// `Cancel download`
  String get cancelDownload {
    return Intl.message(
      'Cancel download',
      name: 'cancelDownload',
      desc: '',
      args: [],
    );
  }

  /// `Please connect to the internet to verify your subscription`
  String get validationRequired {
    return Intl.message(
      'Please connect to the internet to verify your subscription',
      name: 'validationRequired',
      desc: '',
      args: [],
    );
  }

  /// `Downloads`
  String get downloadsTitle {
    return Intl.message(
      'Downloads',
      name: 'downloadsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offlineIndicator {
    return Intl.message(
      'Offline',
      name: 'offlineIndicator',
      desc: '',
      args: [],
    );
  }

  /// `You're offline — showing downloads only`
  String get offlineBanner {
    return Intl.message(
      'You\'re offline — showing downloads only',
      name: 'offlineBanner',
      desc: '',
      args: [],
    );
  }

  /// `No downloaded videos`
  String get noDownloadedVideos {
    return Intl.message(
      'No downloaded videos',
      name: 'noDownloadedVideos',
      desc: '',
      args: [],
    );
  }

  /// `Download videos while online to watch them later`
  String get noDownloadedVideosSubtitle {
    return Intl.message(
      'Download videos while online to watch them later',
      name: 'noDownloadedVideosSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Retry connection`
  String get retryConnection {
    return Intl.message(
      'Retry connection',
      name: 'retryConnection',
      desc: '',
      args: [],
    );
  }

  /// `Still no internet connection`
  String get stillOffline {
    return Intl.message(
      'Still no internet connection',
      name: 'stillOffline',
      desc: '',
      args: [],
    );
  }

  /// `Available offline`
  String get availableOffline {
    return Intl.message(
      'Available offline',
      name: 'availableOffline',
      desc: '',
      args: [],
    );
  }

  /// `{count} downloaded`
  String downloadsCount(int count) {
    return Intl.message(
      '$count downloaded',
      name: 'downloadsCount',
      desc: '',
      args: [count],
    );
  }

  /// `Account`
  String get settingsAccountSection {
    return Intl.message(
      'Account',
      name: 'settingsAccountSection',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get settingsAppSection {
    return Intl.message('App', name: 'settingsAppSection', desc: '', args: []);
  }

  /// `Support`
  String get settingsSupportSection {
    return Intl.message(
      'Support',
      name: 'settingsSupportSection',
      desc: '',
      args: [],
    );
  }

  /// `Danger zone`
  String get settingsDangerSection {
    return Intl.message(
      'Danger zone',
      name: 'settingsDangerSection',
      desc: '',
      args: [],
    );
  }

  /// `Student`
  String get studentLabel {
    return Intl.message('Student', name: 'studentLabel', desc: '', args: []);
  }

  /// `9th grade`
  String get gradeNine {
    return Intl.message('9th grade', name: 'gradeNine', desc: '', args: []);
  }

  /// `Baccalaureate`
  String get gradeBac {
    return Intl.message('Baccalaureate', name: 'gradeBac', desc: '', args: []);
  }

  /// `General`
  String get gradeGeneral {
    return Intl.message('General', name: 'gradeGeneral', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message('Coming soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Appearance`
  String get appTheme {
    return Intl.message('Appearance', name: 'appTheme', desc: '', args: []);
  }

  /// `Match system`
  String get themeModeSystem {
    return Intl.message(
      'Match system',
      name: 'themeModeSystem',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get themeModeLight {
    return Intl.message('Light', name: 'themeModeLight', desc: '', args: []);
  }

  /// `Dark`
  String get themeModeDark {
    return Intl.message('Dark', name: 'themeModeDark', desc: '', args: []);
  }

  /// `Contact us`
  String get contactUs {
    return Intl.message('Contact us', name: 'contactUs', desc: '', args: []);
  }

  /// `Email us and we'll get back to you shortly:`
  String get contactUsMessage {
    return Intl.message(
      'Email us and we\'ll get back to you shortly:',
      name: 'contactUsMessage',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message('Copy', name: 'copy', desc: '', args: []);
  }

  /// `Email copied`
  String get emailCopied {
    return Intl.message(
      'Email copied',
      name: 'emailCopied',
      desc: '',
      args: [],
    );
  }

  /// `App version`
  String get appVersion {
    return Intl.message('App version', name: 'appVersion', desc: '', args: []);
  }

  /// `Log out`
  String get logout {
    return Intl.message('Log out', name: 'logout', desc: '', args: []);
  }

  /// `Are you sure you want to log out?`
  String get logoutConfirm {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logoutConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete account`
  String get deleteAccount {
    return Intl.message(
      'Delete account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Your account will be permanently deleted and this cannot be undone. Are you sure?`
  String get deleteAccountConfirm {
    return Intl.message(
      'Your account will be permanently deleted and this cannot be undone. Are you sure?',
      name: 'deleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Couldn't delete the account, please try again`
  String get deleteAccountFailed {
    return Intl.message(
      'Couldn\'t delete the account, please try again',
      name: 'deleteAccountFailed',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Unsafe device`
  String get unsafeDeviceTitle {
    return Intl.message(
      'Unsafe device',
      name: 'unsafeDeviceTitle',
      desc: '',
      args: [],
    );
  }

  /// `This app is running on an emulator.\nIt can only run on a physical device.`
  String get emulatorDetectedMessage {
    return Intl.message(
      'This app is running on an emulator.\nIt can only run on a physical device.',
      name: 'emulatorDetectedMessage',
      desc: '',
      args: [],
    );
  }

  /// `{count} files`
  String filesCount(int count) {
    return Intl.message(
      '$count files',
      name: 'filesCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} solution videos`
  String solutionVideosCount(int count) {
    return Intl.message(
      '$count solution videos',
      name: 'solutionVideosCount',
      desc: '',
      args: [count],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `Email format is not correct`
  String get emailFormatNotCorrect {
    return Intl.message(
      'Email format is not correct',
      name: 'emailFormatNotCorrect',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load saved data, please try again`
  String get failedToLoadDataPleaseTryAgain {
    return Intl.message(
      'Failed to load saved data, please try again',
      name: 'failedToLoadDataPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get fieldIsRequired {
    return Intl.message(
      'This field is required',
      name: 'fieldIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Full name can only contain letters or spaces`
  String get fullNameCanOnlyContainLettersOrSpaces {
    return Intl.message(
      'Full name can only contain letters or spaces',
      name: 'fullNameCanOnlyContainLettersOrSpaces',
      desc: '',
      args: [],
    );
  }

  /// `It seems you're not connected to the internet. Please check your connection and try again.`
  String get networkErrorSubtitle {
    return Intl.message(
      'It seems you\'re not connected to the internet. Please check your connection and try again.',
      name: 'networkErrorSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No Internet Connection`
  String get networkErrorTitle {
    return Intl.message(
      'No Internet Connection',
      name: 'networkErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Oops! Something went wrong. Please try again`
  String get oopsSomethingWentWrongPleaseTryAgain {
    return Intl.message(
      'Oops! Something went wrong. Please try again',
      name: 'oopsSomethingWentWrongPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Password should be at least 8 characters`
  String get passwordShouldAtLeast8Character {
    return Intl.message(
      'Password should be at least 8 characters',
      name: 'passwordShouldAtLeast8Character',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please complete the 6-digit verification code`
  String get pleaseCompleteVerificationCode {
    return Intl.message(
      'Please complete the 6-digit verification code',
      name: 'pleaseCompleteVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password`
  String get pleaseConfirmYourPassword {
    return Intl.message(
      'Please confirm your password',
      name: 'pleaseConfirmYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter at least first and last name`
  String get pleaseEnterAtLeastFirstAndLastName {
    return Intl.message(
      'Please enter at least first and last name',
      name: 'pleaseEnterAtLeastFirstAndLastName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get pleaseEnterPassword {
    return Intl.message(
      'Please enter your password',
      name: 'pleaseEnterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get pleaseEnterPhoneNumber {
    return Intl.message(
      'Please enter your phone number',
      name: 'pleaseEnterPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the verification code`
  String get pleaseEnterVerificationCode {
    return Intl.message(
      'Please enter the verification code',
      name: 'pleaseEnterVerificationCode',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your full name`
  String get pleaseEnterYourFullName {
    return Intl.message(
      'Please enter your full name',
      name: 'pleaseEnterYourFullName',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get retry {
    return Intl.message('Try Again', name: 'retry', desc: '', args: []);
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Select Country`
  String get selectCountry {
    return Intl.message(
      'Select Country',
      name: 'selectCountry',
      desc: '',
      args: [],
    );
  }

  /// `A server error occurred, please try again later`
  String get serverErrorOccurredPleaseTryAgain {
    return Intl.message(
      'A server error occurred, please try again later',
      name: 'serverErrorOccurredPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, something went wrong on our end. We're working on it — please try again later.`
  String get serverErrorSubtitle {
    return Intl.message(
      'Sorry, something went wrong on our end. We\'re working on it — please try again later.',
      name: 'serverErrorSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Server Error`
  String get serverErrorTitle {
    return Intl.message(
      'Server Error',
      name: 'serverErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Show Less`
  String get showLess {
    return Intl.message('Show Less', name: 'showLess', desc: '', args: []);
  }

  /// `Show More`
  String get showMore {
    return Intl.message('Show More', name: 'showMore', desc: '', args: []);
  }

  /// `Oops! Something went wrong`
  String get somethingWentWrong {
    return Intl.message(
      'Oops! Something went wrong',
      name: 'somethingWentWrong',
      desc: '',
      args: [],
    );
  }

  /// `Syrian phone numbers should be 10 digits, please check and try again`
  String get syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain {
    return Intl.message(
      'Syrian phone numbers should be 10 digits, please check and try again',
      name: 'syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Syrian phone numbers should be 9 digits, please check and try again`
  String get syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain {
    return Intl.message(
      'Syrian phone numbers should be 9 digits, please check and try again',
      name: 'syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `There is problem with your connection, please try again`
  String get thereIsProblemWithYourConnectionPleaseTryAgain {
    return Intl.message(
      'There is problem with your connection, please try again',
      name: 'thereIsProblemWithYourConnectionPleaseTryAgain',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{{count} day ago} other{{count} days ago}}`
  String timeAgoDays(num count) {
    return Intl.plural(
      count,
      one: '$count day ago',
      other: '$count days ago',
      name: 'timeAgoDays',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} hour ago} other{{count} hours ago}}`
  String timeAgoHours(num count) {
    return Intl.plural(
      count,
      one: '$count hour ago',
      other: '$count hours ago',
      name: 'timeAgoHours',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} min ago} other{{count} mins ago}}`
  String timeAgoMinutes(num count) {
    return Intl.plural(
      count,
      one: '$count min ago',
      other: '$count mins ago',
      name: 'timeAgoMinutes',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{{count} month ago} other{{count} months ago}}`
  String timeAgoMonths(num count) {
    return Intl.plural(
      count,
      one: '$count month ago',
      other: '$count months ago',
      name: 'timeAgoMonths',
      desc: '',
      args: [count],
    );
  }

  /// `just now`
  String get timeAgoNow {
    return Intl.message('just now', name: 'timeAgoNow', desc: '', args: []);
  }

  /// `{count, plural, one{{count} year ago} other{{count} years ago}}`
  String timeAgoYears(num count) {
    return Intl.plural(
      count,
      one: '$count year ago',
      other: '$count years ago',
      name: 'timeAgoYears',
      desc: '',
      args: [count],
    );
  }

  /// `Your password must contain at least 8 characters including letters and numbers`
  String
  get yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers {
    return Intl.message(
      'Your password must contain at least 8 characters including letters and numbers',
      name:
          'yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
