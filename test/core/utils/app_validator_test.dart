import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/utils/app_validator.dart';
import 'package:mobile_template/generated/l10n.dart';

/// Validators return `null` when the value is valid and a localized message
/// otherwise, so these assert on null-ness rather than on message text.
void main() {
  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  group('emailValidator', () {
    test('accepts well-formed addresses', () {
      for (final email in ['a@b.co', 'first.last+tag@sub.example.com']) {
        expect(AppValidator.emailValidator(email), isNull, reason: email);
      }
    });

    test('rejects empty and malformed addresses', () {
      for (final email in [null, '', '  ', 'plain', 'a@b', 'a@b.c', '@b.co', 'a b@c.co']) {
        expect(AppValidator.emailValidator(email), isNotNull, reason: '$email');
      }
    });
  });

  group('passwordValidator', () {
    test('accepts 8+ characters containing both letters and digits', () {
      expect(AppValidator.passwordValidator('abcd1234'), isNull);
    });

    test('rejects empty, too short, letters-only and digits-only passwords', () {
      for (final password in [null, '', 'ab1', 'abcdefgh', '12345678']) {
        expect(AppValidator.passwordValidator(password), isNotNull, reason: '$password');
      }
    });
  });

  group('confirmPasswordValidator', () {
    test('accepts a matching confirmation', () {
      expect(
        AppValidator.confirmPasswordValidator(confirmPassword: 'abcd1234', password: 'abcd1234'),
        isNull,
      );
    });

    test('rejects an empty or mismatched confirmation', () {
      expect(
        AppValidator.confirmPasswordValidator(confirmPassword: '', password: 'abcd1234'),
        isNotNull,
      );
      expect(
        AppValidator.confirmPasswordValidator(confirmPassword: 'other123', password: 'abcd1234'),
        isNotNull,
      );
    });
  });

  group('fullNameValidation', () {
    test('accepts Latin and Arabic names of at least two words', () {
      expect(AppValidator.fullNameValidation('Ada Lovelace'), isNull);
      expect(AppValidator.fullNameValidation('محمد الأحمد'), isNull);
    });

    test('rejects empty, single-word, and digit-bearing names', () {
      for (final name in [null, '', '   ', 'Ada', 'Ada L0velace']) {
        expect(AppValidator.fullNameValidation(name), isNotNull, reason: '$name');
      }
    });
  });

  group('phoneNumberValidator', () {
    test('accepts Syrian numbers in both 09xxxxxxxx and 9xxxxxxxx forms', () {
      expect(AppValidator.phoneNumberValidator('0912345678', '+963'), isNull);
      expect(AppValidator.phoneNumberValidator('912345678', '+963'), isNull);
    });

    test('rejects Syrian numbers of the wrong length or prefix', () {
      for (final phone in ['091234567', '91234567', '12345678']) {
        expect(AppValidator.phoneNumberValidator(phone, '+963'), isNotNull, reason: phone);
      }
    });

    test('rejects an empty number regardless of country', () {
      expect(AppValidator.phoneNumberValidator(null, '+963'), isNotNull);
      expect(AppValidator.phoneNumberValidator('', '+1'), isNotNull);
    });

    test('applies no length rule to non-Syrian country codes', () {
      expect(AppValidator.phoneNumberValidator('5551234', '+1'), isNull);
    });
  });

  group('verificationCodeValidator', () {
    test('accepts a code of exactly the configured length', () {
      expect(AppValidator.verificationCodeValidator('123456'), isNull);
    });

    test('rejects empty and wrong-length codes', () {
      for (final code in [null, '', '12345', '1234567']) {
        expect(AppValidator.verificationCodeValidator(code), isNotNull, reason: '$code');
      }
    });
  });

  group('canNotBeEmpty', () {
    test('accepts non-blank values and rejects blank ones', () {
      expect(AppValidator.canNotBeEmpty('x'), isNull);
      expect(AppValidator.canNotBeEmpty(null), isNotNull);
      expect(AppValidator.canNotBeEmpty('   '), isNotNull);
    });
  });
}
