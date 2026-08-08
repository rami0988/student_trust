import 'package:json_annotation/json_annotation.dart';

part 'link_model.g.dart';

@JsonSerializable(checked: true)
class LinkModel {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  LinkModel({this.first, this.last, this.prev, required this.next});

  factory LinkModel.fromJson(Map<String, dynamic> json) => _$LinkModelFromJson(json);

  Map<String, dynamic> toJson() => _$LinkModelToJson(this);
}
