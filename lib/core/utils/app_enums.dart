enum Status {
  initial,
  loading,
  success,
  failure,
  empty;

  bool get isInitial => this == Status.initial;
  bool get isLoading => this == Status.loading;
  bool get isSuccess => this == Status.success;
  bool get isFailure => this == Status.failure;
  bool get isEmpty => this == Status.empty;
}

enum AppFlavor {
  development,
  production,
  none;

  bool get isDevelopment => this == AppFlavor.development;
  bool get isProduction => this == AppFlavor.production;
  bool get isNone => this == AppFlavor.none;
}

enum Language {
  en,
  ar;

  static Language fromValue(String value) {
    return Language.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Language.ar,
    );
  }

  bool get isEnglish => this == Language.en;
  bool get isArabic => this == Language.ar;
}

enum Gender {
  male,
  female,
  unknown;

  static Gender fromValue(String? value) {
    return Gender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => Gender.unknown,
    );
  }

  String toValue() => name;

  bool get isMale => this == Gender.male;
  bool get isFemale => this == Gender.female;
  bool get isUnknown => this == Gender.unknown;
}

enum MediaType {
  image,
  video,
  icon,
  unknown;

  static const _imageExtensions = {'png', 'jpg', 'jpeg', 'webp', 'image'};
  static const _videoExtensions = {'mp4', 'mkv', 'video'};
  static const _iconExtensions = {'svg', 'icon'};

  static MediaType fromValue(String? value) {
    final normalized = value?.toLowerCase().trim();
    if (normalized == null) return MediaType.unknown;
    if (_imageExtensions.contains(normalized)) return MediaType.image;
    if (_videoExtensions.contains(normalized)) return MediaType.video;
    if (_iconExtensions.contains(normalized)) return MediaType.icon;
    return MediaType.unknown;
  }

  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;
  bool get isIcon => this == MediaType.icon;
  bool get isUnknown => this == MediaType.unknown;
}
