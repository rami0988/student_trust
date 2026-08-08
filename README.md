# Mobile Template

A production-shaped Flutter starter: Clean Architecture (data / domain / presentation),
bloc + built_value state, Dio networking with a unified response envelope, DI via
get_it + injectable, and Arabic-first localization.

**It runs end-to-end with no backend** — a bundled mock interceptor serves realistic
responses until you point it at your API.

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run                                   # production flavor
flutter run -t lib/main_development.dart      # development flavor
```

## Make it yours

```bash
dart run scripts/rename.dart --name "My App" --package my_app --bundle-id com.company.my_app
flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

Then follow **[CHECKLIST.md](CHECKLIST.md)** top to bottom — it covers the server URL,
removing the mock interceptor, branding, optional Firebase, and replacing the example feature.

## Add a feature

```bash
dart run scripts/create_feature.dart --name my_feature          # bloc: lists, pagination
dart run scripts/create_feature.dart --name my_feature --cubit  # cubit: forms, simple screens
```

The generated slice mirrors `lib/features/example_feature`, which is the canonical
reference implementation — keep it open while you work, and copy it.

## Documentation

| File | What's in it |
|---|---|
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | Layers, data flow, state-management rules, error handling, flavors |
| **[CHECKLIST.md](CHECKLIST.md)** | Day-1 setup, step by step |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | Naming conventions, how to add a feature, definition of done |

## What's included

- **Networking** — Dio + `{success, message, data, meta}` envelope, auth/logging
  interceptors, connectivity pre-check, typed exceptions → failures
- **State** — bloc (pagination, scroll, EventBus) and cubit (forms), built_value states
  carrying `Status` + `Failure?`
- **Cross-feature sync** — typed EventBus events with optimistic-update support
- **Localization** — Arabic/English via `intl_utils`, language-aware theme (Tajawal/Cairo)
- **Storage** — SharedPreferences + FlutterSecureStorage facade, Hive CE for structured data
- **UI kit** — ~20 shared widgets in `lib/core/widgets/` (text fields, dropdowns, shimmers,
  error/empty views, refresh indicator, network image)
- **Optional** — Firebase messaging + local notifications, deep links (both off by default)

## Project layout

```
lib/
├── app/          MaterialApp shell, AppCubit (language + flavor)
├── core/         everything shared: network, di, theme, widgets, utils, error
├── features/     one vertical slice per feature (data / domain / presentation)
└── l10n/         intl_en.arb, intl_ar.arb
```

## Before you ship

- `flutter analyze` — zero issues
- `flutter test` — green
- Set real server URLs in both entry points and delete `MockApiInterceptor`
- Replace the debug signing config in `android/app/build.gradle.kts` with your release keystore
- Replace launcher icons and the `com.example` bundle id (the rename script handles the id)
