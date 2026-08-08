import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/example_item.dart';

part 'example_item_model.g.dart';

@JsonSerializable(createToJson: false, checked: true)
class ExampleItemModel {
  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description', defaultValue: '')
  final String description;
  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;

  ExampleItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isLiked,
  });

  factory ExampleItemModel.fromJson(Map<String, dynamic> json) => _$ExampleItemModelFromJson(json);

  ExampleItem toDomain() => ExampleItem(
    id: id,
    title: title,
    description: description,
    isLiked: isLiked,
  );
}
