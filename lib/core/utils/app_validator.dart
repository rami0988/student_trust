import '../../generated/l10n.dart';
import '../extensions/strings.dart';
import 'app_regex.dart';
import 'constants.dart';

abstract class AppValidator {
  AppValidator._();

  static String? canNotBeEmpty(String? value) {
    if (value.isNullOrEmpty()) {
      return S.current.fieldIsRequired;
    }
    return null;
  }

  static String? fullNameValidation(String? value) {
    if (value?.trim().isNullOrEmpty() ?? true) {
      return S.current.pleaseEnterYourFullName;
    }
    final String name = value!.trim();

    // Ensure it has at least two words (first and last name)
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return S.current.pleaseEnterAtLeastFirstAndLastName;
    }

    if (!AppRegex.fullNameRegex.hasMatch(name)) {
      return S.current.fullNameCanOnlyContainLettersOrSpaces;
    }

    return null;
  }

  static String? phoneNumberValidator(String? phoneNumber, String countryCode) {
    if (phoneNumber.isNullOrEmpty()) {
      return S.current.pleaseEnterPhoneNumber;
    }

    if (countryCode == '+963') {
      if (phoneNumber!.startsWith('09')) {
        if (phoneNumber.length != 10) {
          return S.current.syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain;
        }
      } else if (phoneNumber.startsWith('9')) {
        if (phoneNumber.length != 9) {
          return S.current.syrianPhoneNumbersShouldBe9DigitsPleaseCheckAndTryAgain;
        }
      } else {
        return S.current.syrianPhoneNumbersShouldBe10DigitsPleaseCheckAndTryAgain;
      }
    }

    return null;
  }

  static String? passwordValidator(String? password) {
    if (password.isNullOrEmpty()) {
      return S.current.pleaseEnterPassword;
    } else if (password!.length < 8) {
      return S.current.passwordShouldAtLeast8Character;
    } else if (!AppRegex.passwordRegex.hasMatch(password)) {
      return S.current.yourPasswordMustContainAtLeast8CharactersIncludingLettersAndNumbers;
    }
    return null;
  }

  static String? confirmPasswordValidator({
    required String? confirmPassword,
    required String password,
  }) {
    if (confirmPassword.isNullOrEmpty()) {
      return S.current.pleaseConfirmYourPassword;
    }
    if (password != confirmPassword) {
      return S.current.passwordsDoNotMatch;
    }
    return null;
  }

  static String? verificationCodeValidator(String? verificationCode) {
    if (verificationCode.isNullOrEmpty()) {
      return S.current.pleaseEnterVerificationCode;
    } else if (verificationCode!.length != Constants.otpCodeLength) {
      return S.current.pleaseCompleteVerificationCode;
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email.isNullOrEmpty()) {
      return S.current.PleaseEnterEmail;
    } else if (!AppRegex.emailRegExp.hasMatch(email!)) {
      return S.current.emailFormatNotCorrect;
    }
    return null;
  }
}
