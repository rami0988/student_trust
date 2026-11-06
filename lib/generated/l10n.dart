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

  /// `Playback speed`
  String get playbackSpeed {
    return Intl.message(
      'Playback speed',
      name: 'playbackSpeed',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get speedNormal {
    return Intl.message('Normal', name: 'speedNormal', desc: '', args: []);
  }

  /// `Reset zoom`
  String get resetZoom {
    return Intl.message('Reset zoom', name: 'resetZoom', desc: '', args: []);
  }

  /// `Play`
  String get playVideo {
    return Intl.message('Play', name: 'playVideo', desc: '', args: []);
  }

  /// `Pause`
  String get pauseVideo {
    return Intl.message('Pause', name: 'pauseVideo', desc: '', args: []);
  }

  /// `Lesson {current} of {total}`
  String lessonOfCount(Object current, Object total) {
    return Intl.message(
      'Lesson $current of $total',
      name: 'lessonOfCount',
      desc: '',
      args: [current, total],
    );
  }

  /// `Watched`
  String get watched {
    return Intl.message('Watched', name: 'watched', desc: '', args: []);
  }

  /// `About this lesson`
  String get aboutLesson {
    return Intl.message(
      'About this lesson',
      name: 'aboutLesson',
      desc: '',
      args: [],
    );
  }

  /// `Speed`
  String get speedLabel {
    return Intl.message('Speed', name: 'speedLabel', desc: '', args: []);
  }

  /// `Quality`
  String get qualityLabel {
    return Intl.message('Quality', name: 'qualityLabel', desc: '', args: []);
  }

  /// `Playback settings`
  String get playbackSettings {
    return Intl.message(
      'Playback settings',
      name: 'playbackSettings',
      desc: '',
      args: [],
    );
  }

  /// `Saved for all lessons`
  String get speedSavedForAll {
    return Intl.message(
      'Saved for all lessons',
      name: 'speedSavedForAll',
      desc: '',
      args: [],
    );
  }

  /// `Video quality`
  String get videoQuality {
    return Intl.message(
      'Video quality',
      name: 'videoQuality',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get qualityDefaultTag {
    return Intl.message(
      'Default',
      name: 'qualityDefaultTag',
      desc: '',
      args: [],
    );
  }

  /// `For very weak connections`
  String get qualityLowDesc {
    return Intl.message(
      'For very weak connections',
      name: 'qualityLowDesc',
      desc: '',
      args: [],
    );
  }

  /// `Data saver`
  String get qualityDataSaverDesc {
    return Intl.message(
      'Data saver',
      name: 'qualityDataSaverDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sharp board text`
  String get qualityHighDesc {
    return Intl.message(
      'Sharp board text',
      name: 'qualityHighDesc',
      desc: '',
      args: [],
    );
  }

  /// `Best on Wi-Fi`
  String get qualityFullDesc {
    return Intl.message(
      'Best on Wi-Fi',
      name: 'qualityFullDesc',
      desc: '',
      args: [],
    );
  }

  /// `Up next`
  String get upNext {
    return Intl.message('Up next', name: 'upNext', desc: '', args: []);
  }

  /// `Change`
  String get change {
    return Intl.message('Change', name: 'change', desc: '', args: []);
  }

  /// `At {speed}, you'll save {saved} on this lesson!`
  String timeSavedFaster(Object speed, Object saved) {
    return Intl.message(
      'At $speed, you\'ll save $saved on this lesson!',
      name: 'timeSavedFaster',
      desc: '',
      args: [speed, saved],
    );
  }

  /// `Across the whole chapter you save {saved}.`
  String timeSavedChapter(Object saved) {
    return Intl.message(
      'Across the whole chapter you save $saved.',
      name: 'timeSavedChapter',
      desc: '',
      args: [saved],
    );
  }

  /// `Normal speed: the lesson takes {duration}`
  String timeSavedNormal(Object duration) {
    return Intl.message(
      'Normal speed: the lesson takes $duration',
      name: 'timeSavedNormal',
      desc: '',
      args: [duration],
    );
  }

  /// `Try {speed} to save {saved} while keeping it clear.`
  String timeSavedTry(Object speed, Object saved) {
    return Intl.message(
      'Try $speed to save $saved while keeping it clear.',
      name: 'timeSavedTry',
      desc: '',
      args: [speed, saved],
    );
  }

  /// `Slower for deeper understanding: +{extra} to the lesson`
  String timeSavedSlower(Object extra) {
    return Intl.message(
      'Slower for deeper understanding: +$extra to the lesson',
      name: 'timeSavedSlower',
      desc: '',
      args: [extra],
    );
  }

  /// `Good for worked examples and the hard parts.`
  String get timeSavedSlowerHint {
    return Intl.message(
      'Good for worked examples and the hard parts.',
      name: 'timeSavedSlowerHint',
      desc: '',
      args: [],
    );
  }

  /// `At {speed} you save {saved} on this lesson`
  String timeSavedPillFaster(Object speed, Object saved) {
    return Intl.message(
      'At $speed you save $saved on this lesson',
      name: 'timeSavedPillFaster',
      desc: '',
      args: [speed, saved],
    );
  }

  /// `Try {speed} and save {saved} on this lesson`
  String timeSavedPillNormal(Object speed, Object saved) {
    return Intl.message(
      'Try $speed and save $saved on this lesson',
      name: 'timeSavedPillNormal',
      desc: '',
      args: [speed, saved],
    );
  }

  /// `At {speed}: +{extra} for deeper understanding`
  String timeSavedPillSlower(Object speed, Object extra) {
    return Intl.message(
      'At $speed: +$extra for deeper understanding',
      name: 'timeSavedPillSlower',
      desc: '',
      args: [speed, extra],
    );
  }

  /// `{count, plural, one{1 hour} other{{count} hours}}`
  String durationHours(num count) {
    return Intl.plural(
      count,
      one: '1 hour',
      other: '$count hours',
      name: 'durationHours',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 minute} other{{count} minutes}}`
  String durationMinutes(num count) {
    return Intl.plural(
      count,
      one: '1 minute',
      other: '$count minutes',
      name: 'durationMinutes',
      desc: '',
      args: [count],
    );
  }

  /// `{count, plural, one{1 second} other{{count} seconds}}`
  String durationSeconds(num count) {
    return Intl.plural(
      count,
      one: '1 second',
      other: '$count seconds',
      name: 'durationSeconds',
      desc: '',
      args: [count],
    );
  }

  /// `{first} {second}`
  String durationJoin(Object first, Object second) {
    return Intl.message(
      '$first $second',
      name: 'durationJoin',
      desc: '',
      args: [first, second],
    );
  }

  /// `{time} left at {speed}`
  String remainingAtSpeed(Object time, Object speed) {
    return Intl.message(
      '$time left at $speed',
      name: 'remainingAtSpeed',
      desc: '',
      args: [time, speed],
    );
  }

  /// `Back {seconds} seconds`
  String skipBack(Object seconds) {
    return Intl.message(
      'Back $seconds seconds',
      name: 'skipBack',
      desc: '',
      args: [seconds],
    );
  }

  /// `Forward {seconds} seconds`
  String skipForward(Object seconds) {
    return Intl.message(
      'Forward $seconds seconds',
      name: 'skipForward',
      desc: '',
      args: [seconds],
    );
  }

  /// `{seconds}s`
  String secondsShort(Object seconds) {
    return Intl.message(
      '${seconds}s',
      name: 'secondsShort',
      desc: '',
      args: [seconds],
    );
  }

  /// `Pinch to zoom`
  String get pinchToZoom {
    return Intl.message(
      'Pinch to zoom',
      name: 'pinchToZoom',
      desc: '',
      args: [],
    );
  }

  /// `Zoom`
  String get zoomTitle {
    return Intl.message('Zoom', name: 'zoomTitle', desc: '', args: []);
  }

  /// `Zoom mode`
  String get zoomModeBadge {
    return Intl.message('Zoom mode', name: 'zoomModeBadge', desc: '', args: []);
  }

  /// `Visible area`
  String get zoomVisibleArea {
    return Intl.message(
      'Visible area',
      name: 'zoomVisibleArea',
      desc: '',
      args: [],
    );
  }

  /// `View position`
  String get zoomPosition {
    return Intl.message(
      'View position',
      name: 'zoomPosition',
      desc: '',
      args: [],
    );
  }

  /// `Whole frame`
  String get zoomPosFull {
    return Intl.message('Whole frame', name: 'zoomPosFull', desc: '', args: []);
  }

  /// `Center`
  String get zoomPosCenter {
    return Intl.message('Center', name: 'zoomPosCenter', desc: '', args: []);
  }

  /// `Left`
  String get zoomPosLeft {
    return Intl.message('Left', name: 'zoomPosLeft', desc: '', args: []);
  }

  /// `Right`
  String get zoomPosRight {
    return Intl.message('Right', name: 'zoomPosRight', desc: '', args: []);
  }

  /// `Top`
  String get zoomPosTop {
    return Intl.message('Top', name: 'zoomPosTop', desc: '', args: []);
  }

  /// `Bottom`
  String get zoomPosBottom {
    return Intl.message('Bottom', name: 'zoomPosBottom', desc: '', args: []);
  }

  /// `Pinch to zoom up to 4×`
  String get zoomTipPinch {
    return Intl.message(
      'Pinch to zoom up to 4×',
      name: 'zoomTipPinch',
      desc: '',
      args: [],
    );
  }

  /// `Drag to move around`
  String get zoomTipPan {
    return Intl.message(
      'Drag to move around',
      name: 'zoomTipPan',
      desc: '',
      args: [],
    );
  }

  /// `Tap the map to jump`
  String get zoomTipMap {
    return Intl.message(
      'Tap the map to jump',
      name: 'zoomTipMap',
      desc: '',
      args: [],
    );
  }

  /// `The watermark stays on top of the zoomed picture, so zooming can't hide it.`
  String get zoomWatermarkNote {
    return Intl.message(
      'The watermark stays on top of the zoomed picture, so zooming can\'t hide it.',
      name: 'zoomWatermarkNote',
      desc: '',
      args: [],
    );
  }

  /// `You are here`
  String get zoomYourPosition {
    return Intl.message(
      'You are here',
      name: 'zoomYourPosition',
      desc: '',
      args: [],
    );
  }

  /// `Zoom in`
  String get zoomIn {
    return Intl.message('Zoom in', name: 'zoomIn', desc: '', args: []);
  }

  /// `Zoom out`
  String get zoomOut {
    return Intl.message('Zoom out', name: 'zoomOut', desc: '', args: []);
  }

  /// `Attempt {attempt} of {max}`
  String retryAttempt(Object attempt, Object max) {
    return Intl.message(
      'Attempt $attempt of $max',
      name: 'retryAttempt',
      desc: '',
      args: [attempt, max],
    );
  }

  /// `in {seconds}s`
  String retryInSeconds(Object seconds) {
    return Intl.message(
      'in ${seconds}s',
      name: 'retryInSeconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `Retrying now`
  String get retryingNow {
    return Intl.message(
      'Retrying now',
      name: 'retryingNow',
      desc: '',
      args: [],
    );
  }

  /// `Resumes at {time}`
  String resumeFrom(Object time) {
    return Intl.message(
      'Resumes at $time',
      name: 'resumeFrom',
      desc: '',
      args: [time],
    );
  }

  /// `Couldn't play the video`
  String get cannotPlayVideo {
    return Intl.message(
      'Couldn\'t play the video',
      name: 'cannotPlayVideo',
      desc: '',
      args: [],
    );
  }

  /// `Continue where you left off`
  String get continueWhereLeft {
    return Intl.message(
      'Continue where you left off',
      name: 'continueWhereLeft',
      desc: '',
      args: [],
    );
  }

  /// `Start the chapter`
  String get startChapter {
    return Intl.message(
      'Start the chapter',
      name: 'startChapter',
      desc: '',
      args: [],
    );
  }

  /// `Watch again`
  String get watchAgain {
    return Intl.message('Watch again', name: 'watchAgain', desc: '', args: []);
  }

  /// `done`
  String get chapterDone {
    return Intl.message('done', name: 'chapterDone', desc: '', args: []);
  }

  /// `{count, plural, one{1 lesson} other{{count} lessons}}`
  String lessonsCount(num count) {
    return Intl.plural(
      count,
      one: '1 lesson',
      other: '$count lessons',
      name: 'lessonsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} completed`
  String completedCount(Object count) {
    return Intl.message(
      '$count completed',
      name: 'completedCount',
      desc: '',
      args: [count],
    );
  }

  /// `All`
  String get filterAll {
    return Intl.message('All', name: 'filterAll', desc: '', args: []);
  }

  /// `In progress`
  String get filterInProgress {
    return Intl.message(
      'In progress',
      name: 'filterInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get filterCompleted {
    return Intl.message(
      'Completed',
      name: 'filterCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Saved`
  String get filterDownloaded {
    return Intl.message('Saved', name: 'filterDownloaded', desc: '', args: []);
  }

  /// `{count, plural, one{1 lesson available offline} other{{count} lessons available offline}}`
  String offlineSummary(num count) {
    return Intl.plural(
      count,
      one: '1 lesson available offline',
      other: '$count lessons available offline',
      name: 'offlineSummary',
      desc: '',
      args: [count],
    );
  }

  /// `Encrypted on this device · re-checked every 7 days`
  String get offlineSummarySub {
    return Intl.message(
      'Encrypted on this device · re-checked every 7 days',
      name: 'offlineSummarySub',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} min left`
  String minutesLeft(Object minutes) {
    return Intl.message(
      '$minutes min left',
      name: 'minutesLeft',
      desc: '',
      args: [minutes],
    );
  }

  /// `New`
  String get newLesson {
    return Intl.message('New', name: 'newLesson', desc: '', args: []);
  }

  /// `Downloading · {percent}%`
  String downloadingPercent(Object percent) {
    return Intl.message(
      'Downloading · $percent%',
      name: 'downloadingPercent',
      desc: '',
      args: [percent],
    );
  }

  /// `Paused · {percent}%`
  String downloadPausedPercent(Object percent) {
    return Intl.message(
      'Paused · $percent%',
      name: 'downloadPausedPercent',
      desc: '',
      args: [percent],
    );
  }

  /// `Saved`
  String get savedOffline {
    return Intl.message('Saved', name: 'savedOffline', desc: '', args: []);
  }

  /// `No lessons in this filter`
  String get noLessonsInFilter {
    return Intl.message(
      'No lessons in this filter',
      name: 'noLessonsInFilter',
      desc: '',
      args: [],
    );
  }

  /// `{hours}h {minutes}m`
  String hoursMinutesShort(Object hours, Object minutes) {
    return Intl.message(
      '${hours}h ${minutes}m',
      name: 'hoursMinutesShort',
      desc: '',
      args: [hours, minutes],
    );
  }

  /// `{minutes}m`
  String minutesShort(Object minutes) {
    return Intl.message(
      '${minutes}m',
      name: 'minutesShort',
      desc: '',
      args: [minutes],
    );
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

  /// `Showing {shown} of {total}`
  String showingOfTotal(int shown, int total) {
    return Intl.message(
      'Showing $shown of $total',
      name: 'showingOfTotal',
      desc: '',
      args: [shown, total],
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

  /// `11th grade`
  String get gradeEleven {
    return Intl.message('11th grade', name: 'gradeEleven', desc: '', args: []);
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

  /// `Waiting`
  String get queuedDownload {
    return Intl.message('Waiting', name: 'queuedDownload', desc: '', args: []);
  }

  /// `Download failed`
  String get downloadFailed {
    return Intl.message(
      'Download failed',
      name: 'downloadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get retryDownload {
    return Intl.message('Try again', name: 'retryDownload', desc: '', args: []);
  }

  /// `This download is damaged - please download the lesson again`
  String get downloadCorrupted {
    return Intl.message(
      'This download is damaged - please download the lesson again',
      name: 'downloadCorrupted',
      desc: '',
      args: [],
    );
  }

  /// `The download stopped before it finished - please try again`
  String get downloadIncomplete {
    return Intl.message(
      'The download stopped before it finished - please try again',
      name: 'downloadIncomplete',
      desc: '',
      args: [],
    );
  }

  /// `My downloads`
  String get myDownloads {
    return Intl.message(
      'My downloads',
      name: 'myDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Manage downloads`
  String get manageDownloads {
    return Intl.message(
      'Manage downloads',
      name: 'manageDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Storage used`
  String get storageUsed {
    return Intl.message(
      'Storage used',
      name: 'storageUsed',
      desc: '',
      args: [],
    );
  }

  /// `Delete all downloads`
  String get deleteAllDownloads {
    return Intl.message(
      'Delete all downloads',
      name: 'deleteAllDownloads',
      desc: '',
      args: [],
    );
  }

  /// `Every downloaded lesson will be removed from this device. You can download them again any time.`
  String get deleteAllDownloadsConfirm {
    return Intl.message(
      'Every downloaded lesson will be removed from this device. You can download them again any time.',
      name: 'deleteAllDownloadsConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Deleted {count} lessons`
  String downloadsDeleted(int count) {
    return Intl.message(
      'Deleted $count lessons',
      name: 'downloadsDeleted',
      desc: '',
      args: [count],
    );
  }

  /// `Lesson removed from downloads`
  String get downloadDeleted {
    return Intl.message(
      'Lesson removed from downloads',
      name: 'downloadDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Total time`
  String get totalDuration {
    return Intl.message(
      'Total time',
      name: 'totalDuration',
      desc: '',
      args: [],
    );
  }

  /// `Weak connection, retrying...`
  String get weakConnectionRetrying {
    return Intl.message(
      'Weak connection, retrying...',
      name: 'weakConnectionRetrying',
      desc: '',
      args: [],
    );
  }

  /// `Not enough storage — free up space, then resume the download`
  String get insufficientStorage {
    return Intl.message(
      'Not enough storage — free up space, then resume the download',
      name: 'insufficientStorage',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for network`
  String get waitingForNetwork {
    return Intl.message(
      'Waiting for network',
      name: 'waitingForNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Download expired after 30 days — download the lesson again`
  String get downloadExpired {
    return Intl.message(
      'Download expired after 30 days — download the lesson again',
      name: 'downloadExpired',
      desc: '',
      args: [],
    );
  }

  /// `Locked — go online once to verify your subscription`
  String get downloadLocked {
    return Intl.message(
      'Locked — go online once to verify your subscription',
      name: 'downloadLocked',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get downloadsInProgress {
    return Intl.message(
      'In progress',
      name: 'downloadsInProgress',
      desc: '',
      args: [],
    );
  }

  /// `/s`
  String get perSecond {
    return Intl.message('/s', name: 'perSecond', desc: '', args: []);
  }

  /// `{time} left`
  String timeLeft(String time) {
    return Intl.message('$time left', name: 'timeLeft', desc: '', args: [time]);
  }

  /// `The downloaded file was damaged and removed — download the lesson again`
  String get mediaCorrupted {
    return Intl.message(
      'The downloaded file was damaged and removed — download the lesson again',
      name: 'mediaCorrupted',
      desc: '',
      args: [],
    );
  }

  /// `Your subscription to this subject ended, so the download was removed`
  String get subscriptionEndedDownloadRemoved {
    return Intl.message(
      'Your subscription to this subject ended, so the download was removed',
      name: 'subscriptionEndedDownloadRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Downloading`
  String get notificationDownloading {
    return Intl.message(
      'Downloading',
      name: 'notificationDownloading',
      desc: '',
      args: [],
    );
  }

  /// `Download paused`
  String get notificationPaused {
    return Intl.message(
      'Download paused',
      name: 'notificationPaused',
      desc: '',
      args: [],
    );
  }

  /// `Download failed — open the app to continue`
  String get notificationFailed {
    return Intl.message(
      'Download failed — open the app to continue',
      name: 'notificationFailed',
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
