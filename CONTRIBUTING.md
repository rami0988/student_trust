# Contributing

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Files & folders | `snake_case` | `example_item_card.dart` |
| Classes | `PascalCase` | `ExampleItemCard` |
| Feature folders | `snake_case` noun/flow | `example_feature`, `my_orders` |
| Data source | `x_remote_data_source.dart` + `_impl` | `ExampleFeatureRemoteDataSource(Impl)` |
| Repository | `x_repository.dart` (domain) + `x_repository_impl.dart` (data) | `ExampleFeatureRepository(Impl)` |
| Use case | `verb_noun_use_case.dart`, class with `call()` | `GetExampleItemsUseCase` |
| Bloc trio | `x_bloc.dart`, `x_event.dart`, `x_state.dart` | `ExampleFeatureBloc` |
| Cubit pair | `x_cubit.dart`, `x_state.dart` | `ExampleItemDetailsCubit` |
| Page | `x_page.dart` (+ `x_page_args.dart` / `x_args.dart` beside it) | `ExampleItemsPage` |
| JSON model | `x_model.dart` with `toDomain()` | `ExampleItemModel` |
| Entity | plain noun, Equatable | `ExampleItem` |
| Generated | `.g.dart` — never edit by hand | `example_item_model.g.dart` |
| Injected fields | `final Type _camelName;` positional constructor params | `this._exampleFeatureRepository` |
| Event bus events | `x_event.dart` in `core/event_bus/` | `ExampleItemChangedEvent` |

Style rules come from `analysis_options.yaml`: relative imports inside `lib/`,
`prefer_const_*`, 120-char lines, trailing commas preserved.

## How to add a new feature, step by step

Reference implementation: `lib/features/example_feature`. Keep it open while you work.

1. **Scaffold**
   ```bash
   dart run scripts/create_feature.dart --name my_feature          # or --cubit
   ```
2. **Endpoints** — add the paths to `lib/core/network/endpoints.dart` under a
   `/// *** My Feature ***` section.
3. **Domain first** — define the entity (Equatable) in `domain/entities/`, the repository
   contract in `domain/repositories/` returning `Future<RequestResult<...>>`, and a use case
   per operation that is shared/composed (skip use cases for simple one-off calls and use
   the repository straight from the cubit).
4. **Data** — write the `json_serializable` model with a `toDomain()` mapper; implement the
   data source with `performGetRequest`/`performPostRequest`/…:
   - list + pagination → `XPaginationModel.fromJson(baseModel.toJson())`
   - single object → `XModel.fromJson(baseModel.data)`
   Implement the repository with `execute(() => dataSource.x(), converter: (m) => m.toDomain())`.
5. **Presentation** — built_value state with `Status` + `Failure?`; bloc handles events
   (use `droppable()` for fetches), cubit exposes methods. Page switches on
   `state.status.isLoading / isEmpty / isFailure / isSuccess` and renders
   `Loader`/shimmers, `EmptyView`, `ErrorView`, or the content.
6. **Route** — add the name to `lib/core/routing/routes.dart` and the case to
   `AppRouter.generateRoute`, wrapping the page in its `BlocProvider` via `getIt`.
7. **Strings** — add keys to `lib/l10n/intl_en.arb` **and** `intl_ar.arb`, then
   `dart run intl_utils:generate`.
8. **Generate** —
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
9. **Cross-feature sync (only if needed)** — add a typed event in `lib/core/event_bus/`,
   fire it optimistically, subscribe in interested blocs, cancel in `close()`.
10. **Tests** — copy the two files in `test/features/example_feature/` and adapt:
    a bloc_test for the bloc, a mockito test for the repository. Rerun build_runner to
    generate the `.mocks.dart` files, then `flutter test`.

## Definition of done

- `flutter analyze` — zero issues.
- `flutter test` — green.
- No feature imports another feature; no JSON outside `data/`; no business strings
  hard-coded (everything through `S`).
