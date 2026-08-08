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

  /// `Example items`
  String get exampleItems {
    return Intl.message(
      'Example items',
      name: 'exampleItems',
      desc: '',
      args: [],
    );
  }

  /// `A reference feature you can copy`
  String get exampleItemsSubtitle {
    return Intl.message(
      'A reference feature you can copy',
      name: 'exampleItemsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No items yet`
  String get emptyExampleItemsTitle {
    return Intl.message(
      'No items yet',
      name: 'emptyExampleItemsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pull to refresh and try again`
  String get emptyExampleItemsSubtitle {
    return Intl.message(
      'Pull to refresh and try again',
      name: 'emptyExampleItemsSubtitle',
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
