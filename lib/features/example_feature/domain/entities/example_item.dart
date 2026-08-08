import 'package:equatable/equatable.dart';

class ExampleItem extends Equatable {
  final int id;
  final String title;
  final String description;
  final bool isLiked;

  const ExampleItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isLiked,
  });

  ExampleItem copyWith({bool? isLiked}) => ExampleItem(
    id: id,
    title: title,
    description: description,
    isLiked: isLiked ?? this.isLiked,
  );

  @override
  List<Object?> get props => [id, title, description, isLiked];
}
