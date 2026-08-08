import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/entities/pagination_state_data.dart';
import '../../../../core/event_bus/example_item_changed_event.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/pagination_state_data_helper.dart';
import '../../domain/entities/example_item.dart';
import '../../domain/use_cases/get_example_items_use_case.dart';
import '../../domain/use_cases/like_example_item_use_case.dart';
import '../../domain/use_cases/unlike_example_item_use_case.dart';
import 'example_feature_event.dart';
import 'example_feature_state.dart';

/// Reference bloc: paginated list + Status/Failure handling + optimistic
/// like-toggle synced across screens through the EventBus.
@injectable
class ExampleFeatureBloc extends Bloc<ExampleFeatureEvent, ExampleFeatureState> {
  final GetExampleItemsUseCase _getExampleItemsUseCase;
  final LikeExampleItemUseCase _likeExampleItemUseCase;
  final UnlikeExampleItemUseCase _unlikeExampleItemUseCase;
  final EventBus _eventBus;

  final ScrollController scrollController = ScrollController();

  StreamSubscription<ExampleItemChangedEvent>? _exampleItemChangedSubscription;

  ExampleFeatureBloc(
    this._getExampleItemsUseCase,
    this._likeExampleItemUseCase,
    this._unlikeExampleItemUseCase,
    this._eventBus,
  ) : super(ExampleFeatureState.initial()) {
    scrollController.addListener(_exampleItemsScrollListener);
    _listenToExampleItemChanges();
    on<GetExampleItems>((event, emit) async {
      if (event.reInitialData) {
        emit(
          state.rebuild(
            (ExampleFeatureStateBuilder b) => b..items.replace(PaginationStateData<ExampleItem>.initial()),
          ),
        );
      }

      if (state.items.currentPage == 1) {
        emit(
          state.rebuild(
            (ExampleFeatureStateBuilder b) => b
              ..status = Status.loading
              ..failure = null,
          ),
        );
      } else {
        emit(
          state.rebuild(
            (ExampleFeatureStateBuilder b) => b..items.isLoading = true,
          ),
        );
      }

      final result = await _getExampleItemsUseCase(state.items.currentPage);

      result.fold(
        failure: (failure) => emit(
          state.rebuild(
            (ExampleFeatureStateBuilder b) => b
              ..status = state.items.currentPage == 1 ? Status.failure : state.status
              ..items.isLoading = false
              ..failure = state.items.currentPage == 1 ? failure : null,
          ),
        ),
        success: (data) => emit(
          state.rebuild(
            (ExampleFeatureStateBuilder b) => b
              ..items.currentPage = state.items.currentPage + 1
              ..items.items = [
                ...state.items.items,
                ...data.data,
              ]
              ..items.isLoading = false
              ..status = state.items.currentPage == 1 && data.data.isEmpty ? Status.empty : Status.success
              ..items.isFinished = data.isLastPage
              ..failure = null,
          ),
        ),
      );
    }, transformer: droppable());
    on<LikeExampleItem>((event, emit) async {
      // Optimistic update: broadcast the change first, revert if the request fails.
      _eventBus.fire(ExampleItemChangedEvent(itemId: event.itemId, isLiked: true));
      final result = await _likeExampleItemUseCase(event.itemId);
      if (result.isFailure) {
        _eventBus.fire(ExampleItemChangedEvent(itemId: event.itemId, isLiked: false));
      }
    });
    on<UnlikeExampleItem>((event, emit) async {
      _eventBus.fire(ExampleItemChangedEvent(itemId: event.itemId, isLiked: false));
      final result = await _unlikeExampleItemUseCase(event.itemId);
      if (result.isFailure) {
        _eventBus.fire(ExampleItemChangedEvent(itemId: event.itemId, isLiked: true));
      }
    });

    on<ChangeExampleItemLikeStateInternally>((event, emit) {
      final List<ExampleItem> updatedItems = state.items.items.map((item) {
        if (item.id == event.itemId) {
          return item.copyWith(isLiked: event.isLiked);
        }
        return item;
      }).toList();
      emit(state.rebuild((b) => b..items.items = updatedItems));
    });
  }

  void _exampleItemsScrollListener() {
    if (PaginationStateDataHelper.shouldGetMoreData(
      scrollController: scrollController,
      isFinished: state.items.isFinished,
      isLoading: state.items.isLoading,
      items: state.items.items.toList(),
    )) {
      add(GetExampleItems((b) => b..reInitialData = false));
    }
  }

  void _listenToExampleItemChanges() {
    _exampleItemChangedSubscription = _eventBus.on<ExampleItemChangedEvent>().listen((event) {
      if (isClosed) return;
      add(
        ChangeExampleItemLikeStateInternally(
          (b) => b
            ..itemId = event.itemId
            ..isLiked = event.isLiked,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    scrollController.removeListener(_exampleItemsScrollListener);
    scrollController.dispose();
    _exampleItemChangedSubscription?.cancel();
    return super.close();
  }
}
