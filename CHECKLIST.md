# Day-1 checklist for a new project

Work top to bottom. Items marked (optional) can wait.

## 1. Identity

- [ ] `dart run scripts/rename.dart --name "My App" --package my_app --bundle-id com.company.my_app`
- [ ] `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
- [ ] Replace launcher icons (`android/app/src/main/res/mipmap-*`, iOS asset catalog).
- [ ] (optional) Configure `flutter_native_splash` and run `dart run flutter_native_splash:create`.

## 1b. Release signing (before you ship — not before you start)

`android/app/build.gradle.kts` signs release builds with the **debug** keystore so
`flutter run --release` works out of the box. Google Play will reject that. Create a
keystore, add `android/key.properties` (git-ignored), and replace the
`signingConfig = signingConfigs.getByName("debug")` line before your first upload.

## 2. Backend

- [ ] Set the real server URLs in `lib/main.dart` and `lib/main_development.dart`
      (`Endpoints.setServerUrl(...)`), replacing `Endpoints.mockServerUrl`.
- [ ] Delete `lib/core/network/mock_api_interceptor.dart` and its registration in
      `DioFactory`, plus `mockServerUrl`/`isMockServer` in `Endpoints`.
- [ ] Replace the example endpoints in `Endpoints` with your API's.
- [ ] Confirm your API uses the `{success, message, data, meta}` envelope; adjust
      `BaseModel`/`MetaModel` field names if not.

## 3. Branding

- [ ] Edit `lib/core/theme/colors_manager.dart` (palette) — everything reads from here.
- [ ] Edit `lib/core/theme/font_manager.dart` + swap font files in `assets/fonts/` and the
      `fonts:` section of pubspec.yaml if you're not keeping Tajawal/Cairo.
- [ ] Review `CustomScaffold` header styling (colored header + white sheet).
- [ ] Default language is Arabic (`AppState.initial` / `AppRepositoryImpl`); switch the
      fallbacks to `Language.en` if this app is English-first.

## 4. Firebase (optional — the app runs without it)

- [ ] `dart pub global activate flutterfire_cli`
- [ ] `flutterfire configure` per environment; put the generated options into
      `lib/firebase/firebase_options_dev.dart` and `firebase_options_prod.dart`
      (keep the file names; class stays `DefaultFirebaseOptions`).
- [ ] Set `useFirebase = true` in both entry points.
- [ ] Call `getIt<NotificationsHelper>().initNotifications()` where you want push
      permission requested (e.g. after login).
- [ ] Implement `NotificationsHelper.onTapNotification` payload → route mapping.
- [ ] Android: add `google-services.json` + Google Services Gradle plugin;
      iOS: `GoogleService-Info.plist` + push capability.

## 5. Replace the example feature

- [ ] Build your first real feature (see CONTRIBUTING.md) and point the initial route at it
      (`Routes` + `AppRouter` + `TemplateApp.initialRoute`).
- [ ] Delete `lib/features/example_feature`, its routes, its endpoints,
      `core/event_bus/example_item_changed_event.dart`, the `exampleItems*`/
      `emptyExampleItems*` arb keys, and `test/features/example_feature/`.
- [ ] Rerun build_runner + intl_utils; `flutter analyze` must stay clean.

## 6. Plumbing to review

- [ ] `DeepLinkHelper._handleUri` — set your link scheme/routes; configure app_links
      platform setup (Android intent filters / iOS associated domains).
- [ ] `AuthInterceptor` — token refresh / logout-on-401 policy if your API needs it.
- [ ] `LocalStorageKeys` — add your keys; never store tokens outside secure storage.
- [ ] CI: run `flutter analyze`, `flutter test`, and a debug build per PR.

## 7. Before the first release build

- [ ] Replace the debug signing config in `android/app/build.gradle.kts` with a real
      release keystore — `flutter build apk --release` currently signs with debug keys.
- [ ] Review the permissions in `android/app/src/main/AndroidManifest.xml`: `INTERNET`
      is required; drop `POST_NOTIFICATIONS` (and the `UIBackgroundModes` entry in
      `ios/Runner/Info.plist`) if you're not shipping push notifications.
- [ ] Test a release build on a real device — network failures caused by a missing
      permission never show up in debug.
