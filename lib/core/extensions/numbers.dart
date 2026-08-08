extension NullOrZero on num? {
  bool isNullOrZero() {
    if (this == null || this == 0) return true;
    return false;
  }
}
