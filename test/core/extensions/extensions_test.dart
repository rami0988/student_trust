import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/extensions/lists.dart';
import 'package:mobile_template/core/extensions/strings.dart';

void main() {
  group('String.isNullOrEmpty', () {
    test('treats null, empty and whitespace-only strings as empty', () {
      expect((null as String?).isNullOrEmpty(), isTrue);
      expect(''.isNullOrEmpty(), isTrue);
      expect('   '.isNullOrEmpty(), isTrue);
    });

    test('treats any non-blank string as non-empty', () {
      expect('a'.isNullOrEmpty(), isFalse);
      expect(' a '.isNullOrEmpty(), isFalse);
    });
  });

  group('String.fileExtension', () {
    test('extracts a lowercase extension from a URL, ignoring the query string', () {
      expect('https://cdn.example.com/a/b/photo.PNG'.fileExtension, 'png');
      expect('https://cdn.example.com/photo.jpg?w=100&h=200'.fileExtension, 'jpg');
    });

    test('returns null when there is no extension', () {
      expect('https://cdn.example.com/photo'.fileExtension, isNull);
    });
  });

  group('List.isNullOrEmpty', () {
    test('distinguishes null/empty lists from populated ones', () {
      expect((null as List?).isNullOrEmpty(), isTrue);
      expect(<int>[].isNullOrEmpty(), isTrue);
      expect([1].isNullOrEmpty(), isFalse);
    });
  });

  group('List.isEqualTo', () {
    test('ignores order by default and respects it when asked', () {
      expect([1, 2, 3].isEqualTo([3, 2, 1]), isTrue);
      expect([1, 2, 3].isEqualTo([3, 2, 1], ignoreOrder: false), isFalse);
      expect([1, 2, 3].isEqualTo([1, 2, 3], ignoreOrder: false), isTrue);
    });

    test('returns false for different lengths or a null counterpart', () {
      expect([1, 2].isEqualTo([1, 2, 3]), isFalse);
      expect([1].isEqualTo(null), isFalse);
    });

    test('treats two nulls and two empties as equal', () {
      expect((null as List<int>?).isEqualTo(null), isTrue);
      expect(<int>[].isEqualTo(<int>[]), isTrue);
    });

    test('compares by derived key when a keySelector is given', () {
      final a = [
        {'id': 1, 'name': 'old'},
      ];
      final b = [
        {'id': 1, 'name': 'new'},
      ];

      expect(a.isEqualTo(b), isFalse);
      expect(a.isEqualTo(b, keySelector: (item) => item['id']), isTrue);
    });

    test('gives the custom comparator precedence over the keySelector', () {
      expect(
        [1, 2].isEqualTo(
          [10, 20],
          comparator: (x, y) => y % x == 0,
          keySelector: (item) => item,
        ),
        isTrue,
      );
    });

    test('does not match one element against the same counterpart twice', () {
      // Without consumed-match tracking, [1, 1] would wrongly equal [1, 2].
      expect([1, 1].isEqualTo([1, 2]), isFalse);
    });
  });
}
