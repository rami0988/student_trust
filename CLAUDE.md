# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project actually is

ثقة (Thiqa) / EduShield **student app** — a Flutter app for watching paid lesson videos
(subjects → chapters → lessons → video), reading worksheets, and downloading lessons for
encrypted offline playback. Its defining constraint is **content protection**: the app is
device-bound, blocks screen capture, refuses to run on emulators, and encrypts downloads
with a key that never leaves the device.

**Important:** the repo was grown from a generic Flutter starter, and `README.md`,
`ARCHITECTURE.md`, `CHECKLIST.md`, `CONTRIBUTING.md` are still largely the *template's*
docs. They describe things that are no longer true here — `example_feature`,
`MockApiInterceptor`, `Endpoints.mockServerUrl`, `test/features/example_feature/`, and the
`{success, message, data, meta}` envelope all no longer apply. The layering/naming
conventions in those files *are* still accurate and worth following; the setup steps and
example references are stale. Prefer this file and the actual code when they disagree.

The pubspec is still `name: mobile_template`, and the root widget is still called
`TemplateApp` — these are leftovers, not a signal that the app is unfinished.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # required after touching DI, models, or built_value state
flutter run                                                # production → https://api.ra-trust.site
flutter run -t lib/main_development.dart                   # development → ngrok URL in main_development.dart
dart run intl_utils:generate                               # after editing lib/l10n/*.arb
flutter analyze                                            # must be zero issues
flutter test
flutter test test/core/utils/app_validator_test.dart       # single file
flutter test --plain-name "validates email"                # single test by name
```

Add a feature scaffold with `dart run scripts/create_feature.dart --name my_feature [--cubit]`.
Note it generates against the *template's* envelope-based data-source pattern, so the
generated data source needs rewriting (see "Networking" below).

## Architecture

Clean Architecture, one vertical slice per feature under `lib/features/<name>/` with
`data/` (models + data sources + repository impl), `domain/` (entities, repository
contracts, use cases), `presentation/` (cubit + state + pages + widgets). Dependency
direction is `presentation → domain ← data`; presentation never imports `data/`.

Shared code lives in `lib/core/`; the app shell (`MaterialApp`, `AppCubit` for
language/flavor, `ConnectivityWatcher`) lives in `lib/app/`.

**Every feature here uses Cubit, not Bloc.** The catalog endpoints (subjects, chapters,
lessons) *are* paginated — see `core/models/pagination_model.dart` + `paginated_result.dart`
and the `loadMore*` methods on their cubits — but that pagination is hand-rolled in the
cubits rather than built on the template's bloc machinery (`PaginationStateData`,
`bloc_concurrency`), which is still present in `core/` but unused.

### Data flow

`Page → Cubit → UseCase (or repository directly) → XRepository (domain) → XRepositoryImpl
extends BaseRepositoryImpl → XRemoteDataSourceImpl → Dio`

`BaseRepositoryImpl.execute(...)` is the **only** place exceptions become failures. Data
sources throw (`exceptions.dart`), repositories return `RequestResult<T>` (`failures.dart`),
`ErrorHandler` converts. Cubits `fold` the result into a built_value state carrying
`Status status` + `Failure? failure`; pages switch on
`state.status.isLoading / isEmpty / isFailure / isSuccess`.

### Networking — no response envelope

This is the biggest deviation from the template docs. The backend returns **raw, unwrapped
JSON** at `<server>/api` (no `{success, message, data, meta}`, no `/v1`). Consequently:

- Data sources **do not** extend `BaseRemoteDataSourceImpl` — its `performGetRequest` /
  `performPostRequest` helpers require the envelope. They inject `Dio` directly and call
  `_dio.get(...)` / `_dio.post(...)` themselves, wrapping errors in
  `ErrorHandler.handleExceptionError(error)` so the repository contract is unchanged.
  `BaseRemoteDataSourceImpl` and `BaseModel` still exist but are effectively dead code.
- Follow `lib/features/subjects/data/data_sources/subjects_remote_data_source_impl.dart`
  or the auth one — those are the real reference implementations for new data sources.

`DioFactory` builds a singleton Dio with `AuthInterceptor` (offline pre-check → rejects as
`connectionError`, `Accept-Language`, Bearer token from secure storage),
`TokenRefreshInterceptor`, and `LoggingInterceptor`.

`TokenRefreshInterceptor` silently renews the 15-minute access token off the 7-day refresh
token and replays the failed request. Because the backend **rotates** refresh tokens
(single-use `jti`), it enforces **single-flight**: one shared `Completer` means concurrent
401s — which the video player produces routinely via overlapping range requests — trigger
exactly one `/auth/refresh`. It persists the rotated refresh token, and fires
`SessionExpiredEvent` (→ `SessionWatcher` → auth gate) **only** when the refresh genuinely
fails. The former `SessionInterceptor`, which hard-logged-out on *every* 401, has been
removed.

Video/thumbnail requests to BunnyCDN must carry `BunnyConstants.cdnHeaders`
(`Referer: https://iframe.mediadelivery.net/`) — the pull zone enforces a Referer
allow-list. The lesson stream endpoint behaves differently per environment: production
returns JSON `{mode: 'bunnycdn', directUrl}`, development returns a 206 byte range. Code
that fetches video probes with `Range: bytes=0-1` to tell them apart — see
`EncryptedDownloadService._resolveVideoUrl` and the online player.

## Content protection (the part to be careful with)

Treat these as load-bearing; don't weaken them while refactoring.

- **Device binding** — `DeviceService` derives a stable per-install UUID (SHA-256 of
  hardware identifiers), cached in secure storage. Sent as `X-Device-ID` on login for
  single-device enforcement, and fed into the offline encryption key.
- **Emulator block** — `AuthGate` refuses to proceed on a non-physical device. Root/jailbreak
  detection is *not* wired up: `flutter_jailbreak_detection` was removed because its
  `build.gradle` predates AGP namespaces and breaks under this project's AGP 9.
- **Screen capture** — `SecurityService` bridges `MethodChannel('com.edushield/security')`
  (`setSecureScreen` → `FLAG_SECURE` on Android) and
  `EventChannel('com.edushield/screen_capture')` (iOS `UIScreen.isCaptured`). Native sides
  live in `android/app/src/main/kotlin/com/edushield/edushield_student/MainActivity.kt` and
  `ios/Runner/AppDelegate.swift`. `VideoPlayerPage` enables/disables it around playback.
- **Encrypted downloads** — `EncryptedDownloadService` (`lib/features/downloads/data/services/`)
  streams video to disk, then writes AES-256-CBC chunks of 2 MB. The key is **derived, never
  stored**: `sha256("$studentId:$deviceUuid:$lessonId")`, so chunks copied to another device
  or account are undecryptable. Playback decrypts into a temp file that is deleted on leaving
  the player. Metadata lives in the Hive box `edushield_downloads`, which enforces a **7-day
  online re-validation window** (`getOfflineVideoPath` throws `VALIDATION_REQUIRED` past it).

## Routing and app-level wiring

Routes are named constants in `lib/core/routing/routes.dart`, built in
`AppRouter.generateRoute`, which wraps each page in its `BlocProvider` from `getIt` and
casts `settings.arguments` to the page's `XArgs` class.

- `Routes.authGate` is the entry point and the single place the auth decision is made
  (security check → silent auto-login → subjects or login). `ConnectivityWatcher` returns
  here when the connection is restored rather than duplicating that logic.
- `AuthCubit` is an app-wide `@lazySingleton` — always provide it with
  `BlocProvider.value(value: getIt<AuthCubit>())`, never `create:`, or popping a route will
  close it out from under `AuthGate`.
- `DownloadCubit` is provided in `main.dart` *above* the navigator so downloads survive
  screen changes. Hive's `edushield_downloads` box is opened in `main()` before
  `configureDependencies()`.
- Per-route cubits get `@injectable`; app-scoped ones get `@lazySingleton`. Register
  third-party singletons in `RegisterModule` in `lib/core/di/di.dart`.

## Conventions

- **Colors**: `AppColors` is canonical (the ثقة brand palette). `ColorsManager` is a
  compatibility shim mapping the template's legacy names onto `AppColors` — use `AppColors`
  in new code. Spacing comes from `AppTokens`. No hardcoded hex or `Colors.white`/`black`.
- **Localization**: Arabic-first (default locale `ar`, RTL must work everywhere). Add keys to
  **both** `lib/l10n/intl_en.arb` and `intl_ar.arb`, then run `intl_utils:generate`. Use
  `S.of(context).key` in widgets, `S.current.key` outside the tree. No hardcoded user-facing
  strings.
- **Imports**: relative inside `lib/` (`prefer_relative_imports` is enforced). 120-char lines,
  trailing commas preserved, `prefer_const_*` on.
- Features never import each other — share through `core/` entities or an `EventBus` event.
- Never hand-edit `.g.dart` / `di.config.dart`; run build_runner.
- Blocs/cubits own and dispose their controllers and `StreamSubscription`s in `close()`; they
  never hold a `BuildContext` (navigation uses the injected `GlobalKey<NavigatorState>`).

## Testing

Tests currently cover `core/` only (`error_handler`, `extensions`, `base_repository_impl`,
`app_validator`) — there are no feature tests and no generated `.mocks.dart` yet, despite
CONTRIBUTING.md pointing at a `test/features/example_feature/` that no longer exists. `mockito`
and `bloc_test` are available; adding mocks requires rerunning build_runner.

## Android / Gradle

AGP 9.0.1, Gradle 9.1.0, Kotlin 2.3.20, Flutter 3.44.8.

**The "migrate to Built-in Kotlin" warning is a known, currently-unfixable one — don't
attempt the migration.** Flutter warns that `android/app/build.gradle.kts` applies the
Kotlin Gradle Plugin and that `better_player_plus` does too. The obvious fix (set
`android.builtInKotlin=true`, drop `id("kotlin-android")`) **does not work here**:
`builtInKotlin` is a project-wide flag, so enabling it also forbids KGP in *plugin*
modules, and dependencies that still apply `org.jetbrains.kotlin.android` — `app_links`
7.2.1 and `better_player_plus` 1.3.4 among them — then fail to configure with:

> The 'org.jetbrains.kotlin.android' plugin is no longer required for Kotlin support since
> AGP 9.0.

This was tried and reverted. The warning is non-fatal on Flutter 3.44; revisit only once
those plugins ship versions that have themselves migrated. `better_player_plus` is already
at the latest 1.3.4 and still applies KGP.

Related: the app pins Kotlin's JVM target to 17 via the top-level `kotlin { compilerOptions
{ jvmTarget } }` block. Removing it causes "Inconsistent JVM Target Compatibility" because
Kotlin's default drifts ahead of `compileOptions`' Java 17.

## Release notes

Android release builds are still signed with the **debug** keystore
(`android/app/build.gradle.kts`) — must be replaced before any Play upload. The `namespace`
(`com.edushield.edushield_student`) and `applicationId` (`com.edushield.student`) intentionally
differ. Firebase is wired but **off** (`useFirebase = false` in both entry points) and the app
runs fine without it.
