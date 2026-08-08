import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:event_bus/event_bus.dart';

import '../../../../core/event_bus/example_item_changed_event.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/example_feature_repository.dart';
import '../pages/example_item_details_args.dart';
import 'example_item_details_state.dart';

/// Reference cubit: simple fetch + Status/Failure handling, created with route
/// arguments directly in AppRouter (so it is NOT annotated with @injectable).
/// It both fires and listens to [ExampleItemChangedEvent], staying in sync
/// with the list screen.
class ExampleItemDetailsCubit extends Cubit<ExampleItemDetailsState> {
  final ExampleFeatureRepository _exampleFeatureRepository;
  final EventBus _eventBus;
  final ExampleItemDetailsArgs _args;

  StreamSubscription<ExampleItemChangedEvent>? _exampleItemChangedSubscription;

  ExampleItemDetailsCubit(
    this._exampleFeatureRepository,
    this._eventBus,
    this._args,
  ) : super(ExampleItemDetailsState.initial()) {
    _listenToExampleItemChanges();
  }

  void getExampleItem() async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _exampleFeatureRepository.getExampleItemById(_args.itemId);
    result.fold(
      failure: (failure) => emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..failure = failure,
        ),
      ),
      success: (item) => emit(
        state.rebuild(
          (b) => b
            ..status = Status.success
            ..item = item
            ..failure = null,
        ),
      ),
    );
  }

  void toggleLike() async {
    final item = state.item;
    if (item == null) return;
    final bool newIsLiked = !item.isLiked;
    // Optimistic update: broadcast the change first, revert if the request fails.
    _eventBus.fire(ExampleItemChangedEvent(itemId: item.id, isLiked: newIsLiked));
    final result = newIsLiked
        ? await _exampleFeatureRepository.likeExampleItem(item.id)
        : await _exampleFeatureRepository.unlikeExampleItem(item.id);
    if (result.isFailure) {
      _eventBus.fire(ExampleItemChangedEvent(itemId: item.id, isLiked: !newIsLiked));
    }
  }

  void _listenToExampleItemChanges() {
    _exampleItemChangedSubscription = _eventBus.on<ExampleItemChangedEvent>().listen((event) {
      if (isClosed) return;
      final item = state.item;
      if (item == null || item.id != event.itemId) return;
      emit(state.rebuild((b) => b..item = item.copyWith(isLiked: event.isLiked)));
    });
  }

  @override
  Future<void> close() {
    _exampleItemChangedSubscription?.cancel();
    return super.close();
  }
}
