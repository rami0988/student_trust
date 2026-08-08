# Architecture

This template preserves the architecture of the production app it was extracted from.
Do not "improve" the patterns — mirror them. `lib/features/example_feature` is the
canonical implementation; when in doubt, copy it.

## Layers

Every feature is a vertical slice with three layers and a strict dependency direction:

```
presentation ──► domain ◄── data
```

- **domain** — pure Dart. Entities (Equatable), abstract repository contracts returning
  `RequestResult<T>`, and use-case classes. Knows nothing about JSON, Dio, or Flutter.
- **data** — JSON models (`json_serializable`, with `toDomain()` mappers), remote/local
  data sources, and the repository implementation. Data sources **throw** typed exceptions;
  repositories **catch** and return `RequestResult`.
- **presentation** — bloc or cubit + built_value state, pages, feature-private widgets.
  Depends on domain only (use cases or repository contracts), never on data.

Anything reusable across features lives in `lib/core`. The app shell (`lib/app`) holds the
`MaterialApp`, `AppCubit` (language + flavor), and the app-level repository.

## End-to-end data flow

```
Page (BlocProvider created in AppRouter)
  └─► Bloc/Cubit ── dispatches ──► UseCase (or repository directly for simple flows)
        └─► XRepository (abstract, domain)
              └─► XRepositoryImpl extends BaseRepositoryImpl        [data]
                    │   execute(() => dataSource.call(), converter: model.toDomain())
                    │   catches exceptions → Failure → FailureResult
                    └─► XRemoteDataSourceImpl extends BaseRemoteDataSourceImpl
                          │   performGetRequest(...) → BaseModel {success, message, data, meta}
                          │   throws ServerException / NetworkException / ParsingJsonException
                          └─► Dio (DioFactory: AuthInterceptor + LoggingInterceptor)
```

Back up the chain: `RequestResult.fold(success:, failure:)` in the bloc → built_value
`state.rebuild(...)` with `Status` + `Failure?` → `BlocBuilder` switches on
`state.status.isLoading / isEmpty / isFailure / isSuccess`.

## State management rules

- **Bloc** (`presentation/bloc/`) for screens with pagination, scroll listeners, or
  EventBus reactions. **Cubit** (`presentation/cubit/`) for forms and simple screens.
- States and Bloc events are **built_value** classes. Every state carries at least
  `Status status` and `Failure? failure`. Update with `state.rebuild((b) => b..x = y)`.
- Pagination is standardized: `PaginationStateData<T>` in state, `PaginationList<T>` from
  the repository, `PaginationStateDataHelper.shouldGetMoreData(...)` in a scroll listener,
  and `droppable()` from bloc_concurrency on the fetch event.
- Blocs/cubits own their controllers (`ScrollController`, `TextEditingController`) and
  dispose them in `close()`, along with every StreamSubscription.
- Blocs created per-route get `@injectable`; app-scoped ones get `@lazySingleton`;
  blocs needing route arguments are constructed manually in `AppRouter`
  (see `ExampleItemDetailsCubit`).

## Cross-feature sync (EventBus)

Features never import each other's blocs. When one screen changes data another screen
shows, fire a typed event from `lib/core/event_bus/` on the get_it `EventBus` singleton.
Interested blocs subscribe in their constructor and cancel in `close()`.

Optimistic updates: fire the event with the new value **before** the request, and fire it
again with the old value if the request fails. `ExampleFeatureBloc.LikeExampleItem` and
`ExampleItemDetailsCubit.toggleLike` are the reference implementations.

## Networking

- `Endpoints` holds the server URL (set at runtime by each entry point) and all paths.
- Every response is the envelope `{success, message, data, links, meta}` → `BaseModel`.
  - Lists + pagination: `XPaginationModel.fromJson(baseModel.toJson())` (reads `data` + `meta.last_page`).
  - Single objects: `XModel.fromJson(baseModel.data)`.
- `AuthInterceptor`: connectivity pre-check (rejects as connectionError when offline),
  `Accept-Language`, Bearer token from secure storage.
- `MockApiInterceptor` is template-only plumbing: it's registered only while the app points
  at `Endpoints.mockServerUrl`. Delete it once you have a real backend.

## Error handling

Two-tier: **data throws, repository returns.**
`exceptions.dart` (thrown below the repository) mirror `failures.dart` (returned above it);
`ErrorHandler` converts between them; `BaseRepositoryImpl.execute` is the only place the
conversion happens. UI renders failures through `ErrorView` (which picks
`NetworkErrorContainer` vs `ServerErrorContainer`) and toasts via `showToastMessage`.

## Flavors (two entry points, no .env)

Configuration lives in code, per entry point — there is deliberately no runtime .env loader:

| | `lib/main.dart` | `lib/main_development.dart` |
|---|---|---|
| Flavor | `AppFlavor.production` | `AppFlavor.development` |
| Server | `Endpoints.setServerUrl(<prod URL>)` | `Endpoints.setServerUrl(<dev URL>)` |
| Firebase | `firebase_options_prod.dart` | `firebase_options_dev.dart` |

Run the dev flavor with `flutter run -t lib/main_development.dart`. Add new per-environment
values by setting them in the entry points (like the server URL), not by adding a .env file.
The current flavor is readable anywhere via `AppCubit.state.flavor`.

## Localization & theming

- Arabic-first: default language is `ar`, persisted via `AppRepository`; `AppCubit`
  rebuilds `MaterialApp` (locale + theme) through a `BlocSelector`.
- Strings live in `lib/l10n/intl_en.arb` / `intl_ar.arb`; run `dart run intl_utils:generate`
  after editing. Use `S.of(context).key` in widgets, `S.current.key` outside the tree.
- The theme is language-aware: `AppThemeData.appTheme(language)` switches font family
  (Tajawal/Cairo). Rebrand by editing `ColorsManager` and `FontManager` only.

## Local storage

- `SharedPreferencesHelper`: static facade over SharedPreferences (plain values) and
  FlutterSecureStorage (tokens — `getSecuredString`/`setSecuredData`). Keys are centralized
  in `LocalStorageKeys`.
- Hive CE for structured data: a generic `app_box` is registered in DI; register typed
  boxes + adapters per feature in `RegisterModule` when needed.

## Do's & Don'ts

**Do**
- Copy `example_feature` for every new feature; keep file/class naming identical in shape.
- Keep relative imports inside `lib/` (`prefer_relative_imports` is enforced).
- Return `RequestResult` from every repository method; never let exceptions cross the
  repository boundary.
- Add a use case when an operation is shared or composes logic; call the repository
  directly from a cubit for simple one-off flows.

**Don't**
- Don't import one feature from another (share via `core/` entities or EventBus events).
- Don't parse JSON in blocs or map models in pages — mapping ends at the repository.
- Don't hold `BuildContext` in blocs; navigation goes through pages or the injected
  `GlobalKey<NavigatorState>` (see NotificationsHelper / DeepLinkHelper).
- Don't hand-write `.g.dart` files — always run build_runner.
