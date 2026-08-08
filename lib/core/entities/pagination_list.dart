import 'package:equatable/equatable.dart';

class PaginationList<T extends Equatable> extends Equatable {
  final List<T> data;
  final bool isLastPage;

  const PaginationList({required this.data, required this.isLastPage});

  @override
  List<Object?> get props => [data, isLastPage];
}
