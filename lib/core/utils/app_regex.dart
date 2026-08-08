abstract class AppRegex {
  AppRegex._();

  static final RegExp fullNameRegex = RegExp(
    r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF a-zA-Z\s\-_]+$',
  );

  static final RegExp passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$');

  static final RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );
}
