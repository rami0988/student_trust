import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class PaginationStateDataHelper {
  PaginationStateDataHelper._();

  static bool _canGetMoreData({
    required bool isFinished,
    required bool isLoading,
    required List items,
  }) {
    return (!isFinished && !isLoading && items.isNotEmpty) ? true : false;
  }

  static bool shouldGetMoreData({
    required ScrollController scrollController,
    required bool isFinished,
    required bool isLoading,
    required List items,
  }) {
    final double maxScroll = scrollController.position.maxScrollExtent;
    final double currentScroll = scrollController.offset;
    bool isScrollingDown = scrollController.position.userScrollDirection == ScrollDirection.reverse;
    return (_canGetMoreData(
              isLoading: isLoading,
              isFinished: isFinished,
              items: items,
            ) &&
            currentScroll > (maxScroll * 0.99) &&
            isScrollingDown)
        ? true
        : false;
  }
}
