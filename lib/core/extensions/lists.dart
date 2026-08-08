extension NullOrEmpty on List? {
  bool isNullOrEmpty() {
    if (this == null || this!.isEmpty) return true;
    return false;
  }
}

typedef ItemComparator<T> = bool Function(T a, T b);
typedef KeySelector<T, K> = K Function(T item);

extension ListComparisonExtension<T> on List<T>? {
  /// Compares this list with [other] using either:
  /// - a custom [comparator], OR
  /// - a [keySelector] to compare derived keys.
  ///
  /// If both are provided, [comparator] takes precedence.
  ///
  /// [ignoreOrder] determines whether list ordering matters.
  bool isEqualTo(
    List<T>? other, {
    ItemComparator<T>? comparator,
    KeySelector<T, Object?>? keySelector,
    bool ignoreOrder = true,
  }) {
    final listA = this;
    final listB = other;

    // ✅ Handle null lists
    if (identical(listA, listB)) return true;
    if (listA == null || listB == null) return false;

    // ✅ Length check
    if (listA.length != listB.length) return false;

    // ✅ Empty lists
    if (listA.isEmpty && listB.isEmpty) return true;

    // Resolve comparison strategy
    bool compareItems(T a, T b) {
      if (comparator != null) {
        return comparator(a, b);
      } else if (keySelector != null) {
        return keySelector(a) == keySelector(b);
      } else {
        return a == b;
      }
    }

    if (ignoreOrder) {
      // Order-insensitive comparison
      final matched = List<bool>.filled(listB.length, false);

      for (final itemA in listA) {
        bool found = false;

        for (int i = 0; i < listB.length; i++) {
          if (!matched[i] && compareItems(itemA, listB[i])) {
            matched[i] = true;
            found = true;
            break;
          }
        }

        if (!found) return false;
      }

      return true;
    } else {
      // Order-sensitive comparison
      for (int i = 0; i < listA.length; i++) {
        if (!compareItems(listA[i], listB[i])) {
          return false;
        }
      }
      return true;
    }
  }
}
