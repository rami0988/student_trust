import 'package:path/path.dart' as p;

extension NullOrEmpty on String? {
  bool isNullOrEmpty() => this == null || this!.trim().isEmpty;
}

extension UriExt on String {
  String? get fileExtension => p.extension(Uri.parse(this).path).replaceFirst('.', '').toLowerCase().nullIfEmpty();
}

extension StringExt on String {
  String? nullIfEmpty() => isEmpty ? null : this;
}
